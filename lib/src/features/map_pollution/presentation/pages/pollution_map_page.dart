import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/loading.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/station_pollution_entity.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_cubit.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_state.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class PollutionMapPage extends StatefulWidget {
  const PollutionMapPage({super.key});

  @override
  State<PollutionMapPage> createState() => _PollutionMapPageState();
}

class _PollutionMapPageState extends State<PollutionMapPage> {
  late final MapController _mapController;
  bool _showHeatmapCircles = true;
  String _filterType = 'all'; // all, good, warning

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    context.read<MapPollutionCubit>().fetchVietnamStations();
  }

  void _moveTo(double lat, double lon, double zoom) {
    _mapController.move(LatLng(lat, lon), zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.bg,
      body: BlocConsumer<MapPollutionCubit, MapPollutionState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.status == MapPollutionStatus.loading && state.stations.isEmpty) {
            return const LoadingWidget(message: 'Đang tải bản đồ & trạm quan trắc...');
          }

          final filteredStations = state.stations.where((st) {
            if (_filterType == 'good') return st.aqi <= 50;
            if (_filterType == 'warning') return st.aqi > 100;
            return true;
          }).toList();

          // Heatmap circles (concentric glowing rings)
          final circles = <CircleMarker>[];
          if (_showHeatmapCircles) {
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
            final info = AQIHelper.getAQIInfo(st.aqi);
            final isSelected = state.selectedStation?.id == st.id;

            return Marker(
              point: LatLng(st.latitude, st.longitude),
              width: 58,
              height: 58,
              child: GestureDetector(
                onTap: () {
                  context.read<MapPollutionCubit>().selectStation(st);
                  _moveTo(st.latitude, st.longitude, 12);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : info.color,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: info.color.withOpacity(0.6),
                            blurRadius: isSelected ? 12 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected ? info.color : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${st.aqi}',
                        style: TextStyle(
                          color: isSelected ? info.color : const Color(0xFF0B1220),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 16,
                      shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                    ),
                  ],
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              // Dark Mode Map (CartoDB Dark Matter tiles)
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(16.0544, 108.2022), // Vietnam center
                  initialZoom: 5.8,
                  minZoom: 4.5,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    userAgentPackageName: 'com.envivn.envivn',
                  ),
                  if (_showHeatmapCircles) CircleLayer(circles: circles),
                  MarkerLayer(markers: markers),
                ],
              ),

              // Top Liquid Glass Search & Quick City Panel
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    AppGlass(
                      borderRadius: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt_rounded,
                            color: UIColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterGlassChip(
                                    label: 'Tất cả',
                                    isActive: _filterType == 'all',
                                    onTap: () => setState(() => _filterType = 'all'),
                                  ),
                                  const SizedBox(width: 6),
                                  _FilterGlassChip(
                                    label: 'Tốt (<50)',
                                    isActive: _filterType == 'good',
                                    onTap: () => setState(() => _filterType = 'good'),
                                  ),
                                  const SizedBox(width: 6),
                                  _FilterGlassChip(
                                    label: 'Cảnh báo (>100)',
                                    isActive: _filterType == 'warning',
                                    onTap: () => setState(() => _filterType = 'warning'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _showHeatmapCircles ? Icons.blur_on_rounded : Icons.blur_off_rounded,
                              color: _showHeatmapCircles ? UIColors.primary : UIColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _showHeatmapCircles = !_showHeatmapCircles),
                            tooltip: 'Bật/Tắt Heatmap',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Jump City Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickCityGlassChip(label: 'Hà Nội', onTap: () => _moveTo(21.0285, 105.8542, 11)),
                          const SizedBox(width: 6),
                          _QuickCityGlassChip(label: 'Đà Nẵng', onTap: () => _moveTo(16.0544, 108.2022, 11)),
                          const SizedBox(width: 6),
                          _QuickCityGlassChip(label: 'TP. Hồ Chí Minh', onTap: () => _moveTo(10.7769, 106.7009, 11)),
                          const SizedBox(width: 6),
                          _QuickCityGlassChip(label: 'Hải Phòng', onTap: () => _moveTo(20.8449, 106.6881, 11)),
                          const SizedBox(width: 6),
                          _QuickCityGlassChip(label: 'Toàn quốc', onTap: () => _moveTo(16.0544, 108.2022, 5.8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Station Detail Preview Card in Liquid Glass (when a station is selected)
              if (state.selectedStation != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 96,
                  child: _buildStationBottomCard(context, state.selectedStation!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStationBottomCard(BuildContext context, StationPollutionEntity station) {
    final info = AQIHelper.getAQIInfo(station.aqi);

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: UIColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Khu vực: ${station.province}',
                    style: const TextStyle(fontSize: 12, color: UIColors.textSecondary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: UIColors.textSecondary, size: 20),
                onPressed: () => context.read<MapPollutionCubit>().clearSelection(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: info.color.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${station.aqi}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: info.color,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      info.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: info.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _MetricItem(label: 'PM2.5', value: '${station.pm25.toStringAsFixed(1)} µg/m³'),
                    const SizedBox(height: 6),
                    _MetricItem(label: 'PM10', value: '${station.pm10.toStringAsFixed(1)} µg/m³'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: UIColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  info.wearMask ? Icons.masks_rounded : Icons.directions_run_rounded,
                  color: info.color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.healthAdvice,
                    style: const TextStyle(fontSize: 11, color: UIColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: UIColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _FilterGlassChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterGlassChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? UIColors.primary : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? UIColors.primary : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF0B1220) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _QuickCityGlassChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickCityGlassChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppGlass(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
