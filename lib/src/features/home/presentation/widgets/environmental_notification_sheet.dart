import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_bottom_sheet.dart';
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
      subtitle: cityName,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (hasAqiWarning ? aqiInfo.color : UIColors.primary).withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(
          hasAqiWarning ? Icons.warning_amber_rounded : Icons.notifications_active_rounded,
          color: hasAqiWarning ? aqiInfo.color : UIColors.primary,
          size: 20,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chất lượng không khí (AQI $aqiVal)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: aqiInfo.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: aqiInfo.color.withOpacity(0.5)),
                      ),
                      child: Text(
                        aqiInfo.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: aqiInfo.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  aqiInfo.healthAdvice,
                  style: const TextStyle(fontSize: 12, color: UIColors.textSecondary, height: 1.4),
                ),
                if (aqiInfo.wearMask) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.masks_rounded, size: 14, color: UIColors.aqiUnhealthySensitive),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Khuyến nghị đeo khẩu trang lọc bụi mịn PM2.5 khi ra ngoài.',
                          style: TextStyle(
                            fontSize: 11,
                            color: UIColors.aqiUnhealthySensitive,
                            fontWeight: FontWeight.w500,
                          ),
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
                        const Icon(Icons.wb_sunny_rounded, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'Cảnh báo UV: Mức ${weather.uvIndex.toStringAsFixed(1)} (Rất cao)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hạn chế tiếp xúc trực tiếp dưới ánh nắng giữa trưa, cần thoa kem chống nắng & kính râm.',
                      style: TextStyle(fontSize: 11, color: UIColors.textSecondary),
                    ),
                  ],
                  if (hasUvWarning && rainProb >= 50) const Divider(height: 16, color: Colors.white10),
                  if (rainProb >= 50) ...[
                    Row(
                      children: [
                        const Icon(Icons.umbrella_rounded, size: 16, color: UIColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'Khả năng mưa: $rainProb%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: UIColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dự báo có khả năng mưa trong vài giờ tới, hãy mang theo áo mưa hoặc ô.',
                      style: TextStyle(fontSize: 11, color: UIColors.textSecondary),
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
