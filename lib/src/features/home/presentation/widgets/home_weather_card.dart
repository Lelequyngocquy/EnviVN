import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class HomeWeatherCard extends StatelessWidget {
  final WeatherEntity weather;
  final VoidCallback? onDetailTap;

  const HomeWeatherCard({
    super.key,
    required this.weather,
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final weatherInfo = WeatherCodeHelper.getInfo(weather.weatherCode);

    final tempStr = weather.currentTemp.toStringAsFixed(0);
    final feelsLikeStr = weather.apparentTemp.toStringAsFixed(0);
    final windStr = weather.windSpeed.toStringAsFixed(1);
    final humidityStr = '${weather.relativeHumidity}%';
    final uvStr = weather.uvIndex.toStringAsFixed(1);

    // Rain indicator: show mm if precipitation > 0, otherwise show probability from hourly
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

    // High / Low temp for today if daily forecast exists
    final daily = weather.dailyForecast.isNotEmpty ? weather.dailyForecast.first : null;
    final String? highLowStr = daily != null
        ? 'Cao: ${daily.maxTemp.toStringAsFixed(0)}° • Thấp: ${daily.minTemp.toStringAsFixed(0)}°'
        : null;

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_sync_rounded,
                    size: 16,
                    color: UIColors.secondary.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'THỜI TIẾT HIỆN TẠI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: UIColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (onDetailTap != null)
                GestureDetector(
                  onTap: onDetailTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chi tiết 24h',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: UIColors.secondary,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: UIColors.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Weather Hero: Temp & Weather Phenomenon (Mưa, Nắng, Mây, Dông bão)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Temp & Weather description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tempStr,
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.0,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: UIColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weatherInfo.description,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: weatherInfo.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cảm giác như: $feelsLikeStr°C${highLowStr != null ? ' • $highLowStr' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: UIColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Big Animated / Glowing Weather Icon
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
                child: Icon(
                  weatherInfo.icon,
                  size: 38,
                  color: weatherInfo.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. 4-Pill Metric Grid (Mưa, Gió, Độ ẩm, Chỉ số UV)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
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
                  color: Colors.white.withOpacity(0.08),
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
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _WeatherPillItem(
                    icon: Icons.opacity_rounded,
                    iconColor: const Color(0xFF67E8F9),
                    label: 'Độ ẩm',
                    value: humidityStr,
                    sub: weather.relativeHumidity > 80 ? 'Ẩm cao' : 'Thoáng đãng',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withOpacity(0.08),
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

          // 4. Mini Hourly Forecast Slider
          if (weather.hourlyForecast.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DỰ BÁO CÁC GIỜ TIẾP THEO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: UIColors.textMuted,
                  ),
                ),
                if (weather.hourlyForecast.any((h) => h.precipitationProbability >= 40))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: UIColors.secondary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.umbrella_rounded, size: 10, color: UIColors.secondary),
                        SizedBox(width: 4),
                        Text(
                          'Sắp có mưa',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: UIColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: weather.hourlyForecast.length > 10 ? 10 : weather.hourlyForecast.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = weather.hourlyForecast[index];
                  final isFirst = index == 0;
                  final timeStr = isFirst ? 'Bây giờ' : DateFormat('HH:mm').format(item.time);
                  final itemInfo = WeatherCodeHelper.getInfo(item.weatherCode);

                  return GestureDetector(
                    onTap: onDetailTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? UIColors.primary.withOpacity(0.12)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isFirst
                              ? UIColors.primary.withOpacity(0.4)
                              : Colors.white.withOpacity(0.06),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                              color: isFirst ? UIColors.primary : UIColors.textSecondary,
                            ),
                          ),
                          Icon(
                            itemInfo.icon,
                            size: 18,
                            color: itemInfo.color,
                          ),
                          Text(
                            '${item.temperature.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (item.precipitationProbability > 0)
                            Text(
                              '${item.precipitationProbability}%',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: UIColors.secondary,
                              ),
                            )
                          else
                            const SizedBox(height: 11),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: UIColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
