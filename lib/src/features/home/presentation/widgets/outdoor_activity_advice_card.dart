import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/activity_advice_helper.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class OutdoorActivityAdviceCard extends StatelessWidget {
  final AirQualityEntity airQuality;
  final WeatherEntity weather;

  const OutdoorActivityAdviceCard({
    super.key,
    required this.airQuality,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final aqi = airQuality.usAqi > 0 ? airQuality.usAqi : 50;
    final info = AQIHelper.getAQIInfo(aqi);
    final uv = weather.uvIndex;
    final rainProb = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;

    final adviceData = ActivityAdviceHelper.evaluate(
      aqi: aqi,
      uv: uv,
      rainProb: rainProb,
    );

    return AppGlass(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: adviceData.statusColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_run_rounded,
                        color: adviceData.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Khuyến nghị hoạt động',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: UIColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppStatusTag(
                label: adviceData.statusLabel,
                color: adviceData.statusColor,
                size: AppTagSize.medium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            adviceData.adviceText,
            style: const TextStyle(
              fontSize: 13,
              color: UIColors.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Khung giờ hoạt động gợi ý:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: UIColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TimeSlotGlassChip(
                time: '05:30 - 07:30',
                activity: 'Chạy bộ sáng',
                status: adviceData.morningStatus,
                isOk: adviceData.isMorningOk,
              ),
              const SizedBox(width: 8),
              _TimeSlotGlassChip(
                time: '17:00 - 18:30',
                activity: 'Tập ngoài trời',
                status: adviceData.eveningStatus,
                isOk: adviceData.isEveningOk,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionGlassPill(
                icon: Icons.masks_rounded,
                label: info.wearMask
                    ? 'Đeo khẩu trang PM2.5'
                    : 'Không cần khẩu trang',
                color: info.wearMask
                    ? UIColors.aqiUnhealthySensitive
                    : UIColors.aqiGood,
              ),
              _ActionGlassPill(
                icon: Icons.wb_sunny_rounded,
                label: uv >= 6 ? 'Chống nắng SPF 30+' : 'UV an toàn',
                color: uv >= 6 ? Colors.orange : UIColors.secondary,
              ),
              _ActionGlassPill(
                icon: Icons.air_rounded,
                label: aqi <= 80 ? 'Mở cửa thông thoáng' : 'Bật máy lọc khí',
                color: aqi <= 80 ? UIColors.aqiGood : Colors.deepOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeSlotGlassChip extends StatelessWidget {
  final String time;
  final String activity;
  final String status;
  final bool isOk;

  const _TimeSlotGlassChip({
    required this.time,
    required this.activity,
    required this.status,
    required this.isOk,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: isOk ? UIColors.primary : UIColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              activity,
              style: const TextStyle(
                fontSize: 11,
                color: UIColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOk ? UIColors.primary : UIColors.aqiUnhealthySensitive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionGlassPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppStatusTag(
      label: label,
      icon: icon,
      color: color,
      size: AppTagSize.medium,
      fontWeight: FontWeight.w600,
    );
  }
}
