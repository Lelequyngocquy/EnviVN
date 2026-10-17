import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../common/constants/colors.dart';
import '../../domain/entities/weather_entity.dart';

class HourlyTemperatureChart extends StatelessWidget {
  final List<HourlyWeatherPoint> hourlyData;

  const HourlyTemperatureChart({
    super.key,
    required this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = hourlyData.take(12).toList(); // Show next 12 hours for clarity
    final spots = <FlSpot>[];
    double minTemp = 100.0;
    double maxTemp = -50.0;

    for (int i = 0; i < points.length; i++) {
      final t = points[i].temperature;
      spots.add(FlSpot(i.toDouble(), t));
      if (t < minTemp) minTemp = t;
      if (t > maxTemp) maxTemp = t;
    }

    // Add padding to bounds
    minTemp = (minTemp - 2).floorToDouble();
    maxTemp = (maxTemp + 2).ceilToDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UIColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: UIColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Biểu đồ nhiệt độ (12h tới)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: UIColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: minTemp,
                maxY: maxTemp,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 4,
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
                          child: Text(
                            DateFormat('HH:mm').format(time),
                            style: const TextStyle(
                              color: UIColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
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
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.white,
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
          const SizedBox(height: 12),
          // Horizontal list of hours with weather icons
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: points.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final pt = points[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(pt.time),
                      style: const TextStyle(fontSize: 11, color: UIColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pt.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: UIColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop, size: 10, color: UIColors.secondary),
                        Text(
                          '${pt.humidity}%',
                          style: const TextStyle(fontSize: 10, color: UIColors.textSecondary),
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
