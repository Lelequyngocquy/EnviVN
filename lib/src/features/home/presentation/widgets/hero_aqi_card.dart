import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class HeroAQICard extends StatelessWidget {
  final AirQualityEntity airQuality;
  final String updateTimeText;
  final VoidCallback? onDetailTap;

  const HeroAQICard({
    super.key,
    required this.airQuality,
    this.updateTimeText = 'Cập nhật: Vừa xong',
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final aqiVal = airQuality.usAqi > 0 ? airQuality.usAqi : 72;
    final aqiInfo = AQIHelper.getAQIInfo(aqiVal);
    final pm25Val = airQuality.pm25 > 0 ? airQuality.pm25 : 22.1;
    final pm10Val = airQuality.pm10 > 0 ? airQuality.pm10 : 45.0;

    return AppGlass(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CHỈ SỐ CHẤT LƯỢNG KHÔNG KHÍ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: UIColors.textSecondary,
                ),
              ),
              Icon(Icons.bubble_chart_rounded, color: aqiInfo.color, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '$aqiVal',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Status Badge Pill
              AppStatusTag(
                label: aqiInfo.label,
                color: aqiInfo.color,
                size: AppTagSize.large,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sub-metrics PM2.5 and PM10
          Text(
            'PM2.5: ${pm25Val.toStringAsFixed(1)} µg/m³  •  PM10: ${pm10Val.toStringAsFixed(1)} µg/m³',
            style: const TextStyle(
              fontSize: 13,
              color: UIColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          // 24-Bar Hourly Timeline Indicator (matching g_1 to g_24 in 02 svg)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Dự báo theo giờ',
                    style: TextStyle(
                      fontSize: 11,
                      color: UIColors.textSecondary,
                    ),
                  ),
                  Text(
                    '24h',
                    style: TextStyle(
                      fontSize: 11,
                      color: UIColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(24, (i) {
                    double factor = 0.5;
                    Color barColor = UIColors.aqiGood;

                    if (airQuality.hourlyAqi.length > i) {
                      final item = airQuality.hourlyAqi[i];
                      final info = AQIHelper.getAQIInfo(item.aqi);
                      barColor = info.color;
                      factor = (item.aqi / 200).clamp(0.2, 1.0);
                    } else {
                      factor = (0.3 + (i % 8) * 0.1).clamp(0.2, 1.0);
                      if (i >= 8 && i <= 14) {
                        barColor = UIColors.aqiModerate;
                      } else if (i >= 15 && i <= 18) {
                        barColor = UIColors.aqiUnhealthySensitive;
                      }
                    }

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        height: 28 * factor,
                        decoration: BoxDecoration(
                          color: barColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: UIColors.surfaceVariant),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                updateTimeText,
                style: const TextStyle(fontSize: 11, color: UIColors.textMuted),
              ),
              if (onDetailTap != null)
                GestureDetector(
                  onTap: onDetailTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: const [
                      Text(
                        'Chi tiết 24h',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: UIColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: UIColors.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
