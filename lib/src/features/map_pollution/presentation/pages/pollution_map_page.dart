import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/infrastructure/configs/env_config.dart';
import 'package:envivn/src/core/presentation/widgets/loading.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_cubit.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_state.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/map_top_control_bar.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/station_marker_widget.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/station_preview_card.dart';

class PollutionMapPage extends StatefulWidget {
  const PollutionMapPage({super.key});

  @override
  State<PollutionMapPage> createState() => _PollutionMapPageState();
}

class _PollutionMapPageState extends State<PollutionMapPage> {
  late final MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Initialize map stations with current city from HomeDashboard if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mapCubit = context.read<MapPollutionCubit>();
      final homeCubit = context.read<HomeDashboardCubit>();
      final initialCity = homeCubit.state.currentCity;

      if (initialCity.isGps) {
        mapCubit.setUserGpsLocation(
          LatLng(initialCity.latitude, initialCity.longitude),
        );
      }
      mapCubit.loadUserGpsLocation(
        fallbackCoords: initialCity.isGps
            ? LatLng(initialCity.latitude, initialCity.longitude)
            : null,
      );

      if (mapCubit.state.stations.isEmpty) {
        mapCubit
            .fetchVietnamStations(
          initialCity: initialCity.name,
          initialCoords: LatLng(initialCity.latitude, initialCity.longitude),
        )
            .then((_) {
          if (mounted && homeCubit.state.hasPendingMapSync) {
            _syncWithHomeCity(initialCity);
            homeCubit.consumeMapSync();
          }
        });
      } else if (homeCubit.state.hasPendingMapSync) {
        _syncWithHomeCity(initialCity);
        homeCubit.consumeMapSync();
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
    } catch (e) {
      debugPrint('⚠️ [MapController.move] Bỏ qua di chuyển: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeDashboardCubit, HomeDashboardState>(
      listenWhen: (prev, curr) {
        final switchedToMap = prev.currentTab != 1 && curr.currentTab == 1;
        final cityChanged = prev.currentCity != curr.currentCity;
        return (switchedToMap && curr.hasPendingMapSync) ||
            (curr.currentTab == 1 && cityChanged);
      },
      listener: (context, homeState) {
        if (homeState.currentCity.isGps) {
          context.read<MapPollutionCubit>().setUserGpsLocation(
            LatLng(homeState.currentCity.latitude, homeState.currentCity.longitude),
          );
        }
        _syncWithHomeCity(homeState.currentCity);
        context.read<HomeDashboardCubit>().consumeMapSync();
      },
      child: Scaffold(
        backgroundColor: UIColors.bg,
        body: BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
          buildWhen: (prev, curr) => prev.currentCity != curr.currentCity,
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
                      message: 'Đang tải bản đồ & trạm quan trắc...');
                }

                final filteredStations = state.filteredStations;

                // User GPS location (always available if state or home has it)
                final userGps = state.userGpsLocation ??
                    (homeState.currentCity.isGps
                        ? LatLng(homeState.currentCity.latitude, homeState.currentCity.longitude)
                        : null);

                // Heatmap & GPS Accuracy Halo Circles
                final circles = <CircleMarker>[];

                // 1. Always show user GPS location accuracy ring if GPS is known
                if (userGps != null) {
                  circles.add(
                    CircleMarker(
                      point: userGps,
                      radius: 22,
                      useRadiusInMeter: false,
                      color: const Color(0xFF2979FF).withOpacity(0.20),
                      borderColor: const Color(0xFF2979FF).withOpacity(0.60),
                      borderStrokeWidth: 1.5,
                    ),
                  );
                }

                // 2. Heatmap circles
                if (state.showHeatmap) {
                  for (final st in filteredStations) {
                    final info = AQIHelper.getAQIInfo(st.aqi);
                    circles.add(
                      CircleMarker(
                        point: LatLng(st.latitude, st.longitude),
                        radius: 46,
                        useRadiusInMeter: false,
                        color: info.color.withOpacity(0.18),
                        borderColor: info.color.withOpacity(0.35),
                        borderStrokeWidth: 1.5,
                      ),
                    );
                    circles.add(
                      CircleMarker(
                        point: LatLng(st.latitude, st.longitude),
                        radius: 24,
                        useRadiusInMeter: false,
                        color: info.color.withOpacity(0.3),
                        borderColor: Colors.transparent,
                      ),
                    );
                  }
                }

                // Pins / Markers
                final markers = filteredStations.map((st) {
                  final isSelected = state.selectedStation?.id == st.id;
                  return Marker(
                    point: LatLng(st.latitude, st.longitude),
                    width: 58,
                    height: 58,
                    child: StationMarkerWidget(
                      station: st,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<MapPollutionCubit>().selectStation(st);
                      },
                    ),
                  );
                }).toList();

                // 3. Always add user GPS blue dot marker on the map
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
                              color: const Color(0xFF2979FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2979FF).withOpacity(0.7),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
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

                return Stack(
                  children: [
                    // Dark Mode Map (OpenStreetMap with flutter_map Dark Mode Filter)
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            const LatLng(16.0544, 108.2022), // Vietnam center
                        initialZoom: 5.8,
                        minZoom: 4.5,
                        maxZoom: 18.0,
                        onMapReady: () {
                          _isMapReady = true;
                          final curState =
                              context.read<MapPollutionCubit>().state;
                          if (curState.targetLocation != null &&
                              curState.targetZoom != null) {
                            _safeMove(
                                curState.targetLocation!, curState.targetZoom!);
                          }
                        },
                        onTap: (tapPosition, point) {
                          // Tapping anywhere on the map outside markers clears selection
                          context.read<MapPollutionCubit>().clearSelection();
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: EnvConfig.osmTileUrl,
                          userAgentPackageName: EnvConfig.mapUserAgent,
                          tileBuilder: darkModeTileBuilder,
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

                    // Bottom Station Detail Preview Card in Liquid Glass (Compact with Weather)
                    if (state.selectedStation != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        child: StationPreviewCard(
                          station: state.selectedStation!,
                          onClose: () =>
                              context.read<MapPollutionCubit>().clearSelection(),
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

