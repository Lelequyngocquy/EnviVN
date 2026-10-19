import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/station_pollution_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class StationPreviewCard extends StatelessWidget {
  final StationPollutionEntity station;
  final VoidCallback onClose;

  const StationPreviewCard({
    super.key,
    required this.station,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final aqiInfo = AQIHelper.getAQIInfo(station.aqi);
    final weatherInfo = WeatherCodeHelper.getInfo(station.weatherCode);
    final temp = station.temperature ?? 26.0;
    final humidity = station.humidity ?? 70;
    final wind = station.windSpeed ?? 10.0;

    return AppGlass(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top row: Station Title, Province & Compact Close Button
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: AppText.bold(
                        station.name,
                        size: 14,
                        color: UIColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppText.regular(
                      '• ${station.province}',
                      size: 12,
                      color: UIColors.textSecondary,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon(
                    Icons.close_rounded,
                    color: UIColors.textSecondary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Compact Info Grid: [AQI Badge] | [PM2.5 / PM10] | Divider | [Weather info]
          Row(
            children: [
              // AQI Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: aqiInfo.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: aqiInfo.color.withOpacity(0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.extraBold(
                      '${station.aqi}',
                      size: 20,
                      color: aqiInfo.color,
                      height: 1.0,
                    ),
                    const SizedBox(height: 2),
                    AppText.bold(
                      aqiInfo.label,
                      size: 9.5,
                      color: aqiInfo.color,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Air Quality metrics
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.rich(
                    TextSpan(
                      text: 'PM2.5: ',
                      style: const TextStyle(fontSize: 11, color: UIColors.textSecondary),
                      children: [
                        TextSpan(
                          text: '${station.pm25.toStringAsFixed(1)} µg',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  AppText.rich(
                    TextSpan(
                      text: 'PM10:  ',
                      style: const TextStyle(fontSize: 11, color: UIColors.textSecondary),
                      children: [
                        TextSpan(
                          text: '${station.pm10.toStringAsFixed(1)} µg',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Subtle Vertical Divider
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withOpacity(0.12),
              ),
              const SizedBox(width: 10),

              // Weather metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        AppIcon(weatherInfo.icon, size: 16, color: weatherInfo.color),
                        const SizedBox(width: 4),
                        AppText.bold(
                          '${temp.toStringAsFixed(0)}°C',
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: AppText.regular(
                            weatherInfo.shortLabel,
                            size: 10.5,
                            color: UIColors.textSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        AppText.regular(
                          '💧 $humidity%',
                          size: 10,
                          color: UIColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        AppText.regular(
                          '💨 ${wind.toStringAsFixed(0)}km/h',
                          size: 10,
                          color: UIColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),

          // 3. Compact Health Advice Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: UIColors.surfaceVariant.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                AppIcon(
                  aqiInfo.wearMask ? Icons.masks_rounded : Icons.check_circle_outline_rounded,
                  color: aqiInfo.color,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AppText.regular(
                    aqiInfo.healthAdvice,
                    size: 10,
                    color: UIColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

