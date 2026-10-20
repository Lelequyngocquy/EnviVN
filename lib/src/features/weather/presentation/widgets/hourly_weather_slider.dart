import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class HourlyWeatherSlider extends StatelessWidget {
  final List<HourlyWeatherPoint> hourlyList;

  const HourlyWeatherSlider({super.key, required this.hourlyList});

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) return const SizedBox.shrink();

    final points = hourlyList.take(24).toList();

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: AppText.bold(
                  'DỰ BÁO CHI TIẾT TỪNG MỐC GIỜ SẮP TỚI',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  size: 11,
                  letterSpacing: 0.8,
                  color: UIColors.textSecondary,
                ),
              ),
              if (points.any((h) => h.precipitationProbability >= 40)) ...[
                const SizedBox(width: 8),
                const AppStatusTag(
                  label: 'Có mưa trong ngày',
                  icon: Icons.umbrella_rounded,
                  color: UIColors.secondary,
                  size: AppTagSize.small,
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: points.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = points[index];
                final isFirst = index == 0;
                final timeStr = isFirst
                    ? 'Bây giờ'
                    : DateFormat('HH:mm').format(item.time);
                final itemInfo = WeatherCodeHelper.getInfo(
                  item.weatherCode,
                  time: item.time,
                );

                return Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? UIColors.secondary.withOpacity(0.12)
                        : UIColors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isFirst
                          ? UIColors.secondary.withOpacity(0.4)
                          : UIColors.white.withOpacity(0.06),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        timeStr,
                        size: 10,
                        fontWeight: isFirst
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isFirst
                            ? UIColors.secondary
                            : UIColors.textSecondary,
                      ),
                      AppIcon(itemInfo.icon, size: 20, color: itemInfo.color),
                      AppText.bold(
                        '${item.temperature.toStringAsFixed(0)}°',
                        size: 13,
                        color: UIColors.textPrimary,
                      ),
                      if (item.precipitationProbability > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppIcon(
                              Icons.water_drop,
                              size: 8,
                              color: UIColors.secondary,
                            ),
                            AppText.semiBold(
                              '${item.precipitationProbability}%',
                              size: 9,
                              color: UIColors.secondary,
                            ),
                          ],
                        )
                      else
                        AppText.regular(
                          '${item.humidity}% 💧',
                          size: 8,
                          color: UIColors.textMuted,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
