import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class WeatherHeroDetailCard extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherHeroDetailCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final weatherInfo = WeatherCodeHelper.getInfo(weather.weatherCode);
    final tempStr = weather.currentTemp.toStringAsFixed(0);
    final feelsLikeStr = weather.apparentTemp.toStringAsFixed(0);
    final windStr = weather.windSpeed.toStringAsFixed(1);
    final isRaining = weather.precipitation > 0;
    final int nextRainProb = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;

    final daily = weather.dailyForecast.isNotEmpty ? weather.dailyForecast.first : null;
    final highLowStr = daily != null
        ? 'Cao: ${daily.maxTemp.toStringAsFixed(0)}° • Thấp: ${daily.minTemp.toStringAsFixed(0)}°'
        : null;

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tempStr,
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.0,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: UIColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weatherInfo.description,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: weatherInfo.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cảm giác như: $feelsLikeStr°C${highLowStr != null ? ' • $highLowStr' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: UIColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: weatherInfo.color.withOpacity(0.15),
                  border: Border.all(
                    color: weatherInfo.color.withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: weatherInfo.color.withOpacity(0.25),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  weatherInfo.icon,
                  size: 36,
                  color: weatherInfo.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4-Pill Metric Grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    icon: Icons.water_drop_rounded,
                    iconColor: UIColors.secondary,
                    label: isRaining ? 'Lượng mưa' : 'Khả năng mưa',
                    value: isRaining
                        ? '${weather.precipitation.toStringAsFixed(1)} mm'
                        : '$nextRainProb%',
                  ),
                ),
                _buildMetricDivider(),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.air_rounded,
                    iconColor: UIColors.primary,
                    label: 'Tốc độ gió',
                    value: '$windStr km/h',
                  ),
                ),
                _buildMetricDivider(),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.opacity_rounded,
                    iconColor: const Color(0xFF67E8F9),
                    label: 'Độ ẩm',
                    value: '${weather.relativeHumidity}%',
                  ),
                ),
                _buildMetricDivider(),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: UIColors.warning,
                    label: 'Chỉ số UV',
                    value: weather.uvIndex.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.08),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: UIColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
