import 'dart:ui';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/infrastructure/configs/env_config.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/core/presentation/widgets/loading.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/flood_blackspot.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/map_layer_type.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/station_pollution_entity.dart';
import 'package:envivn/src/features/map_pollution/infrastructure/models/thermal_hotspot_model.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_cubit.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_state.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/dropped_pin_marker_widget.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/map_layer_selector_sheet.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/map_side_controls.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/map_top_control_bar.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/station_marker_widget.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/station_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PollutionMapPage extends StatefulWidget {
  const PollutionMapPage({super.key});

  @override
  State<PollutionMapPage> createState() => _PollutionMapPageState();
}

class _PollutionMapPageState extends State<PollutionMapPage> {
  late final MapController _mapController;
  bool _isMapReady = false;
  double _currentZoom = 5.8;

  /// Giới hạn vùng hiển thị bản đồ theo đúng tỉ lệ màn hình smartphone (thon dài chiều dọc),
  /// bao trọn toàn bộ lãnh thổ, hải phận Việt Nam cùng 2 quần đảo Hoàng Sa và Trường Sa.
  /// Mở rộng chiều cao cả 2 đầu Bắc (vượt qua Lũng Cú) và Nam (vượt qua Trường Sa & Cà Mau)
  /// để khi xem "Toàn quốc", bản đồ phủ kín hoàn toàn chiều dọc màn hình điện thoại mà không bị hụt.
  static final LatLngBounds _vietnamMapBounds = LatLngBounds(
    const LatLng(
      2.5,
      101.8,
    ), // Góc Tây Nam (mở rộng sâu về phía nam qua vùng biển Trường Sa)
    const LatLng(
      28.0,
      117.2,
    ), // Góc Đông Bắc (mở rộng cao về phía bắc qua vùng biên giới Lũng Cú)
  );

