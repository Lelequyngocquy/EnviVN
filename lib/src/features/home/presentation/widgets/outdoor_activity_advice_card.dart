import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/activity_advice_helper.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
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
      currentTime: DateTime.now(),
      hourlyWeather: weather.hourlyForecast,
      hourlyAqi: airQuality.hourlyAqi,
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
                      child: AppIcon(
                        Icons.directions_run_rounded,
                        color: adviceData.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: AppText.bold(
                        'Khuyến nghị hoạt động',
                        maxLines: 3,
                        size: 14,
                        color: UIColors.textPrimary,
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
          AppText.medium(
            adviceData.adviceText,
            size: 13,
            color: UIColors.textPrimary,
            height: 1.45,
          ),
          const SizedBox(height: 14),
          const AppText.bold(
            'Khung giờ hoạt động gợi ý:',
            size: 11,
            color: UIColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < adviceData.slots.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _TimeSlotGlassChip(
                  time: adviceData.slots[i].timeRange,
                  activity: adviceData.slots[i].activity,
                  status: adviceData.slots[i].status,
                  isOk: adviceData.slots[i].isOk,
                ),
              ],
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
                AppIcon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: isOk ? UIColors.primary : UIColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AppText.bold(
                    time,
                    maxLines: 1,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            AppText.regular(
              activity,
              maxLines: 1,
              size: 11,
              color: UIColors.textSecondary,
            ),
            const SizedBox(height: 2),
            AppText.bold(
              status,
              maxLines: 1,
              size: 10,
              color: isOk ? UIColors.primary : UIColors.aqiUnhealthySensitive,
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
