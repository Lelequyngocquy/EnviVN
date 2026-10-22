import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/story_share/presentation/widgets/story_options_bottom_sheet.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:gap/gap.dart';

/// Thẻ hình ảnh tóm tắt dữ liệu môi trường, thiết kế compact, hỗ trợ chọn & di chuyển card.
class StoryCardView extends StatelessWidget {
  final CityEntity city;
  final AirQualityEntity airQuality;
  final DetailsEntity weather;
  final DateTime updateTime;
  final StoryRatio ratio;
  final List<StoryCardType> cards;
  final int? selectedIndex;
  final ValueChanged<int?>? onCardSelected;
  final void Function(int fromIndex, int toIndex)? onSwapCards;
  final bool isInteractive;

  const StoryCardView({
    super.key,
    required this.city,
    required this.airQuality,
    required this.weather,
    required this.updateTime,
    this.ratio = StoryRatio.story,
    this.cards = const [
      StoryCardType.airQuality,
      StoryCardType.weather,
      StoryCardType.floodRisk,
      StoryCardType.advisorHealth,
    ],
    this.selectedIndex,
    this.onCardSelected,
    this.onSwapCards,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final aqi = airQuality.usAqi;
    final aqiInfo = AQIHelper.getAQIInfo(aqi);
    final dateStr = DateHelper.formatVietnameseFull(updateTime);
    final timeStr = DateHelper.formatTime(updateTime);

    return AspectRatio(
      aspectRatio: ratio.ratioValue,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1527),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: UIColors.white.withOpacity(0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: aqiInfo.color.withOpacity(0.22),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Ánh sáng nền trang trí
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: aqiInfo.color.withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: UIColors.primary.withOpacity(0.15),
                ),
              ),
            ),

