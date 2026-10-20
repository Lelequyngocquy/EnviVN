import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class SevenDayForecastCard extends StatelessWidget {
  final List<DailyWeatherPoint> dailyForecast;

  const SevenDayForecastCard({
    super.key,
    required this.dailyForecast,
  });

  @override
  Widget build(BuildContext context) {
    final days = dailyForecast.take(7).toList();
    if (days.isEmpty) return const SizedBox.shrink();

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AppText.bold(
                'DỰ BÁO THỜI TIẾT 7 NGÀY TỚI',
                size: 11,
                letterSpacing: 0.8,
                color: UIColors.textSecondary,
              ),
              AppIcon(Icons.calendar_month_rounded, size: 16, color: UIColors.textSecondary),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            separatorBuilder: (context, index) => Divider(
              color: UIColors.white.withOpacity(0.06),
              height: 16,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final dayName = DateHelper.formatWeekday(day.date);
              final info = WeatherCodeHelper.getInfo(day.weatherCode, isDay: true);

              return Row(
                children: [
                  SizedBox(
                    width: 78,
                    child: AppText(
                      dayName,
                      size: 13,
                      fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                      color: index == 0 ? UIColors.textPrimary : UIColors.textSecondary,
                    ),
                  ),
                  AppIcon(info.icon, size: 18, color: info.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.regular(
                      info.shortLabel,
                      size: 12,
                      color: UIColors.white70,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (day.precipitationSum > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: UIColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText.semiBold(
                        '💧 ${day.precipitationSum.toStringAsFixed(1)}mm',
                        size: 10,
                        color: UIColors.secondary,
                      ),
                    ),
                  AppText.bold(
                    '${day.minTemp.toStringAsFixed(0)}° / ${day.maxTemp.toStringAsFixed(0)}°',
                    size: 12,
                    color: UIColors.textPrimary,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
