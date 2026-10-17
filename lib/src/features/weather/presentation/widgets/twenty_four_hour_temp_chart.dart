import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class TwentyFourHourTempChart extends StatelessWidget {
  final List<HourlyWeatherPoint> hourlyList;

  const TwentyFourHourTempChart({
    super.key,
    required this.hourlyList,
  });

  @override
  Widget build(BuildContext context) {
    final points = hourlyList.take(24).toList();
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    double minTemp = points.map((p) => p.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = points.map((p) => p.temperature).reduce((a, b) => a > b ? a : b);
    minTemp = (minTemp - 2).floorToDouble();
    maxTemp = (maxTemp + 2).ceilToDouble();
    if (minTemp >= maxTemp) {
      minTemp -= 2;
      maxTemp += 2;
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
                    Text(
                      'Biểu đồ nhiệt độ 24 giờ tới',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UIColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Đường cong nhiệt độ (°C) theo từng mốc giờ',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: UIColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const AppStatusTag(
                label: '24 Giờ',
                color: UIColors.secondary,
                size: AppTagSize.medium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minTemp,
                maxY: maxTemp,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: ((maxTemp - minTemp) / 3).clamp(1.0, 10.0),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: UIColors.border.withOpacity(0.6),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: ((maxTemp - minTemp) / 3).clamp(1.0, 10.0),
                      getTitlesWidget: (val, _) => Text(
                        '${val.toInt()}°',
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
                      interval: 4,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < points.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('HH:mm').format(points[idx].time),
                              style: const TextStyle(color: UIColors.textSecondary, fontSize: 10),
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
