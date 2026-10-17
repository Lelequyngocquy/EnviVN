import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
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
                      child: Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: UIColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${station.province}',
                      style: const TextStyle(fontSize: 12, color: UIColors.textSecondary),
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
                  child: const Icon(
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
                    Text(
                      '${station.aqi}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: aqiInfo.color,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aqiInfo.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: aqiInfo.color,
                      ),
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
                  RichText(
                    text: TextSpan(
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
                  RichText(
                    text: TextSpan(
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
                        Icon(weatherInfo.icon, size: 16, color: weatherInfo.color),
                        const SizedBox(width: 4),
                        Text(
                          '${temp.toStringAsFixed(0)}°C',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            weatherInfo.shortLabel,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: UIColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '💧 $humidity%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: UIColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '💨 ${wind.toStringAsFixed(0)}km/h',
                          style: const TextStyle(
                            fontSize: 10,
                            color: UIColors.textSecondary,
                          ),
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
                Icon(
                  aqiInfo.wearMask ? Icons.masks_rounded : Icons.check_circle_outline_rounded,
                  color: aqiInfo.color,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    aqiInfo.healthAdvice,
                    style: const TextStyle(fontSize: 10, color: UIColors.textPrimary),
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

