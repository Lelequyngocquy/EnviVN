import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class Aqi24hChartCard extends StatelessWidget {
  final List<dynamic> hourlyPoints;

  const Aqi24hChartCard({
    super.key,
    required this.hourlyPoints,
  });

  @override
  Widget build(BuildContext context) {
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
                      'Diễn biến nồng độ 24 giờ qua',
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
                      'Chỉ số AQI theo từng khung giờ',
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
                label: 'AQI US',
                color: UIColors.primary,
                size: AppTagSize.medium,
              ),
            ],
          ),
          const SizedBox(height: 28),
          _build24hChart(hourlyPoints),
        ],
      ),
    );
  }

  Widget _build24hChart(List<dynamic> points) {
    final spots = <FlSpot>[];
    if (points.isNotEmpty) {
      final step = (points.length / 9).clamp(1, 10).toInt();
      for (int i = 0; i < points.length && spots.length < 9; i += step) {
        final p = points[i];
        final aqiVal = (p.aqi as int? ?? 50).toDouble();
        spots.add(FlSpot(spots.length.toDouble(), aqiVal));
      }
    } else {
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
