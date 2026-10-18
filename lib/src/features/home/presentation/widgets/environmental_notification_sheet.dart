import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_bottom_sheet.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class EnvironmentalNotificationSheet extends StatelessWidget {
  final String cityName;
  final AirQualityEntity airQuality;
  final WeatherEntity weather;
  final VoidCallback? onDismiss;

  const EnvironmentalNotificationSheet({
    super.key,
    required this.cityName,
    required this.airQuality,
    required this.weather,
    this.onDismiss,
  });

  /// Hiển thị thông báo môi trường bằng vỏ AppBottomSheet dùng chung
  static Future<void> show(
    BuildContext context, {
    required String cityName,
    required AirQualityEntity airQuality,
    required WeatherEntity weather,
  }) {
    final aqiVal = airQuality.usAqi > 0 ? airQuality.usAqi : 50;
    final aqiInfo = AQIHelper.getAQIInfo(aqiVal);
    final hasAqiWarning = aqiVal > 100;

    return AppBottomSheet.show(
      context,
      title: 'Thông báo môi trường',
      subtitle: cityName.isNotEmpty ? 'Điều kiện thực tế tại $cityName' : null,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (hasAqiWarning ? aqiInfo.color : UIColors.primary).withOpacity(
            0.18,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AppIcon(
            hasAqiWarning
                ? Icons.warning_amber_rounded
                : Icons.notifications_active_rounded,
            color: hasAqiWarning ? aqiInfo.color : UIColors.primary,
            size: 22,
          ),
        ),
      ),
      bottomButtonText: 'Đã hiểu',
      child: EnvironmentalNotificationSheet(
        cityName: cityName,
        airQuality: airQuality,
        weather: weather,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aqiVal = airQuality.usAqi > 0 ? airQuality.usAqi : 50;
    final aqiInfo = AQIHelper.getAQIInfo(aqiVal);
    final hasUvWarning = weather.uvIndex >= 8;
    final rainProb = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AQI Alert Card
          AppGlass(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText.semiBold(
                        'Chất lượng không khí (AQI $aqiVal)',
                        maxLines: 3,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppStatusTag(
                      label: aqiInfo.label,
                      color: aqiInfo.color,
                      size: AppTagSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppText.regular(
                  aqiInfo.healthAdvice,
                  size: 12,
                  color: UIColors.textSecondary,
                  height: 1.4,
                ),
                if (aqiInfo.wearMask) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      AppIcon(
                        Icons.masks_rounded,
                        size: 14,
                        color: UIColors.aqiUnhealthySensitive,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: AppText.medium(
                          'Khuyến nghị đeo khẩu trang lọc bụi mịn PM2.5 khi ra ngoài.',
                          size: 11,
                          color: UIColors.aqiUnhealthySensitive,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Weather Alert Card (UV & Rain)
          if (hasUvWarning || rainProb >= 50) ...[
            const SizedBox(height: 12),
            AppGlass(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasUvWarning) ...[
                    Row(
                      children: [
                        const AppIcon(
                          Icons.wb_sunny_rounded,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        AppText.bold(
                          'Cảnh báo UV: Mức ${weather.uvIndex.toStringAsFixed(1)} (Rất cao)',
                          size: 12,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const AppText.regular(
                      'Hạn chế tiếp xúc trực tiếp dưới ánh nắng giữa trưa, cần thoa kem chống nắng & kính râm.',
                      size: 11,
                      color: UIColors.textSecondary,
                    ),
                  ],
                  if (hasUvWarning && rainProb >= 50)
                    const Divider(height: 16, color: Colors.white10),
                  if (rainProb >= 50) ...[
                    Row(
                      children: [
                        const AppIcon(
                          Icons.umbrella_rounded,
                          size: 16,
                          color: UIColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        AppText.bold(
                          'Khả năng mưa: $rainProb%',
                          size: 12,
                          color: UIColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const AppText.regular(
                      'Dự báo có khả năng mưa trong vài giờ tới, hãy mang theo áo mưa hoặc ô.',
                      size: 11,
                      color: UIColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
