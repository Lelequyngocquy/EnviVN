import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_cubit.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_state.dart';

class TwentyFourHourDetailPage extends StatelessWidget {
  const TwentyFourHourDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateHelper.formatVietnameseFull(now);

    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: BlocBuilder<AirQualityCubit, AirQualityState>(
          builder: (context, aqiState) {
            return BlocBuilder<WeatherCubit, WeatherState>(
              builder: (context, weatherState) {
                final aqi = aqiState.airQuality;
                final hourlyPoints = aqi.hourlyAqi;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          AppGlass(
                            borderRadius: 14,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  context.read<HomeDashboardCubit>().setTab(0);
                                }
                              },
                              tooltip: 'Quay lại',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chi tiết 24 giờ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: UIColors.textPrimary,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: UIColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2x2 Pollutant Glass Cards (matching 04 · Chi tiết 24 giờ.svg)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.35,
                        children: [
                          _GlassPollutantCard(
                            label: 'PM2.5',
                            value: aqi.pm25 > 0 ? aqi.pm25.toStringAsFixed(1) : '24.5',
                            unit: 'µg/m³',
                            progress: ((aqi.pm25 > 0 ? aqi.pm25 : 24.5) / 75.0).clamp(0.0, 1.0),
                            progressColor: (aqi.pm25 > 35) ? UIColors.aqiUnhealthySensitive : UIColors.aqiGood,
                          ),
                          _GlassPollutantCard(
                            label: 'PM10',
                            value: aqi.pm10 > 0 ? aqi.pm10.toStringAsFixed(1) : '48.0',
                            unit: 'µg/m³',
                            progress: ((aqi.pm10 > 0 ? aqi.pm10 : 48.0) / 100.0).clamp(0.0, 1.0),
                            progressColor: (aqi.pm10 > 50) ? UIColors.aqiModerate : UIColors.aqiGood,
                          ),
                          _GlassPollutantCard(
                            label: 'O₃ (Ozone)',
                            value: aqi.ozone > 0 ? aqi.ozone.toStringAsFixed(1) : '38.2',
                            unit: 'µg/m³',
                            progress: ((aqi.ozone > 0 ? aqi.ozone : 38.2) / 120.0).clamp(0.0, 1.0),
                            progressColor: UIColors.secondary,
                          ),
                          _GlassPollutantCard(
                            label: 'NO₂',
                            value: aqi.nitrogenDioxide > 0 ? aqi.nitrogenDioxide.toStringAsFixed(1) : '19.5',
                            unit: 'µg/m³',
                            progress: ((aqi.nitrogenDioxide > 0 ? aqi.nitrogenDioxide : 19.5) / 60.0).clamp(0.0, 1.0),
                            progressColor: UIColors.aqiGood,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 24h Detailed Trend Chart (matching #chart in 04 svg)
                      AppGlass(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Diễn biến nồng độ 24 giờ qua',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: UIColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Chỉ số AQI theo từng khung giờ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: UIColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: UIColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: UIColors.primary.withOpacity(0.4)),
                                  ),
                                  child: const Text(
                                    'AQI US',
                                    style: TextStyle(
                                      color: UIColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _build24hChart(hourlyPoints),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Health Advisory Card (matching #health in 04 svg)
                      AppGlass(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: UIColors.warning.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: UIColors.warning,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Khuyến cáo sức khỏe 24h',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: UIColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Khung giờ 14:00 - 18:00 chất lượng không khí đạt trạng thái trong lành nhất trong ngày, rất thích hợp cho chạy bộ, đạp xe và thông gió nhà cửa.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: UIColors.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _build24hChart(List<dynamic> points) {
    final spots = <FlSpot>[];
    // If real hourly points available, take 9 samples across 24 hours
    if (points.isNotEmpty) {
      final step = (points.length / 9).clamp(1, 10).toInt();
      for (int i = 0; i < points.length && spots.length < 9; i += step) {
        final p = points[i];
        final aqiVal = (p.aqi as int? ?? 50).toDouble();
        spots.add(FlSpot(spots.length.toDouble(), aqiVal));
      }
    } else {
      // Default sample curve matching SVG 04
      const defaultVals = [52.0, 58.0, 64.0, 52.0, 78.0, 94.0, 84.0, 72.0, 65.0];
      for (int i = 0; i < defaultVals.length; i++) {
        spots.add(FlSpot(i.toDouble(), defaultVals[i]));
      }
    }

    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minY: 30,
          maxY: 120,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 30,
            getDrawingHorizontalLine: (value) => FlLine(
              color: UIColors.border.withOpacity(0.6),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 30,
                getTitlesWidget: (val, _) => Text(
                  val.toInt().toString(),
                  style: const TextStyle(color: UIColors.textMuted, fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 2,
                getTitlesWidget: (val, _) {
                  final hours = ['00h', '06h', '12h', '18h', '24h'];
                  final idx = (val / 2).toInt();
                  if (idx >= 0 && idx < hours.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        hours[idx],
                        style: const TextStyle(color: UIColors.textSecondary, fontSize: 11),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: UIColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 4,
                  color: UIColors.bg,
                  strokeWidth: 2.5,
                  strokeColor: UIColors.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    UIColors.primary.withOpacity(0.35),
                    UIColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPollutantCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double progress;
  final Color progressColor;

  const _GlassPollutantCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlass(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: UIColors.textSecondary,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: UIColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: UIColors.textMuted,
                ),
              ),
            ],
          ),
          // Progress Bar (matching pb-t and pb-f in 04 svg)
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: UIColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