            // Toàn bộ nội dung thẻ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. HEADER BRAND & THỜI GIAN (COMPACT) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: UIColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const AppIcon(
                              Icons.eco_rounded,
                              color: UIColors.primary,
                              size: 14,
                            ),
                          ),
                          const Gap(6),
                          const AppText.bold(
                            'EnviVN',
                            size: 13,
                            color: UIColors.textPrimary,
                            maxLines: 3,
                          ),
                        ],
                      ),
                      AppGlass(
                        isFixed: true,
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: AppText.regular(
                          timeStr,
                          size: 10,
                          color: UIColors.textSecondary,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),

                  const Gap(6),

                  // --- 2. TÊN ĐỊA ĐIỂM & NGÀY THÁNG ---
                  Row(
                    children: [
                      AppIcon(
                        city.isGps
                            ? Icons.my_location_rounded
                            : Icons.location_on_rounded,
                        color: city.isGps
                            ? UIColors.secondary
                            : UIColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AppText.bold(
                          city.name,
                          size: 15,
                          color: UIColors.textPrimary,
                          maxLines: 3,
                        ),
                      ),
                      const Gap(6),
                      AppText.regular(
                        dateStr,
                        size: 10,
                        color: UIColors.textMuted,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const Gap(8),

                  // --- 3. KHU VỰC CÁC THẺ CON MODULAR (COMPACT / MIN) ---
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: constraints.maxHeight - 20,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      child: _buildCardsGrid(
                                        context,
                                        aqiInfo: aqiInfo,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(6),

                            // --- 4. FOOTER THƯƠNG HIỆU ---
                            _buildFooter(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Footer thương hiệu chân trang của Story
  Widget _buildFooter() {
    return Row(
      children: const [
        Expanded(
          child: AppText.regular(
            'EnviVN • Giám sát môi trường',
            size: 8.5,
            color: UIColors.textMuted,
            maxLines: 3,
          ),
        ),
        Gap(4),
        AppText.regular(
          'envivn.app',
          size: 8.5,
          color: UIColors.textMuted,
          maxLines: 3,
        ),
      ],
    );
  }

  /// Lưới 2 cột cho các thẻ con trong Story thu gọn về min
  Widget _buildCardsGrid(
    BuildContext context, {
    required dynamic aqiInfo,
  }) {
    if (cards.isEmpty) {
      return const Center(
        child: AppText.regular(
          'Chưa chọn thẻ dữ liệu nào',
          size: 12,
          color: UIColors.textMuted,
          maxLines: 3,
        ),
      );
    }

    final rowCount = (cards.length / 2).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rowCount, (rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = leftIndex + 1;
        final hasRight = rightIndex < cards.length;

        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rowCount - 1 ? 8 : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildInteractiveCardSlot(
                    index: leftIndex,
                    cardType: cards[leftIndex],
                    aqiInfo: aqiInfo,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: hasRight
                      ? _buildInteractiveCardSlot(
                          index: rightIndex,
                          cardType: cards[rightIndex],
                          aqiInfo: aqiInfo,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Khung bọc tương tác cho mỗi thẻ: hỗ trợ tap để chọn và hiển thị 4 mũi tên di chuyển
  Widget _buildInteractiveCardSlot({
    required int index,
    required StoryCardType cardType,
    required dynamic aqiInfo,
  }) {
    final isSelected = isInteractive && (selectedIndex == index);

    // Tính toán trạng thái các cạnh để disable mũi tên thích hợp
    final int total = cards.length;
    final int col = index % 2; // 0: Trái, 1: Phải

    final bool canMoveUp = (index - 2) >= 0;
    final bool canMoveDown = (index + 2) < total;
    final bool canMoveLeft = col == 1; // Ở cột phải mới sang trái được
    final bool canMoveRight =
        (col == 0) && (index + 1 < total); // Ở cột trái mới sang phải được

    return GestureDetector(
      onTap: () {
        if (!isInteractive) return;
        if (isSelected) {
          onCardSelected?.call(null);
        } else {
          onCardSelected?.call(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? UIColors.primary
                : UIColors.white.withOpacity(0.08),
            width: isSelected ? 1.8 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: UIColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.loose,
          children: [
            // Nội dung chính của card con thu nhỏ về min
            _buildCardContent(cardType, aqiInfo: aqiInfo),

            // Thanh điều khiển 4 hướng khi thẻ đang được chọn
            if (isSelected)
              Positioned.fill(
                child: Container(
                  color: UIColors.bg.withOpacity(0.88),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mũi tên Lên (Up)
                      _buildArrowButton(
                        icon: Icons.arrow_upward_rounded,
                        isEnabled: canMoveUp,
                        onTap: () => onSwapCards?.call(index, index - 2),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mũi tên Trái (Left)
                          _buildArrowButton(
                            icon: Icons.arrow_back_rounded,
                            isEnabled: canMoveLeft,
                            onTap: () => onSwapCards?.call(index, index - 1),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: AppIcon(
                              Icons.open_with_rounded,
                              size: 13,
                              color: UIColors.primary,
                            ),
                          ),
                          // Mũi tên Phải (Right)
                          _buildArrowButton(
                            icon: Icons.arrow_forward_rounded,
                            isEnabled: canMoveRight,
                            onTap: () => onSwapCards?.call(index, index + 1),
                          ),
                        ],
                      ),
                      // Mũi tên Xuống (Down)
                      _buildArrowButton(
                        icon: Icons.arrow_downward_rounded,
                        isEnabled: canMoveDown,
                        onTap: () => onSwapCards?.call(index, index + 2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Nút mũi tên điều hướng (tự động làm mờ và vô hiệu hoá khi chạm cạnh)
  Widget _buildArrowButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: isEnabled
              ? UIColors.primary.withOpacity(0.25)
              : UIColors.surfaceVariant.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled
                ? UIColors.primary
                : UIColors.white.withOpacity(0.05),
            width: 1.0,
          ),
        ),
        child: Center(
          child: AppIcon(
            icon,
            size: 13,
            color: isEnabled
                ? UIColors.primary
                : UIColors.textMuted.withOpacity(0.35),
          ),
        ),
      ),
    );
  }

  /// Xây dựng nội dung compact cụ thể cho từng loại card
  Widget _buildCardContent(StoryCardType type, {required dynamic aqiInfo}) {
    final aqi = airQuality.usAqi;
    final weatherInfo = WeatherCodeHelper.getInfo(weather.weatherCode);
    final isRaining = weather.precipitation > 0;
    final int nextRainProb = weather.hourlyForecast.isNotEmpty
        ? weather.hourlyForecast.first.precipitationProbability
        : 0;

    switch (type) {
      case StoryCardType.airQuality:
        return AppGlass(
          isFixed: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const AppIcon(
                      Icons.air_rounded,
                      size: 12,
                      color: UIColors.primary,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: AppText.bold(
                        'KHÔNG KHÍ',
                        size: 9,
                        color: UIColors.textMuted,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: aqiInfo.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText.bold(
                        aqiInfo.label,
                        size: 8,
                        color: aqiInfo.color,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AppText.bold(
                      '$aqi',
                      size: 19,
                      color: aqiInfo.color,
                      maxLines: 3,
                    ),
                    const SizedBox(width: 4),
                    const AppText.semiBold(
                      'AQI US',
                      size: 8.5,
                      color: UIColors.textSecondary,
                      maxLines: 3,
                    ),
                  ],
                ),
                const Gap(3),
                AppText.regular(
                  'Bụi PM2.5: ${airQuality.pm25.toStringAsFixed(1)} µg/m³',
                  size: 8.5,
                  color: UIColors.textSecondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );

      case StoryCardType.weather:
        return AppGlass(
          isFixed: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AppIcon(weatherInfo.icon, size: 12, color: weatherInfo.color),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: AppText.bold(
                        'THỜI TIẾT',
                        size: 9,
                        color: UIColors.textMuted,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AppText.semiBold(
                      'UV ${weather.uvIndex.toStringAsFixed(1)}',
                      size: 8.5,
                      color: UIColors.warning,
                      maxLines: 3,
                    ),
                  ],
                ),
                const Gap(4),
                Row(
                  children: [
                    AppText.bold(
                      '${weather.currentTemp.round()}°C',
                      size: 17,
                      color: UIColors.textPrimary,
                      maxLines: 3,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText.semiBold(
                        weatherInfo.description,
                        size: 9,
                        color: weatherInfo.color,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const Gap(3),
                AppText.regular(
                  'Cảm giác: ${weather.apparentTemp.round()}°C • Ẩm ${weather.relativeHumidity}%',
                  size: 8.5,
                  color: UIColors.textSecondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );

      case StoryCardType.floodRisk:
        return AppGlass(
          isFixed: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const AppIcon(
                      Icons.flood_rounded,
                      size: 12,
                      color: UIColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: AppText.bold(
                        'NGẬP & MƯA',
                        size: 9,
                        color: UIColors.textMuted,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isRaining || nextRainProb >= 50
                                    ? UIColors.warning
                                    : UIColors.secondary)
                                .withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText.bold(
                        isRaining ? 'Có mưa' : '$nextRainProb%',
                        size: 8,
                        color: isRaining || nextRainProb >= 50
                            ? UIColors.warning
                            : UIColors.secondary,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                AppText.bold(
                  isRaining
                      ? 'Mưa ${weather.precipitation.toStringAsFixed(1)} mm'
                      : 'Khả năng mưa: $nextRainProb%',
                  size: 11,
                  color: isRaining || nextRainProb >= 50
                      ? UIColors.warning
                      : UIColors.textPrimary,
                  maxLines: 3,
                ),
                const Gap(3),
                AppText.regular(
                  isRaining || nextRainProb >= 60
                      ? 'Đề phòng ngập cục bộ tại các điểm trũng'
                      : 'Tuyến đường khô ráo, nguy cơ ngập thấp',
                  size: 8.5,
                  color: UIColors.textSecondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );

      case StoryCardType.advisorHealth:
        return AppGlass(
          isFixed: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    AppIcon(
                      Icons.health_and_safety_rounded,
                      size: 12,
                      color: UIColors.primaryDark,
                    ),
                    Gap(4),
                    Expanded(
                      child: AppText.bold(
                        'CỐ VẤN Y TẾ',
                        size: 9,
                        color: UIColors.textMuted,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                AppText.bold(
                  aqi > 100
                    ? 'Khuyên dùng khẩu trang N95'
                    : 'An toàn khi ra ngoài',
                  size: 10.5,
                  color: aqi > 100 ? UIColors.warning : UIColors.primary,
                  maxLines: 3,
                ),
                const Gap(3),
                AppText.regular(
                  aqiInfo.healthAdvice,
                  size: 8.5,
                  color: UIColors.textSecondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );

      case StoryCardType.outdoorActivity:
        return AppGlass(
          isFixed: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    AppIcon(
                      Icons.directions_run_rounded,
                      size: 12,
                      color: UIColors.pinPurple,
                    ),
                    Gap(4),
                    Expanded(
                      child: AppText.bold(
                        'THỂ THAO',
                        size: 9,
                        color: UIColors.textMuted,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                AppText.bold(
                  aqi <= 100
                    ? 'Thích hợp cho chạy bộ sáng'
                    : 'Nên tập luyện trong nhà',
                  size: 10.5,
                  color: aqi <= 100 ? UIColors.primary : UIColors.error,
                  maxLines: 3,
                ),
                const Gap(3),
                AppText.regular(
                  'UV ${weather.uvIndex.toStringAsFixed(1)} • Thích hợp 06:00 - 08:00',
                  size: 8.5,
                  color: UIColors.textSecondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );

      case StoryCardType.windAtmosphere:
        return AppGlass(
          isFixed: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    AppIcon(
                      Icons.speed_rounded,
                      size: 12,
                      color: UIColors.gpsBlue,
                    ),
                    Gap(4),
                    Expanded(
                      child: AppText.bold(
                        'GIÓ & KHÍ QUYỂN',
                        size: 9,
                        color: UIColors.textMuted,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText.regular(
                            'Gió',
                            size: 7.5,
                            color: UIColors.textMuted,
                            maxLines: 3,
                          ),
                          AppText.bold(
                            '${weather.windSpeed.toStringAsFixed(1)} km/h',
                            size: 9.5,
                            color: UIColors.textPrimary,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText.regular(
                            'Khí áp',
                            size: 7.5,
                            color: UIColors.textMuted,
                            maxLines: 3,
                          ),
                          AppText.bold(
                            '${weather.surfacePressure.toStringAsFixed(0)} hPa',
                            size: 9.5,
                            color: UIColors.textPrimary,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(3),
                AppText.regular(
                  weather.relativeHumidity > 80
                      ? 'Độ ẩm cao, không khí oi bức'
                      : 'Khí áp bình thường',
                  size: 8,
                  color: UIColors.textSecondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
    }
  }
}
