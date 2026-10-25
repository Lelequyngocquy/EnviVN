import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class TwentyFourHourTempChart extends StatelessWidget {
  final List<HourlyDetailsPoint> hourlyList;

  const TwentyFourHourTempChart({super.key, required this.hourlyList});

  @override
  Widget build(BuildContext context) {
    final points = hourlyList.take(24).toList();
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    double rawMin = points
        .map((p) => p.temperature)
        .reduce((a, b) => a < b ? a : b);
    double rawMax = points
        .map((p) => p.temperature)
        .reduce((a, b) => a > b ? a : b);

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

    for (int i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].temperature));
    }

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppText.bold(
                      'Biểu đồ nhiệt độ 24 giờ tới',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      size: 16,
                      color: UIColors.textPrimary,
                    ),
                    Gap(4),
                    AppText.regular(
                      'Đường cong nhiệt độ (°C) theo từng mốc giờ',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      size: 12,
                      color: UIColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              const AppStatusTag(
                label: '24 Giờ',
                color: UIColors.secondary,
                size: AppTagSize.medium,
              ),
            ],
          ),
          const Gap(24),
          SizedBox(
            height: 160,
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
                    color: UIColors.border.withOpacity(0.6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: interval,
                      getTitlesWidget: (val, _) => AppText.regular(
                        '${val.toInt()}°',
                        color: UIColors.textMuted,
                        size: 10,
                      ),
                    ),
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
                      interval: 4,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < points.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: AppText.regular(
                              DateFormat('HH:mm').format(points[idx].time),
                              color: UIColors.textSecondary,
                              size: 10,
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
                    color: UIColors.error,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                        radius: 3.5,
                        color: UIColors.error,
                        strokeWidth: 2,
                        strokeColor: UIColors.error,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          UIColors.error.withOpacity(0.35),
                          UIColors.error.withOpacity(0.0),
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
        ],
      ),
    );
  }
}
