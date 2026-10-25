import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/activity_advice_helper.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:gap/gap.dart';

class OutdoorActivityAdviceCard extends StatelessWidget {
  final AirQualityEntity airQuality;
  final DetailsEntity weather;
  final bool isCompact;

  const OutdoorActivityAdviceCard({
    super.key,
    required this.airQuality,
    required this.weather,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final aqi = airQuality.usAqi > 0 ? airQuality.usAqi : 50;
    final info = AQIHelper.getAQIInfo(aqi);
    final uv = weather.uvIndex;
    final rainProb = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;
    final weatherCode = weather.weatherCode;
    final weatherInfo = WeatherCodeHelper.getInfo(weatherCode);
    final precipitation = weather.precipitation;
    final isCurrentlyRaining = precipitation > 0.1 || weatherInfo.isRain;

    final adviceData = ActivityAdviceHelper.evaluate(
      aqi: aqi,
      uv: uv,
      rainProb: rainProb,
      currentTime: DateTime.now(),
      hourlyWeather: weather.hourlyForecast,
      hourlyAqi: airQuality.hourlyAqi,
      isRaining: isCurrentlyRaining,
      precipitation: precipitation,
    );

    return AppGlass(
      borderRadius: isCompact ? 18 : 22,
      padding: isCompact ? const EdgeInsets.all(13) : const EdgeInsets.all(18),
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
                      padding: EdgeInsets.all(isCompact ? 6 : 8),
                      decoration: BoxDecoration(
                        color: adviceData.statusColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                      ),
                      child: AppIcon(
                        Icons.directions_run_rounded,
                        color: adviceData.statusColor,
                        size: isCompact ? 16 : 20,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: AppText.bold(
                        'Khuyến nghị hoạt động',
                        maxLines: 1,
                        size: isCompact ? 13 : 14,
                        color: UIColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              AppStatusTag(
                label: adviceData.statusLabel,
                color: adviceData.statusColor,
                size: isCompact ? AppTagSize.small : AppTagSize.medium,
              ),
            ],
          ),
          Gap(isCompact ? 8 : 12),
          AppText.medium(
            adviceData.adviceText,
            size: isCompact ? 12 : 13,
            color: UIColors.textPrimary,
            height: isCompact ? 1.35 : 1.45,
          ),
          Gap(isCompact ? 8 : 14),
          Wrap(
            spacing: isCompact ? 6 : 8,
            runSpacing: isCompact ? 6 : 8,
            children: [
              _ActionGlassPill(
                icon: Icons.masks_rounded,
                label: info.wearMask
                    ? 'Đeo khẩu trang PM2.5'
                    : 'Không cần khẩu trang',
                color: info.wearMask
                    ? UIColors.aqiUnhealthySensitive
                    : UIColors.aqiGood,
                isCompact: isCompact,
              ),
              _ActionGlassPill(
                icon: isCurrentlyRaining
                    ? Icons.water_drop_rounded
                    : (rainProb >= 40
                          ? Icons.umbrella_rounded
                          : Icons.wb_sunny_outlined),
                label: isCurrentlyRaining
                    ? 'Đang mưa • Mang áo mưa'
                    : (rainProb >= 40
                          ? 'Chuẩn bị áo mưa ($rainProb%)'
                          : 'Trời tạnh ráo'),
                color: isCurrentlyRaining || rainProb >= 40
                    ? UIColors.secondary
                    : UIColors.aqiGood,
                isCompact: isCompact,
              ),
              _ActionGlassPill(
                icon: Icons.wb_sunny_rounded,
                label: uv >= 6 ? 'Chống nắng SPF 30+' : 'UV an toàn',
                color: uv >= 6 ? UIColors.warning : UIColors.secondary,
                isCompact: isCompact,
              ),
              _ActionGlassPill(
                icon: Icons.air_rounded,
                label: aqi <= 80 ? 'Mở cửa thông thoáng' : 'Bật máy lọc khí',
                color: aqi <= 80
                    ? UIColors.aqiGood
                    : UIColors.aqiUnhealthySensitive,
                isCompact: isCompact,
              ),
            ],
          ),
          Gap(isCompact ? 8 : 14),
          AppText.bold(
            'Khung giờ hoạt động gợi ý:',
            size: isCompact ? 10.5 : 11,
            color: UIColors.textSecondary,
          ),
          Gap(isCompact ? 6 : 8),
          Row(
            children: [
              for (int i = 0; i < adviceData.slots.length; i++) ...[
                if (i > 0) const Gap(8),
                _TimeSlotGlassChip(
                  time: adviceData.slots[i].timeRange,
                  activity: adviceData.slots[i].activity,
                  status: adviceData.slots[i].status,
                  isOk: adviceData.slots[i].isOk,
                  isCompact: isCompact,
                ),
              ],
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
  final bool isCompact;

  const _TimeSlotGlassChip({
    required this.time,
    required this.activity,
    required this.status,
    required this.isOk,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 5)
            : const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: UIColors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
          border: Border.all(color: UIColors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  Icons.schedule_rounded,
                  size: isCompact ? 11 : 13,
                  color: isOk ? UIColors.primary : UIColors.textSecondary,
                ),
                const Gap(4),
                Expanded(
                  child: AppText.bold(
                    time,
                    maxLines: 1,
                    size: isCompact ? 10 : 11,
                    color: UIColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Gap(2),
            AppText.regular(
              activity,
              maxLines: 1,
              size: isCompact ? 9.5 : 11,
              color: UIColors.textSecondary,
            ),
            const Gap(1),
            AppText.bold(
              status,
              maxLines: 1,
              size: isCompact ? 9 : 10,
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
  final bool isCompact;

  const _ActionGlassPill({
    required this.icon,
    required this.label,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppStatusTag(
      label: label,
      icon: icon,
      color: color,
      size: isCompact ? AppTagSize.small : AppTagSize.medium,
      fontWeight: FontWeight.w600,
    );
  }
}
