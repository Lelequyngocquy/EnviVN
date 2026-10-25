import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../common/constants/colors.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../domain/entities/details_entity.dart';

class HourlyTemperatureChart extends StatelessWidget {
  final List<HourlyDetailsPoint> hourlyData;

  const HourlyTemperatureChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = hourlyData.take(12).toList();
    final spots = <FlSpot>[];
    double rawMin = 100.0;
    double rawMax = -50.0;

    for (int i = 0; i < points.length; i++) {
      final t = points[i].temperature;
      spots.add(FlSpot(i.toDouble(), t));
      if (t < rawMin) rawMin = t;
      if (t > rawMax) rawMax = t;
    }

    final diff = rawMax - rawMin;
    final double interval;
    if (diff <= 6) {
      interval = 2.0;
    } else if (diff <= 12) {
      interval = 3.0;
    } else if (diff <= 20) {
      interval = 5.0;
    } else {
      interval = 10.0;
    }

    double minTemp = (rawMin / interval).floorToDouble() * interval;
    if (rawMin - minTemp < interval * 0.4) {
      minTemp -= interval;
    }
    double maxTemp = (rawMax / interval).ceilToDouble() * interval;
    if (maxTemp - rawMax < interval * 0.4) {
      maxTemp += interval;
    }
    if (minTemp >= maxTemp) {
      minTemp -= interval;
      maxTemp += interval;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UIColors.border),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              AppIcon(
                Icons.show_chart_rounded,
                color: UIColors.secondary,
                size: 20,
              ),
              Gap(8),
              AppText.bold(
                'Biểu đồ nhiệt độ (12h tới)',
                size: 14,
                color: UIColors.textPrimary,
              ),
            ],
          ),
          const Gap(24),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.all(),
                minY: minTemp,
                maxY: maxTemp,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: UIColors.border.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final time = points[index].time;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: AppText.medium(
                            DateFormat('HH:mm').format(time),
                            color: UIColors.textSecondary,
                            size: 10,
                          ),
                        );
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
                    color: UIColors.secondary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 3.5,
                            color: UIColors.white,
                            strokeWidth: 2,
                            strokeColor: UIColors.secondary,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          UIColors.secondary.withOpacity(0.25),
                          UIColors.secondary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(12),

          SizedBox(
            height: 70,
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: points.length,
              separatorBuilder: (_, _) => const Gap(12),
              itemBuilder: (context, index) {
                final pt = points[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.regular(
                      DateFormat('HH:mm').format(pt.time),
                      size: 11,
                      color: UIColors.textSecondary,
                    ),
                    const Gap(4),
                    AppText.bold(
                      '${pt.temperature.toStringAsFixed(0)}°',
                      size: 13,
                      color: UIColors.textPrimary,
                    ),
                    const Gap(2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppIcon(
                          Icons.water_drop,
                          size: 10,
                          color: UIColors.secondary,
                        ),
                        AppText.regular(
                          '${pt.humidity}%',
                          size: 10,
                          color: UIColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
