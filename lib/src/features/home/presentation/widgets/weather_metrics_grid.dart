import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final WeatherEntity weather;
  final void Function(String metricType)? onMetricTap;

  const WeatherMetricsGrid({
    super.key,
    required this.weather,
    this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    final tempStr = weather.currentTemp > 0 ? weather.currentTemp.toStringAsFixed(0) : '28';
    final feelsLikeStr = weather.apparentTemp > 0 ? weather.apparentTemp.toStringAsFixed(0) : '30';
    final humidityVal = weather.relativeHumidity > 0 ? weather.relativeHumidity : 78;
    final windSpeedStr = weather.windSpeed > 0 ? weather.windSpeed.toStringAsFixed(1) : '12.0';
    final uvIndexStr = weather.uvIndex > 0 ? weather.uvIndex.toStringAsFixed(1) : '4.2';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        MetricGlassItem(
          icon: Icons.thermostat_rounded,
          iconColor: Colors.orangeAccent,
          label: 'Nhiệt độ',
          value: '$tempStr°C',
          sub: 'Cảm giác như: $feelsLikeStr°C',
          onTap: onMetricTap != null ? () => onMetricTap!('temperature') : null,
        ),
        MetricGlassItem(
          icon: Icons.water_drop_rounded,
          iconColor: UIColors.secondary,
          label: 'Độ ẩm',
          value: '$humidityVal%',
          sub: humidityVal > 80 ? 'Ẩm cao' : 'Thoáng đãng',
          onTap: onMetricTap != null ? () => onMetricTap!('humidity') : null,
        ),
        MetricGlassItem(
          icon: Icons.air_rounded,
          iconColor: UIColors.primary,
          label: 'Tốc độ gió',
          value: '$windSpeedStr km/h',
          sub: 'Gió nhẹ',
          onTap: onMetricTap != null ? () => onMetricTap!('wind') : null,
        ),
        MetricGlassItem(
          icon: Icons.wb_sunny_rounded,
          iconColor: UIColors.warning,
          label: 'Chỉ số UV',
          value: uvIndexStr,
          sub: weather.uvIndex >= 6 ? 'Cần che chắn' : 'Mức an toàn',
          onTap: onMetricTap != null ? () => onMetricTap!('uv') : null,
        ),
      ],
    );
  }
}

class MetricGlassItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;
  final VoidCallback? onTap;

  const MetricGlassItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppGlass(
        borderRadius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AppIcon(icon, color: iconColor, size: 18),
                const SizedBox(width: 6),
                AppText.regular(
                  label,
                  size: 12,
                  color: UIColors.textSecondary,
                ),
              ],
            ),
            AppText.bold(
              value,
              size: 22,
              color: Colors.white,
            ),
            AppText.regular(
              sub,
              size: 10,
              color: UIColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
