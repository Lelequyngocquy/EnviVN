import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class DetailsHeroDetailCard extends StatelessWidget {
  final DetailsEntity details;

  const DetailsHeroDetailCard({
    super.key,
    required this.details,
  });

  // Backward compatible constructor
  const DetailsHeroDetailCard.fromWeather({
    super.key,
    required DetailsEntity weather,
  }) : details = weather;

  @override
  Widget build(BuildContext context) {
    final weather = details;
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
                        AppText.extraBold(
                          tempStr,
                          size: 50,
                          color: UIColors.white,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                        const Gap(4),
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: AppText.bold(
                            '°C',
                            size: 22,
                            color: UIColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    AppText.bold(
                      weatherInfo.description,
                      size: 15,
                      color: weatherInfo.color,
                    ),
                    const Gap(4),
                    AppText.medium(
                      'Cảm giác như: $feelsLikeStr°C${highLowStr != null ? ' • $highLowStr' : ''}',
                      size: 12,
                      color: UIColors.textSecondary,
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
                child: AppIcon(
                  weatherInfo.icon,
                  size: 36,
                  color: weatherInfo.color,
                ),
              ),
            ],
          ),
          const Gap(16),

          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: UIColors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: UIColors.white.withOpacity(0.08),
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
                    iconColor: UIColors.secondary,
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
      color: UIColors.white.withOpacity(0.08),
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
        AppIcon(icon, size: 14, color: iconColor),
        const Gap(3),
        AppText.bold(
          value,
          size: 12,
          color: UIColors.white,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(1),
        AppText.medium(
          label,
          size: 9.5,
          color: UIColors.textSecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Backward-compatibility alias
typedef WeatherHeroDetailCard = DetailsHeroDetailCard;