  double _calculateMarkerScale(double zoom) {
    // Thu nhỏ hài hòa theo zoom:
    // Zoom <= 5.0 (toàn quốc thu nhỏ): scale = 0.55
    // Zoom >= 12.0 (nội thành/đô thị): scale = 1.0 (phóng to nhẹ tới 1.15 ở zoom cực cận)
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

    // Khởi tạo trạm bản đồ với vị trí hiện tại của người dùng nếu có
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mapCubit = context.read<MapPollutionCubit>();
      final homeCubit = context.read<HomeDashboardCubit>();

      // Xác định thành phố ban đầu hiệu quả:
      // Nếu HomeDashboardCubit chưa hoàn tất init (vẫn đang giữ defaultCity Hà Nội),
      // ưu tiên đọc trực tiếp thành phố người dùng đã lưu từ LocalStorage.
      CityEntity effectiveCity = homeCubit.state.currentCity;
      if (effectiveCity == CityEntity.defaultCity) {
        final saved = homeCubit.storage.getSelectedCity();
        if (saved != null) {
          effectiveCity = CityEntity(
            name: saved['name']?.toString() ?? effectiveCity.name,
            province: saved['name']?.toString() ?? effectiveCity.province,
            latitude:
                double.tryParse(saved['lat']?.toString() ?? '') ??
                effectiveCity.latitude,
            longitude:
                double.tryParse(saved['lon']?.toString() ?? '') ??
                effectiveCity.longitude,
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
        // Trạm quan trắc đã có sẵn trong state (khi hot reload hoặc quay lại tab):
        // Di chuyển camera đến đúng vị trí targetLocation đang được chọn trong state
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

  void _syncWithHomeCity(CityEntity city) {
    final mapCubit = context.read<MapPollutionCubit>();
    mapCubit.selectHomeLocation(
      lat: city.latitude,
      lon: city.longitude,
      zoom: 12.0,
      label: city.name,
    );
    _safeMove(LatLng(city.latitude, city.longitude), 12.0);
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
        context.read<MapPollutionCubit>().switchMapLayer(newLayer);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeDashboardCubit, HomeDashboardState>(
      listenWhen: (prev, curr) {
        // Tab 2 là tab Bản đồ (IndexedStack index 2)
        final switchedToMap = prev.currentTab != 2 && curr.currentTab == 2;
        final cityChanged = prev.currentCity != curr.currentCity;
        final permissionChanged =
            prev.isLocationPermissionGranted !=
            curr.isLocationPermissionGranted;
        return (switchedToMap && curr.hasPendingMapSync) ||
            (curr.currentTab == 2 && (cityChanged || permissionChanged));
      },
      listener: (context, homeState) {
        final mapCubit = context.read<MapPollutionCubit>();
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

        // Chỉ đồng bộ di chuyển bản đồ theo vị trí Home nếu người dùng đang ở chế độ xem Home,
        // hoặc chưa chọn thành phố nào trên bản đồ, tránh ghi đè lên thành phố người dùng vừa chọn xem (như Hải Phòng)
        if (mapCubit.state.isHomeSelected ||
            mapCubit.state.selectedQuickCity == null ||
            homeState.hasPendingMapSync) {
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
            return BlocConsumer<MapPollutionCubit, MapPollutionState>(
              listenWhen: (prev, curr) =>
                  curr.targetLocation != null &&
                  (prev.targetLocation != curr.targetLocation ||
                      prev.targetZoom != curr.targetZoom),
              listener: (context, state) {
                if (state.targetLocation != null && state.targetZoom != null) {
                  _safeMove(state.targetLocation!, state.targetZoom!);
                }
              },
              builder: (context, state) {
                if (state.status == MapPollutionStatus.loading &&
                    state.stations.isEmpty) {
                  return const LoadingWidget(
                    message: 'Đang tải bản đồ & trạm quan trắc...',
                  );
                }

                final filteredStations = state.filteredStations;

                // User GPS location (chỉ hiển thị khi đã cấp quyền)
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

                // 1. User GPS Accuracy circle
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

                // 2. Picked location radar pulse circles (Màu tím pinPurple đồng bộ)
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

                // 3. Heatmap circles thích ứng theo activeLayer và co giãn tỉ lệ theo zoom
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

                // Pins / Markers trạm quan trắc (thích ứng 4 loại Map và co giãn tỉ lệ theo zoom)
                // Đặt chính giữa tâm tọa độ trạm và CircleMarker bán kính ảnh hưởng
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
                          context.read<MapPollutionCubit>().selectStation(st);
                        },
                      ),
                    ),
                  );
                }).toList();

                // 4. Các marker phụ trợ chuyên biệt cho từng Layer
                if (state.activeLayer == MapLayerType.thermal) {
                  // Điểm cháy vệ tinh NASA NOAA-20 / Điểm nhiệt sinh khối
                  final thermalSpots = state.thermalHotspots.isNotEmpty
                      ? state.thermalHotspots
                      : ThermalHotspotModel.sampleHotspots;
                  for (final spot in thermalSpots) {
                    final isSelected = state.selectedStation?.id == spot.id;
                    final isActive = spot.isActiveFire;

                    // Phân biệt visual giữa ĐANG CHÁY (Đỏ rực, pulse) và VÙNG THƯỜNG XẢY RA CHÁY (Vàng cam cảnh báo)
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
                                final spotStation = StationPollutionEntity(
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
                                  // Nếu là điểm đang cháy: gán nhiệt phát xạ của đám cháy
                                  // Nếu là vùng thường xảy ra cháy: để null để Cubit nạp nhiệt độ thời tiết thực tế!
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
                                context.read<MapPollutionCubit>().selectStation(
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
                  // Điểm cảnh báo nguy cơ ngập úng đô thị (Điểm đen thường ngập khi mưa lớn)
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
                                final spotStation = StationPollutionEntity(
                                  id: spot.id,
                                  name: spot.name,
                                  province: spot.province,
                                  latitude: spot.latitude,
                                  longitude: spot.longitude,
                                  aqi: 35,
                                  pm25: 10.0,
                                  pm10: 18.0,
                                  updatedAt: DateTime.now(),
                                  // Để null để Cubit nạp thông số thời tiết & lượng mưa THỰC TẾ từ Open-Meteo
                                  isFloodBlackspot: true,
                                  historicalDepthCm: spot.averageDepthCm,
                                  floodTriggerCondition: spot.triggerCondition,
                                  floodProneTime: spot.proneTime,
                                  spotDescription: spot.description,
                                );
                                context.read<MapPollutionCubit>().selectStation(
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

                // 5. User GPS blue dot marker
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

                // 6. Custom Dropped Pin Marker at picked location (Tím, chính giữa CircleMarker tâm ghim)
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
                              context
                                  .read<MapPollutionCubit>()
                                  .pickCustomLocation(state.pickedLocation!);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // 7. Nhãn khẳng định chủ quyền Quần đảo Hoàng Sa & Trường Sa (Việt Nam)
                // Hiển thị text nhỏ tinh tế, đặt lùi xuống phía nam dưới điểm ghim của đảo,
                // nền làm mờ trong suốt (frosted glass) để tránh đè lấp hoặc che khuất bản đồ
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
                                    const SizedBox(height: 1),
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
                    // Dark Mode Map (OpenStreetMap with flutter_map Dark Mode Filter)
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        backgroundColor: UIColors.bg,
                        initialCenter:
                            context
                                .read<MapPollutionCubit>()
                                .state
                                .targetLocation ??
                            const LatLng(16.0544, 108.2022),
                        initialZoom:
                            context
                                .read<MapPollutionCubit>()
                                .state
                                .targetZoom ??
                            5.8,
                        minZoom: 4.6,
                        maxZoom: 18.0,
                        cameraConstraint: CameraConstraint.containCenter(
                          bounds: _vietnamMapBounds,
                        ),
                        onMapReady: () {
                          _isMapReady = true;
                          _currentZoom = _mapController.camera.zoom;
                          final curState = context
                              .read<MapPollutionCubit>()
                              .state;
                          if (curState.targetLocation != null &&
                              curState.targetZoom != null) {
                            _safeMove(
                              curState.targetLocation!,
                              curState.targetZoom!,
                            );
                          }
                        },
                        onPositionChanged: (camera, hasGesture) {
                          if ((camera.zoom - _currentZoom).abs() >= 0.06) {
                            setState(() {
                              _currentZoom = camera.zoom;
                            });
                          }
                        },
                        onTap: (tapPosition, point) {
                          // Chỉ cho phép ghim điểm trong phạm vi lãnh thổ & hải phận Việt Nam
                          if (_vietnamMapBounds.contains(point)) {
                            context
                                .read<MapPollutionCubit>()
                                .pickCustomLocation(point);
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: EnvConfig.osmTileUrl,
                          userAgentPackageName: EnvConfig.mapUserAgent,
                          tileBuilder: darkModeTileBuilder,
                          tileBounds: _vietnamMapBounds,
                        ),
                        // Lớp mặt nạ màu xanh mực tối bao ngoài khung hình chữ nhật Việt Nam
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
                        // Tia định vị nét đứt kết nối từ Điểm ghim đến Trạm/Thành phố tham chiếu
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

                    // Top Liquid Glass Search & Quick City Panel
                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: MapTopControlBar(
                        activeFilter: state.activeFilter,
                        onFilterChanged: (filter) =>
                            context.read<MapPollutionCubit>().setFilter(filter),
                        showHeatmap: state.showHeatmap,
                        onToggleHeatmap: () =>
                            context.read<MapPollutionCubit>().toggleHeatmap(),
                        selectedCityName: state.selectedCityName,
                        homeCityName: homeState.currentCity.name,
                        isHomeSelected: state.isHomeSelected,
                        selectedQuickCity: state.selectedQuickCity,
                        onSelectHomeCity: () =>
                            _syncWithHomeCity(homeState.currentCity),
                        quickCities: state.quickCities,
                        onSelectQuickCity: (target) => context
                            .read<MapPollutionCubit>()
                            .selectQuickCity(target),
                        onSelectCity: (city) => context
                            .read<MapPollutionCubit>()
                            .selectLocationByCityName(city),
                        onSelectAllVietnam: () =>
                            context.read<MapPollutionCubit>().showAllVietnam(),
                      ),
                    ),

                    // Top Satellite Data Status Badge (Chỉ hiển thị ở layer Nhiệt độ & Điểm cháy khi có thông báo cache/vệ tinh)
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
                                  const SizedBox(width: 5),
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

                    // Center-Right Floating Side Controls (Layer Switch Button, Zoom Bar & Cancel Picker)
                    Positioned(
                      right: 14,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: MapSideControls(
                          onZoomIn: _zoomIn,
                          onZoomOut: _zoomOut,
                          hasPickedLocation: state.pickedLocation != null,
                          onCancelPicker: () {
                            context
                                .read<MapPollutionCubit>()
                                .clearPickedLocation();
                          },
                          onToggleLayer: () =>
                              _openLayerSelector(context, state.activeLayer),
                          activeLayer: state.activeLayer,
                          onWholeCountry: () {
                            context.read<MapPollutionCubit>().showAllVietnam();
                          },
                          isShowedAllVN: state.isShowedAllVN,
                        ),
                      ),
                    ),

                    // Bottom Station Detail Preview Card in Liquid Glass (thích ứng theo activeLayer)
                    if (state.selectedStation != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        child: StationPreviewCard(
                          station: state.selectedStation!,
                          isLoading:
                              state.isPickingLocation ||
                              state.isLoadingPointData,
                          activeLayer: state.activeLayer,
                          onClose: () => context
                              .read<MapPollutionCubit>()
                              .clearSelection(),
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
