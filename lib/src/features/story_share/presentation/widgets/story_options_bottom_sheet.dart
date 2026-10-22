import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_bottom_sheet.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/shared/widgets/app_divider.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

enum StoryRatio {
  story(9 / 16, '9:16', 'Story', Icons.crop_portrait_rounded),
  square(1.0, '1:1', 'Vuông', Icons.crop_square_rounded),
  portrait(4 / 5, '4:5', 'Dọc', Icons.crop_5_4_rounded);

  final double ratioValue;
  final String label;
  final String description;
  final IconData icon;

  const StoryRatio(this.ratioValue, this.label, this.description, this.icon);
}

enum StoryCardType {
  airQuality,
  weather,
  floodRisk,
  advisorHealth,
  outdoorActivity,
  windAtmosphere,
}

class StoryCardMeta {
  final StoryCardType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const StoryCardMeta({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  static const List<StoryCardMeta> all = [
    StoryCardMeta(
      type: StoryCardType.airQuality,
      title: 'Chất lượng không khí',
      subtitle: 'AQI US • Nồng độ bụi PM2.5 & PM10',
      icon: Icons.air_rounded,
      iconColor: UIColors.primary,
    ),
    StoryCardMeta(
      type: StoryCardType.weather,
      title: 'Thời tiết hiện tại',
      subtitle: 'Nhiệt độ • Cảm giác thực • Chỉ số UV',
      icon: Icons.wb_sunny_rounded,
      iconColor: UIColors.warning,
    ),
    StoryCardMeta(
      type: StoryCardType.floodRisk,
      title: 'Nguy cơ ngập & Mưa',
      subtitle: 'Khả năng mưa • Cảnh báo dông ngập',
      icon: Icons.flood_rounded,
      iconColor: UIColors.secondary,
    ),
    StoryCardMeta(
      type: StoryCardType.advisorHealth,
      title: 'Cố vấn sức khỏe y tế',
      subtitle: 'Khẩu trang • Cảnh báo nhóm nhạy cảm',
      icon: Icons.health_and_safety_rounded,
      iconColor: UIColors.primaryDark,
    ),
    StoryCardMeta(
      type: StoryCardType.outdoorActivity,
      title: 'Cố vấn thể thao ngoài trời',
      subtitle: 'Chạy bộ • Đạp xe • Giờ lý tưởng',
      icon: Icons.directions_run_rounded,
      iconColor: UIColors.pinPurple,
    ),
    StoryCardMeta(
      type: StoryCardType.windAtmosphere,
      title: 'Gió & Khí quyển',
      subtitle: 'Tốc độ gió • Độ ẩm • Áp suất khí quyển',
      icon: Icons.speed_rounded,
      iconColor: UIColors.gpsBlue,
    ),
  ];
}

class StoryOptionsBottomSheet extends StatefulWidget {
  final StoryRatio initialRatio;
  final List<StoryCardType> initialCards;
  final CityEntity city;
  final AirQualityEntity airQuality;
  final DetailsEntity weather;
  final void Function(StoryRatio ratio, List<StoryCardType> cards) onApply;

  const StoryOptionsBottomSheet({
    super.key,
    required this.initialRatio,
    required this.initialCards,
    required this.city,
    required this.airQuality,
    required this.weather,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required StoryRatio currentRatio,
    required List<StoryCardType> currentCards,
    required CityEntity city,
    required AirQualityEntity airQuality,
    required DetailsEntity weather,
    required void Function(StoryRatio ratio, List<StoryCardType> cards) onApply,
  }) {
    return AppBottomSheet.show(
      context,
      title: 'Tùy chỉnh thẻ Story',
      subtitle: 'Tỷ lệ và các dữ liệu muốn chia sẻ',
      icon: Icons.settings_suggest,
      maxHeightFactor: 0.9,
      child: StoryOptionsBottomSheet(
        initialRatio: currentRatio,
        initialCards: currentCards,
        city: city,
        airQuality: airQuality,
        weather: weather,
        onApply: onApply,
      ),
    );
  }

  @override
  State<StoryOptionsBottomSheet> createState() =>
      _StoryOptionsBottomSheetState();
}

class _StoryOptionsBottomSheetState extends State<StoryOptionsBottomSheet> {
  late StoryRatio _selectedRatio;
  late List<StoryCardType> _selectedCards;

  @override
  void initState() {
    super.initState();
    _selectedRatio = widget.initialRatio;
    _selectedCards = List.from(widget.initialCards);
  }

  void _toggleCard(StoryCardType type) {
    setState(() {
      if (_selectedCards.contains(type)) {
        if (_selectedCards.length > 1) {
          _selectedCards.remove(type);
        }
      } else {
        _selectedCards.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aqi = widget.airQuality.usAqi;
    final aqiInfo = AQIHelper.getAQIInfo(aqi);
    final weatherInfo = WeatherCodeHelper.getInfo(widget.weather.weatherCode);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppDivider(title: 'tỷ lệ khung hình'),
                    Gap(8),
                    Row(
                      children: StoryRatio.values.map((ratio) {
                        final isSelected = _selectedRatio == ratio;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRatio = ratio;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? UIColors.primary.withOpacity(0.18)
                                      : UIColors.surfaceVariant.withOpacity(
                                          0.4,
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? UIColors.primary
                                        : UIColors.white.withOpacity(0.08),
                                    width: isSelected ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIcon(
                                      ratio.icon,
                                      size: 20,
                                      color: isSelected
                                          ? UIColors.primary
                                          : UIColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    AppText.bold(
                                      ratio.label,
                                      size: 13,
                                      color: isSelected
                                          ? UIColors.primary
                                          : UIColors.textPrimary,
                                      maxLines: 3,
                                    ),
                                    const Gap(2),
                                    AppText.regular(
                                      ratio.description,
                                      size: 10,
                                      color: isSelected
                                          ? UIColors.primaryDark
                                          : UIColors.textMuted,
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Gap(8),
                AppDivider(title: 'các thẻ dữ liệu'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppText.semiBold(
                      'Đã chọn: ${_selectedCards.length}/${StoryCardMeta.all.length}',
                      size: 11,
                      color: UIColors.primary,
                      maxLines: 3,
                    ),
                  ],
                ),
                const Gap(10),

                Column(
                  children: List.generate(StoryCardMeta.all.length, (index) {
                    final meta = StoryCardMeta.all[index];
                    final isChecked = _selectedCards.contains(meta.type);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _toggleCard(meta.type),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isChecked
                                ? UIColors.primary.withOpacity(0.08)
                                : UIColors.cardBg.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isChecked
                                  ? UIColors.primary.withOpacity(0.8)
                                  : UIColors.white.withOpacity(0.06),
                              width: isChecked ? 1.2 : 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isChecked
                                          ? UIColors.primary
                                          : UIColors.surfaceVariant,
                                    ),
                                    child: isChecked
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 15,
                                            color: UIColors.bg,
                                          )
                                        : null,
                                  ),
                                  const Gap(10),
                                  AppIcon(
                                    meta.icon,
                                    size: 18,
                                    color: meta.iconColor,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText.bold(
                                          meta.title,
                                          size: 13,
                                          color: UIColors.textPrimary,
                                          maxLines: 3,
                                        ),
                                        AppText.regular(
                                          meta.subtitle,
                                          size: 10,
                                          color: UIColors.textSecondary,
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Gap(8),

                              _buildMiniatureCard(
                                meta.type,
                                aqiInfo: aqiInfo,
                                weatherInfo: weatherInfo,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const Gap(12),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedRatio, _selectedCards);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.primary,
                foregroundColor: UIColors.bg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const AppText.bold(
                'Áp dụng tùy chọn',
                size: 15,
                color: UIColors.bg,
                maxLines: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniatureCard(
    StoryCardType type, {
    required dynamic aqiInfo,
    required dynamic weatherInfo,
  }) {
    final aqi = widget.airQuality.usAqi;
    final weather = widget.weather;
    final isRaining = weather.precipitation > 0;
    final int nextRainProb = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;

    switch (type) {
      case StoryCardType.airQuality:
        return AppGlass(
          isFixed: true,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.semiBold(
                    'CHỈ SỐ KHÔNG KHÍ',
                    size: 9,
                    color: UIColors.textMuted,
                    maxLines: 3,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AppText.bold(
                        '$aqi',
                        size: 20,
                        color: aqiInfo.color,
                        maxLines: 3,
                      ),
                      const SizedBox(width: 4),
                      const AppText.bold(
                        'AQI US',
                        size: 9,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: aqiInfo.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText.bold(
                  aqiInfo.label,
                  size: 11,
                  color: aqiInfo.color,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        );

      case StoryCardType.weather:
        return AppGlass(
          isFixed: true,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppIcon(weatherInfo.icon, size: 20, color: weatherInfo.color),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bold(
                        '${weather.currentTemp.round()}°C',
                        size: 14,
                        color: UIColors.textPrimary,
                        maxLines: 3,
                      ),
                      AppText.regular(
                        weatherInfo.description,
                        size: 9,
                        color: UIColors.textSecondary,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ],
              ),
              AppText.semiBold(
                'Cảm giác: ${weather.apparentTemp.round()}°C',
                size: 9,
                color: UIColors.textMuted,
                maxLines: 3,
              ),
            ],
          ),
        );

      case StoryCardType.floodRisk:
        return AppGlass(
          isFixed: true,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              const AppIcon(
                Icons.umbrella_rounded,
                size: 18,
                color: UIColors.secondary,
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bold(
                      isRaining
                          ? 'Đang có mưa • Lượng: ${weather.precipitation.toStringAsFixed(1)} mm'
                          : 'Xác suất mưa tới: $nextRainProb%',
                      size: 10,
                      color: isRaining || nextRainProb >= 50
                          ? UIColors.warning
                          : UIColors.textPrimary,
                      maxLines: 3,
                    ),
                    AppText.regular(
                      isRaining || nextRainProb >= 60
                          ? 'Đề phòng ngập cục bộ ở vùng trũng'
                          : 'Đường xá thông thoáng, nguy cơ ngập thấp',
                      size: 9,
                      color: UIColors.textSecondary,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case StoryCardType.advisorHealth:
        return AppGlass(
          isFixed: true,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIcon(
                Icons.masks_rounded,
                size: 18,
                color: UIColors.primaryDark,
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bold(
                      aqi > 100
                          ? 'Nên đeo khẩu trang N95'
                          : 'Khẩu trang thông thường',
                      size: 10,
                      color: aqi > 100 ? UIColors.warning : UIColors.primary,
                      maxLines: 3,
                    ),
                    AppText.regular(
                      aqiInfo.healthAdvice,
                      size: 9,
                      color: UIColors.textSecondary,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case StoryCardType.outdoorActivity:
        return AppGlass(
          isFixed: true,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              const AppIcon(
                Icons.directions_run_rounded,
                size: 18,
                color: UIColors.pinPurple,
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bold(
                      aqi <= 100
                          ? 'Lý tưởng cho chạy bộ ngoài trời'
                          : 'Hạn chế tập luyện ngoài trời',
                      size: 10,
                      color: aqi <= 100 ? UIColors.primary : UIColors.error,
                      maxLines: 3,
                    ),
                    AppText.regular(
                      'UV: ${weather.uvIndex.toStringAsFixed(1)} • Khuyên tập trước 08:00 sáng',
                      size: 9,
                      color: UIColors.textSecondary,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case StoryCardType.windAtmosphere:
        return AppGlass(
          isFixed: true,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric(
                'Gió',
                '${weather.windSpeed.toStringAsFixed(1)} km/h',
              ),
              _buildMiniMetric('Độ ẩm', '${weather.relativeHumidity}%'),
              _buildMiniMetric(
                'Khí áp',
                '${weather.surfacePressure.toStringAsFixed(0)} hPa',
              ),
            ],
          ),
        );
    }
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      children: [
        AppText.regular(label, size: 8, color: UIColors.textMuted, maxLines: 3),
        AppText.bold(value, size: 10, color: UIColors.textPrimary, maxLines: 3),
      ],
    );
  }
}
