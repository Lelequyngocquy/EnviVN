import 'dart:ui';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/infrastructure/configs/env_config.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/core/presentation/widgets/loading.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/map/domain/entities/flood_blackspot.dart';
import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/features/map/domain/entities/station_entity.dart';
import 'package:envivn/src/features/map/infrastructure/models/thermal_hotspot_model.dart';
import 'package:envivn/src/features/map/presentation/cubits/map_cubit.dart';
import 'package:envivn/src/features/map/presentation/cubits/map_state.dart';
import 'package:envivn/src/features/map/presentation/widgets/dropped_pin_marker_widget.dart';
import 'package:envivn/src/features/map/presentation/widgets/map_layer_selector_sheet.dart';
import 'package:envivn/src/features/map/presentation/widgets/map_side_controls.dart';
import 'package:envivn/src/features/map/presentation/widgets/map_top_control_bar.dart';
import 'package:envivn/src/features/map/presentation/widgets/map_zoom_controls.dart';
import 'package:envivn/src/features/map/presentation/widgets/station_marker_widget.dart';
import 'package:envivn/src/features/map/presentation/widgets/station_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gap/gap.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  bool _isMapReady = false;
  double _currentZoom = 5.8;

  static final LatLngBounds _vietnamMapBounds = LatLngBounds(
    const LatLng(2.5, 101.8),
    const LatLng(28.0, 117.2),
  );

  double _calculateMarkerScale(double zoom) {
    if (zoom <= 5.0) return 0.55;
    if (zoom >= 12.0) {
      return (1.0 + (zoom - 12.0) * 0.025).clamp(1.0, 1.15);
    }
    return 0.55 + ((zoom - 5.0) / (12.0 - 5.0)) * (1.0 - 0.55);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mapCubit = context.read<MapCubit>();
      final homeCubit = context.read<HomeDashboardCubit>();

      AppLocationEntity effectiveCity = homeCubit.state.currentCity;
      if (effectiveCity == AppLocationEntity.defaultLocation) {
        final saved = homeCubit.storage.getSelectedCity();
        if (saved != null) {
          final rawName = saved['name']?.toString() ?? effectiveCity.name;
          final normalizedName = rawName.startsWith('Vị trí hiện tại')
              ? 'Vị trí hiện tại'
              : rawName;
          effectiveCity = AppLocationEntity.city(
            name: normalizedName,
            province: normalizedName == 'Vị trí hiện tại'
                ? 'Định vị GPS'
                : (saved['province']?.toString() ??
                      (saved['name']?.toString() ?? effectiveCity.province)),
            latitude:
                double.tryParse(saved['lat']?.toString() ?? '') ??
                effectiveCity.latitude,
            longitude:
                double.tryParse(saved['lon']?.toString() ?? '') ??
                effectiveCity.longitude,
            isGps: normalizedName == 'Vị trí hiện tại',
          );
        }
      }

      final isPermissionGranted = homeCubit.state.isLocationPermissionGranted;

      if (isPermissionGranted && effectiveCity.isGps) {
        mapCubit.setUserGpsLocation(
          LatLng(effectiveCity.latitude, effectiveCity.longitude),
        );
      } else {
        mapCubit.clearUserGpsLocation();
      }

      if (isPermissionGranted) {
        mapCubit.loadUserGpsLocation(
          fallbackCoords: effectiveCity.isGps
              ? LatLng(effectiveCity.latitude, effectiveCity.longitude)
              : null,
        );
      }

      if (mapCubit.state.stations.isEmpty) {
        final targetCityName =
            mapCubit.state.selectedCityName ?? effectiveCity.name;
        final targetCoords =
            mapCubit.state.targetLocation ??
            LatLng(effectiveCity.latitude, effectiveCity.longitude);

        mapCubit
            .fetchVietnamStations(
              initialCity: targetCityName,
              initialCoords: targetCoords,
            )
            .then((_) {
              if (mounted) {
                if (mapCubit.state.targetLocation != null) {
                  _safeMove(
                    mapCubit.state.targetLocation!,
                    mapCubit.state.targetZoom ?? 12.0,
                  );
                } else if (homeCubit.state.hasPendingMapSync) {
                  _syncWithHomeCity(effectiveCity);
                  homeCubit.consumeMapSync();
                }
              }
            });
      } else {
        if (mapCubit.state.targetLocation != null) {
          _safeMove(
            mapCubit.state.targetLocation!,
            mapCubit.state.targetZoom ?? 12.0,
          );
        } else if (homeCubit.state.hasPendingMapSync) {
          _syncWithHomeCity(effectiveCity);
          homeCubit.consumeMapSync();
        }
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _syncWithHomeCity(AppLocationEntity city) {
    final mapCubit = context.read<MapCubit>();
    mapCubit.selectHomeLocation(
      lat: city.latitude,
      lon: city.longitude,
      zoom: 12.0,
      label: city.name,
    );
    _safeMove(LatLng(city.latitude, city.longitude), 12.0);
  }

  void _moveToCurrentGpsLocation() async {
    final homeCubit = context.read<HomeDashboardCubit>();
    await homeCubit.detectGpsLocation();
    final updatedCity = homeCubit.state.currentCity;
    _syncWithHomeCity(updatedCity);
  }

  void _safeMove(LatLng latLng, double zoom) {
    if (!_isMapReady || !mounted) return;
    try {
      _mapController.move(latLng, zoom);
      if ((zoom - _currentZoom).abs() >= 0.06) {
        setState(() {
          _currentZoom = zoom;
        });
      }
    } catch (e) {
      debugPrint('⚠️ [MapController.move] Bỏ qua di chuyển: $e');
    }
  }

  void _zoomIn() {
    if (!_isMapReady) return;
    try {
      final curZoom = _mapController.camera.zoom;
      final targetZoom = (curZoom + 1.0).clamp(4.5, 18.0);
      _safeMove(_mapController.camera.center, targetZoom);
    } catch (e) {
      debugPrint('⚠️ [MapController.zoomIn] Lỗi zoom: $e');
    }
  }

  void _zoomOut() {
    if (!_isMapReady) return;
    try {
      final curZoom = _mapController.camera.zoom;
      final targetZoom = (curZoom - 1.0).clamp(4.6, 18.0);
      _safeMove(_mapController.camera.center, targetZoom);
    } catch (e) {
      debugPrint('⚠️ [MapController.zoomOut] Lỗi zoom: $e');
    }
  }

  void _openLayerSelector(BuildContext context, MapLayerType currentLayer) {
    MapLayerSelectorSheet.show(
      context,
      currentLayer: currentLayer,
      onLayerSelected: (newLayer) {
        context.read<MapCubit>().switchMapLayer(newLayer);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeDashboardCubit, HomeDashboardState>(
      listenWhen: (prev, curr) {
        final switchedToMap = prev.currentTab != 1 && curr.currentTab == 1;
        final cityChanged = prev.currentCity != curr.currentCity;
        final permissionChanged =
            prev.isLocationPermissionGranted !=
            curr.isLocationPermissionGranted;
        return (switchedToMap && curr.hasPendingMapSync) ||
            (curr.currentTab == 1 && (cityChanged || permissionChanged));
      },
      listener: (context, homeState) {
        final mapCubit = context.read<MapCubit>();
        if (!homeState.isLocationPermissionGranted) {
          mapCubit.clearUserGpsLocation();
        } else if (homeState.currentCity.isGps) {
          mapCubit.setUserGpsLocation(
            LatLng(
              homeState.currentCity.latitude,
              homeState.currentCity.longitude,
            ),
          );
        }

        final hasActiveMapSelection =
            mapCubit.state.pickedLocation != null ||
            mapCubit.state.selectedStation != null;

        if (homeState.hasPendingMapSync ||
            (mapCubit.state.isHomeSelected && !hasActiveMapSelection)) {
          _syncWithHomeCity(homeState.currentCity);
        }
        context.read<HomeDashboardCubit>().consumeMapSync();
      },
      child: Scaffold(
        backgroundColor: UIColors.bg,
        body: BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
          buildWhen: (prev, curr) =>
              prev.currentCity != curr.currentCity ||
              prev.isLocationPermissionGranted !=
                  curr.isLocationPermissionGranted,
          builder: (context, homeState) {
            return BlocConsumer<MapCubit, MapState>(
              listenWhen: (prev, curr) =>
                  (curr.targetLocation != null &&
                      (prev.targetLocation != curr.targetLocation ||
                          prev.targetZoom != curr.targetZoom)) ||
                  prev.selectedStation != curr.selectedStation,
              listener: (context, state) {
                if (state.targetLocation != null && state.targetZoom != null) {
                  _safeMove(state.targetLocation!, state.targetZoom!);
                }
                final station = state.selectedStation;
                if (station != null && !state.isHomeSelected) {
                  final isPicked = station.id.startsWith('picked_');
                  final location = isPicked
                      ? AppLocationEntity.customPin(
                          latitude: station.latitude,
                          longitude: station.longitude,
                          customName: station.name,
                          referenceProvince: station.province,
                          distanceKm: state.pickedDistanceKm,
                        )
                      : AppLocationEntity.station(
                          id: station.id,
                          name: station.name,
                          province: station.province,
                          latitude: station.latitude,
                          longitude: station.longitude,
                        );
                  context.read<HomeDashboardCubit>().syncLocationFromMap(
                    location,
                  );
                }
              },
              builder: (context, state) {
                if (state.status == MapStatus.loading &&
                    state.stations.isEmpty) {
                  return const LoadingWidget(
                    message: 'Đang tải bản đồ & trạm quan trắc...',
                  );
                }

                final filteredStations = state.filteredStations;

                final isPermissionGranted =
                    homeState.isLocationPermissionGranted;
                final userGps = isPermissionGranted
                    ? (state.userGpsLocation ??
                          (homeState.currentCity.isGps
                              ? LatLng(
                                  homeState.currentCity.latitude,
                                  homeState.currentCity.longitude,
                                )
                              : null))
                    : null;

                final markerScale = _calculateMarkerScale(_currentZoom);
                final circles = <CircleMarker>[];

                if (userGps != null) {
                  circles.add(
                    CircleMarker(
                      point: userGps,
                      radius: (35 * markerScale).clamp(20.0, 45.0),
                      useRadiusInMeter: false,
                      color: UIColors.gpsBlue.withOpacity(0.12),
                      borderColor: UIColors.gpsBlue.withOpacity(0.4),
                      borderStrokeWidth: 1.2,
                    ),
                  );
                }

                if (state.pickedLocation != null) {
                  circles.add(
                    CircleMarker(
                      point: LatLng(
                        (state.pickedLocation?.latitude ?? 0),
                        state.pickedLocation?.longitude ?? 0,
                      ),
                      radius: 38 * markerScale,
                      useRadiusInMeter: false,
                      color: UIColors.pinPurple.withOpacity(0.18),
                      borderColor: UIColors.pinPurple.withOpacity(0.55),
                      borderStrokeWidth: 1.5,
                    ),
                  );
                  circles.add(
                    CircleMarker(
                      point: LatLng(
                        (state.pickedLocation?.latitude ?? 0),
                        state.pickedLocation?.longitude ?? 0,
                      ),
                      radius: 18 * markerScale,
                      useRadiusInMeter: false,
                      color: UIColors.pinPurple.withOpacity(0.32),
                      borderColor: UIColors.transparent,
                    ),
                  );
                }

                if (state.showHeatmap) {
                  for (final st in filteredStations) {
                    Color circleColor;
                    switch (state.activeLayer) {
                      case MapLayerType.weather:
                        final weatherInfo = WeatherCodeHelper.getInfo(
                          st.weatherCode,
                        );
                        circleColor = weatherInfo.color;
                        break;
                      case MapLayerType.airQuality:
                        final aqiInfo = AQIHelper.getAQIInfo(st.aqi);
                        circleColor = aqiInfo.color;
                        break;
                      case MapLayerType.thermal:
                        circleColor = st.heatRiskLevel.color;
                        break;
                      case MapLayerType.flood:
                        circleColor = st.isHighFloodRisk
                            ? UIColors.markerRed
                            : UIColors.gpsBlue;
                        break;
                    }

                    circles.add(
                      CircleMarker(
                        point: LatLng(st.latitude, st.longitude),
                        radius: 46 * markerScale,
                        useRadiusInMeter: false,
                        color: circleColor.withOpacity(0.18),
                        borderColor: circleColor.withOpacity(0.35),
                        borderStrokeWidth: 1.5,
                      ),
                    );
                    circles.add(
                      CircleMarker(
                        point: LatLng(st.latitude, st.longitude),
                        radius: 24 * markerScale,
                        useRadiusInMeter: false,
                        color: circleColor.withOpacity(0.3),
                        borderColor: UIColors.transparent,
                      ),
                    );
                  }
                }

                const baseStationW = 80.0;
                const baseStationH = 34.0;
                final markers = filteredStations.map((st) {
                  final isSelected = state.selectedStation?.id == st.id;
                  final w = baseStationW * markerScale;
                  final h = baseStationH * markerScale;
                  return Marker(
                    point: LatLng(st.latitude, st.longitude),
                    width: w,
                    height: h,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: StationMarkerWidget(
                        station: st,
                        isSelected: isSelected,
                        activeLayer: state.activeLayer,
                        onTap: () {
                          context.read<MapCubit>().selectStation(st);
                        },
                      ),
                    ),
                  );
                }).toList();

                if (state.activeLayer == MapLayerType.thermal) {
                  final thermalSpots = state.thermalHotspots.isNotEmpty
                      ? state.thermalHotspots
                      : ThermalHotspotModel.sampleHotspots;
                  for (final spot in thermalSpots) {
                    final isSelected = state.selectedStation?.id == spot.id;
                    final isActive = spot.isActiveFire;

                    final markerColor = isActive
                        ? UIColors.markerRedDark
                        : UIColors.warning;
                    final markerIcon = isActive
                        ? Icons.local_fire_department_rounded
                        : Icons.whatshot_outlined;

                    const baseSpotSize = 46.0;
                    final size = baseSpotSize * markerScale;

                    markers.add(
                      Marker(
                        point: LatLng(spot.latitude, spot.longitude),
                        width: size,
                        height: size,
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: baseSpotSize,
                            height: baseSpotSize,
                            child: GestureDetector(
                              onTap: () {
                                final spotStation = StationEntity(
                                  id: spot.id,
                                  name: spot.locationName,
                                  province: spot.province,
                                  latitude: spot.latitude,
                                  longitude: spot.longitude,
                                  aqi: isActive ? 165 : 45,
                                  pm25: isActive ? 85.0 : 15.0,
                                  pm10: isActive ? 110.0 : 25.0,
                                  updatedAt: DateTime.now(),
                                  isThermalHotspot: true,
                                  isActiveFire: isActive,
                                  fireType: spot.fireType,
                                  fireBrightnessCelsius: spot.brightnessCelsius,
                                  fireConfidence: spot.confidence,
                                  fireProneSeason: spot.proneSeason,
                                  fireDetectedTime: spot.detectedTime,
                                  spotDescription: spot.description,

                                  temperature: isActive
                                      ? spot.brightnessCelsius.clamp(38.0, 75.0)
                                      : null,
                                  apparentTemp: isActive
                                      ? spot.brightnessCelsius.clamp(42.0, 80.0)
                                      : null,
                                  weatherCode: isActive ? 1 : null,
                                  humidity: isActive ? 35 : null,
                                  windSpeed: isActive ? 16.0 : null,
                                  uvIndex: isActive ? 9.0 : null,
                                );
                                context.read<MapCubit>().selectStation(
                                  spotStation,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: markerColor.withOpacity(
                                    isSelected ? 0.95 : 0.82,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? UIColors.white
                                        : UIColors.cardBg,
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: markerColor.withOpacity(
                                        isActive ? 0.75 : 0.45,
                                      ),
                                      blurRadius: isSelected
                                          ? 12
                                          : (isActive ? 8 : 5),
                                      spreadRadius: isActive ? 1 : 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: AppIcon(
                                    markerIcon,
                                    color: isActive
                                        ? UIColors.white
                                        : UIColors.bg,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                } else if (state.activeLayer == MapLayerType.flood) {
                  for (final spot in FloodBlackspot.vietnamBlackspots) {
                    final isSelected = state.selectedStation?.id == spot.id;
                    const baseSpotSize = 46.0;
                    final size = baseSpotSize * markerScale;

                    markers.add(
                      Marker(
                        point: LatLng(spot.latitude, spot.longitude),
                        width: size,
                        height: size,
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: baseSpotSize,
                            height: baseSpotSize,
                            child: GestureDetector(
                              onTap: () {
                                final spotStation = StationEntity(
                                  id: spot.id,
                                  name: spot.name,
                                  province: spot.province,
                                  latitude: spot.latitude,
                                  longitude: spot.longitude,
                                  aqi: 35,
                                  pm25: 10.0,
                                  pm10: 18.0,
                                  updatedAt: DateTime.now(),

                                  isFloodBlackspot: true,
                                  historicalDepthCm: spot.averageDepthCm,
                                  floodTriggerCondition: spot.triggerCondition,
                                  floodProneTime: spot.proneTime,
                                  spotDescription: spot.description,
                                );
                                context.read<MapCubit>().selectStation(
                                  spotStation,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: UIColors.warning.withOpacity(
                                    isSelected ? 0.95 : 0.82,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? UIColors.white
                                        : UIColors.cardBg,
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: UIColors.warning.withOpacity(0.55),
                                      blurRadius: isSelected ? 12 : 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: AppIcon(
                                    Icons.warning_amber_rounded,
                                    color: UIColors.bg,
                                    size: 21,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }

                if (userGps != null) {
                  markers.add(
                    Marker(
                      point: userGps,
                      width: 28,
                      height: 28,
                      child: GestureDetector(
                        onTap: () {
                          _syncWithHomeCity(homeState.currentCity);
                        },
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: UIColors.gpsBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: UIColors.white,
                                width: 2.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: UIColors.gpsBlue.withOpacity(0.7),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: UIColors.black.withOpacity(0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (state.pickedLocation != null) {
                  const basePinSize = 42.0;
                  final pinSize = basePinSize * markerScale;
                  markers.add(
                    Marker(
                      point: state.pickedLocation!,
                      width: pinSize,
                      height: pinSize,
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: basePinSize,
                          height: basePinSize,
                          child: DroppedPinMarkerWidget(
                            isLoading: state.isPickingLocation,
                            onTap: () {
                              context.read<MapCubit>().pickCustomLocation(
                                state.pickedLocation!,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }

                const archipelagos = [
                  (
                    name: 'Quần đảo Hoàng Sa',
                    sovereignty: '(Việt Nam)',
                    coords: LatLng(15.5500, 112.0333),
                  ),
                  (
                    name: 'Quần đảo Trường Sa',
                    sovereignty: '(Việt Nam)',
                    coords: LatLng(8.7500, 114.2500),
                  ),
                ];

                for (final item in archipelagos) {
                  final labelW = (130.0 * markerScale).clamp(85.0, 140.0);
                  final labelH = (38.0 * markerScale).clamp(26.0, 42.0);
                  markers.add(
                    Marker(
                      point: item.coords,
                      width: labelW,
                      height: labelH,
                      alignment: Alignment.center,
                      child: IgnorePointer(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: UIColors.bg.withOpacity(0.38),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: UIColors.white.withOpacity(0.18),
                                    width: 0.7,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: UIColors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText.bold(
                                      item.name,
                                      size: 10.5,
                                      color: UIColors.textPrimary,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            color: UIColors.black.withOpacity(
                                              0.7,
                                            ),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(1),
                                    AppText.semiBold(
                                      item.sovereignty,
                                      size: 8.5,
                                      color: UIColors.secondary,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            color: UIColors.black.withOpacity(
                                              0.7,
                                            ),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        backgroundColor: UIColors.bg,
                        initialCenter:
                            context.read<MapCubit>().state.targetLocation ??
                            const LatLng(16.0544, 108.2022),
                        initialZoom:
                            context.read<MapCubit>().state.targetZoom ?? 5.8,
                        minZoom: 4.6,
                        maxZoom: 18.0,
                        cameraConstraint: CameraConstraint.containCenter(
                          bounds: _vietnamMapBounds,
                        ),
                        onMapReady: () {
                          _isMapReady = true;
                          _currentZoom = _mapController.camera.zoom;
                          final curState = context.read<MapCubit>().state;
                          if (curState.targetLocation != null &&
                              curState.targetZoom != null) {
                            _safeMove(
                              curState.targetLocation!,
                              curState.targetZoom!,
                            );
                          }
                        },
                        onPositionChanged: (camera, hasGesture) {
                          final oldScale = _calculateMarkerScale(_currentZoom);
                          final newScale = _calculateMarkerScale(camera.zoom);
                          if (oldScale != newScale) {
                            setState(() {
                              _currentZoom = camera.zoom;
                            });
                          }
                        },
                        onTap: (tapPosition, point) {
                          if (_vietnamMapBounds.contains(point)) {
                            context.read<MapCubit>().pickCustomLocation(point);
                          }
                        },
                      ),
                      children: [
                        RepaintBoundary(
                          child: TileLayer(
                            urlTemplate: EnvConfig.osmTileUrl,
                            userAgentPackageName: EnvConfig.mapUserAgent,
                            tileBuilder: darkModeTileBuilder,
                            tileBounds: _vietnamMapBounds,
                          ),
                        ),

                        PolygonLayer(
                          invertedFill: UIColors.bg,
                          polygons: [
                            Polygon(
                              points: [
                                LatLng(
                                  _vietnamMapBounds.south,
                                  _vietnamMapBounds.west,
                                ),
                                LatLng(
                                  _vietnamMapBounds.north,
                                  _vietnamMapBounds.west,
                                ),
                                LatLng(
                                  _vietnamMapBounds.north,
                                  _vietnamMapBounds.east,
                                ),
                                LatLng(
                                  _vietnamMapBounds.south,
                                  _vietnamMapBounds.east,
                                ),
                              ],
                              color: UIColors.transparent,
                              borderColor: UIColors.cardGlassBorder,
                              borderStrokeWidth: 1.5,
                            ),
                          ],
                        ),

                        if (state.pickedLocation != null &&
                            state.pickedReferenceLocation != null &&
                            (state.pickedDistanceKm ?? 0) >= 0.5)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [
                                  state.pickedLocation!,
                                  state.pickedReferenceLocation!,
                                ],
                                strokeWidth: 2.2,
                                color: UIColors.pinPurple.withOpacity(0.8),
                                pattern: StrokePattern.dashed(
                                  segments: const [6, 4],
                                ),
                                borderStrokeWidth: 1.0,
                                borderColor: UIColors.bg.withOpacity(0.6),
                              ),
                            ],
                          ),
                        if (circles.isNotEmpty) CircleLayer(circles: circles),
                        MarkerLayer(markers: markers),
                      ],
                    ),

                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: RepaintBoundary(
                        child: MapTopControlBar(
                          activeFilter: state.activeFilter,
                          onFilterChanged: (filter) =>
                              context.read<MapCubit>().setFilter(filter),
                          showHeatmap: state.showHeatmap,
                          onToggleHeatmap: () =>
                              context.read<MapCubit>().toggleHeatmap(),
                          selectedCityName: state.selectedCityName,
                          homeCityName: homeState.currentCity.name,
                          isHomeSelected: state.isHomeSelected,
                          selectedQuickCity: state.selectedQuickCity,
                          onSelectHomeCity: () =>
                              _syncWithHomeCity(homeState.currentCity),
                          quickCities: state.quickCities,
                          onSelectQuickCity: (target) =>
                              context.read<MapCubit>().selectQuickCity(target),
                          onSelectCity: (city) => context
                              .read<MapCubit>()
                              .selectLocationByCityName(city),
                          onSelectAllVietnam: () =>
                              context.read<MapCubit>().showAllVietnam(),
                        ),
                      ),
                    ),

                    if (state.activeLayer == MapLayerType.thermal &&
                        state.thermalNotice != null &&
                        state.thermalNotice!.isNotEmpty)
                      Positioned(
                        top: 165,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: UIColors.bg.withOpacity(0.82),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: state.isThermalFromCache
                                      ? UIColors.warning.withOpacity(0.6)
                                      : UIColors.secondary.withOpacity(0.6),
                                  width: 0.9,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: UIColors.black.withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcon(
                                    state.isThermalFromCache
                                        ? Icons.history_rounded
                                        : Icons.satellite_alt_rounded,
                                    size: 13,
                                    color: state.isThermalFromCache
                                        ? UIColors.warning
                                        : UIColors.secondary,
                                  ),
                                  const Gap(5),
                                  Flexible(
                                    child: AppText.regular(
                                      state.thermalNotice!,
                                      size: 10.5,
                                      color: UIColors.textPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      left: 14,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: RepaintBoundary(
                          child: MapZoomControls(
                            onZoomIn: _zoomIn,
                            onZoomOut: _zoomOut,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 14,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: RepaintBoundary(
                          child: MapSideControls(
                            hasPickedLocation: state.pickedLocation != null,
                            onCancelPicker: () {
                              context.read<MapCubit>().clearPickedLocation();
                              context
                                  .read<HomeDashboardCubit>()
                                  .revertToGpsOrHome();
                            },
                            onCurrentLocation: _moveToCurrentGpsLocation,
                            isHomeSelected: state.isHomeSelected,
                            onToggleLayer: () =>
                                _openLayerSelector(context, state.activeLayer),
                            activeLayer: state.activeLayer,
                            onWholeCountry: () {
                              context.read<MapCubit>().showAllVietnam();
                            },
                            isShowedAllVN: state.isShowedAllVN,
                          ),
                        ),
                      ),
                    ),

                    if (state.selectedStation != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        child: RepaintBoundary(
                          child: StationPreviewCard(
                            station: state.selectedStation!,
                            isLoading:
                                state.isPickingLocation ||
                                state.isLoadingPointData,
                            activeLayer: state.activeLayer,
                            onClose: () {
                              context.read<MapCubit>().clearSelection();
                              context
                                  .read<HomeDashboardCubit>()
                                  .revertToGpsOrHome();
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
