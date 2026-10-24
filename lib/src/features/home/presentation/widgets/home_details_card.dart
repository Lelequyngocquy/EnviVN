import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:gap/gap.dart';

class HomeDetailsCard extends StatelessWidget {
  final DetailsEntity details;
  final VoidCallback? onDetailTap;

  const HomeDetailsCard({super.key, required this.details, this.onDetailTap});

  const HomeDetailsCard.fromWeather({
    super.key,
    required DetailsEntity weather,
    this.onDetailTap,
  }) : details = weather;

  @override
  Widget build(BuildContext context) {
    final weather = details;
    final weatherInfo = WeatherCodeHelper.getInfo(weather.weatherCode);

    final tempStr = weather.currentTemp.toStringAsFixed(0);
    final feelsLikeStr = weather.apparentTemp.toStringAsFixed(0);
    final windStr = weather.windSpeed.toStringAsFixed(1);
    final humidityStr = '${weather.relativeHumidity}%';
    final uvStr = weather.uvIndex.toStringAsFixed(1);

    final bool isRaining = weather.precipitation > 0;
    final int nextRainProb = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;
    final String rainValue = isRaining
        ? '${weather.precipitation.toStringAsFixed(1)} mm'
        : '$nextRainProb%';
    final String rainSub = isRaining
        ? 'Đang có mưa'
        : (nextRainProb > 30 ? 'Khả năng mưa' : 'Khô ráo');

    final daily = weather.dailyForecast.isNotEmpty
        ? weather.dailyForecast.first
        : null;
    final String? highLowStr = daily != null
        ? 'Cao: ${daily.maxTemp.toStringAsFixed(0)}° • Thấp: ${daily.minTemp.toStringAsFixed(0)}°'
        : null;

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const AppText.bold(
                  'THỜI TIẾT HIỆN TẠI',
                  size: 11,
                  letterSpacing: 0.8,
                  color: UIColors.textSecondary,
                ),
              ),
              AppIcon(
                Icons.cloud_sync_rounded,
                size: 16,
                color: UIColors.secondary.withOpacity(0.9),
              ),
            ],
          ),
          const Gap(16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.extraBold(
                          tempStr,
                          size: 50,
                          color: UIColors.textPrimary,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                        const Gap(4),
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: AppText.bold(
                            '°C',
                            size: 22,
                            color: UIColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    AppText.bold(
                      weatherInfo.description,
                      size: 15,
                      color: weatherInfo.color,
                    ),
                    const Gap(4),
                    AppText.medium(
                      'Cảm giác như: $feelsLikeStr°C${highLowStr != null ? ' • $highLowStr' : ''}',
                      size: 12,
                      color: UIColors.textSecondary,
                    ),
                  ],
                ),
              ),

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: weatherInfo.color.withOpacity(0.14),
                  border: Border.all(
                    color: weatherInfo.color.withOpacity(0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: weatherInfo.color.withOpacity(0.2),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: AppIcon(
                  weatherInfo.icon,
                  size: 38,
                  color: weatherInfo.color,
                ),
              ),
            ],
          ),
          const Gap(16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: UIColors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: UIColors.white.withOpacity(0.08),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _WeatherPillItem(
                    icon: Icons.water_drop_rounded,
                    iconColor: UIColors.secondary,
                    label: isRaining ? 'Lượng mưa' : 'Khả năng mưa',
                    value: rainValue,
                    sub: rainSub,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: UIColors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _WeatherPillItem(
                    icon: Icons.air_rounded,
                    iconColor: UIColors.primary,
                    label: 'Tốc độ gió',
                    value: '$windStr km/h',
                    sub: weather.windSpeed > 25 ? 'Gió giật' : 'Gió nhẹ',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: UIColors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _WeatherPillItem(
                    icon: Icons.opacity_rounded,
                    iconColor: UIColors.secondary,
                    label: 'Độ ẩm',
                    value: humidityStr,
                    sub: weather.relativeHumidity > 80
                        ? 'Ẩm cao'
                        : 'Thoáng đãng',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: UIColors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _WeatherPillItem(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: UIColors.warning,
                    label: 'Chỉ số UV',
                    value: uvStr,
                    sub: weather.uvIndex >= 6 ? 'Nguy cơ cao' : 'Mức an toàn',
                  ),
                ),
              ],
            ),
          ),

          if (weather.hourlyForecast.isNotEmpty) ...[
            const Gap(14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText.bold(
                  'DỰ BÁO CÁC GIỜ TIẾP THEO',
                  size: 11,
                  letterSpacing: 0.8,
                  color: UIColors.textSecondary,
                ),
                if (weather.hourlyForecast.any(
                  (h) => h.precipitationProbability >= 40,
                ))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: UIColors.secondary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          Icons.umbrella_rounded,
                          size: 11,
                          color: UIColors.secondary,
                        ),
                        Gap(4),
                        AppText.bold(
                          'Sắp có mưa',
                          size: 10,
                          color: UIColors.secondary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Gap(10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: weather.hourlyForecast.length > 10
                    ? 10
                    : weather.hourlyForecast.length,
                separatorBuilder: (context, index) => const Gap(8),
                itemBuilder: (context, index) {
                  final item = weather.hourlyForecast[index];
                  final isFirst = index == 0;
                  final timeStr = isFirst
                      ? 'Bây giờ'
                      : DateFormat('HH:mm').format(item.time);
                  final itemInfo = WeatherCodeHelper.getInfo(
                    item.weatherCode,
                    time: item.time,
                  );

                  return GestureDetector(
                    onTap: onDetailTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? UIColors.primary.withOpacity(0.12)
                            : UIColors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isFirst
                              ? UIColors.primary.withOpacity(0.4)
                              : UIColors.white.withOpacity(0.06),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            timeStr,
                            size: 11,
                            fontWeight: isFirst
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isFirst
                                ? UIColors.primary
                                : UIColors.textSecondary,
                          ),
                          AppIcon(
                            itemInfo.icon,
                            size: 18,
                            color: itemInfo.color,
                          ),
                          AppText.bold(
                            '${item.temperature.toStringAsFixed(0)}°',
                            size: 12,
                            color: UIColors.textPrimary,
                          ),
                          if (item.precipitationProbability > 0)
                            AppText.semiBold(
                              '${item.precipitationProbability}%',
                              size: 10,
                              color: UIColors.secondary,
                            )
                          else
                            const Gap(11),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const Gap(14),
          const Divider(height: 1, color: UIColors.surfaceVariant),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText.regular(
                'Cập nhật: Vừa xong',
                size: 11,
                color: UIColors.textMuted,
              ),
              if (onDetailTap != null)
                GestureDetector(
                  onTap: onDetailTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: const [
                      AppText.bold(
                        'Chi tiết 24h',
                        size: 12,
                        color: UIColors.primary,
                      ),
                      AppIcon(
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

class _WeatherPillItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;

  const _WeatherPillItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 14, color: iconColor),
        const Gap(3),
        AppText.bold(value, size: 12, color: UIColors.textPrimary, maxLines: 1),
        const Gap(1),
        AppText.medium(
          label,
          size: 9.5,
          color: UIColors.textSecondary,
          maxLines: 1,
        ),
      ],
    );
  }
}

// Backward-compatibility alias
typedef HomeWeatherCard = HomeDetailsCard;

