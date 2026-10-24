import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HeroAQICard extends StatefulWidget {
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
  State<HeroAQICard> createState() => _HeroAQICardState();
}

class _HeroAQICardState extends State<HeroAQICard> {
  int _selectedIndex = 0;

  DateTime _getTimeAt(int index) {
    if (widget.airQuality.hourlyAqi.length > index) {
      return widget.airQuality.hourlyAqi[index].time;
    }
    return DateTime.now().add(Duration(hours: index));
  }

  int _getAqiAt(int index) {
    if (widget.airQuality.hourlyAqi.length > index) {
      return widget.airQuality.hourlyAqi[index].aqi;
    }
    final base = widget.airQuality.usAqi > 0 ? widget.airQuality.usAqi : 72;
    return (base + ((index % 6) - 2) * 4).clamp(15, 300);
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatHour(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    return '${h}h';
  }

  @override
  Widget build(BuildContext context) {
    final currentAqi = widget.airQuality.usAqi > 0
        ? widget.airQuality.usAqi
        : 72;
    final currentAqiInfo = AQIHelper.getAQIInfo(currentAqi);
    final pm25Val = widget.airQuality.pm25 > 0 ? widget.airQuality.pm25 : 22.1;
    final pm10Val = widget.airQuality.pm10 > 0 ? widget.airQuality.pm10 : 45.0;

    final activeAqi = _getAqiAt(_selectedIndex);
    final activeInfo = AQIHelper.getAQIInfo(activeAqi);
    final activeTime = _getTimeAt(_selectedIndex);

    return AppGlass(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText.bold(
                'CHỈ SỐ CHẤT LƯỢNG KHÔNG KHÍ',
                size: 11,
                letterSpacing: 0.8,
                color: UIColors.textSecondary,
              ),
              AppIcon(
                Icons.bubble_chart_rounded,
                color: currentAqiInfo.color,
                size: 20,
              ),
            ],
          ),
          const Gap(14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppText.extraBold(
                  '$currentAqi',
                  size: 54,
                  color: UIColors.textPrimary,
                  height: 1.0,
                  maxLines: 3,
                ),
              ),
              const Gap(14),

              AppStatusTag(
                label: currentAqiInfo.label,
                color: currentAqiInfo.color,
                size: AppTagSize.large,
              ),
            ],
          ),
          const Gap(12),

          AppText.medium(
            'PM2.5: ${pm25Val.toStringAsFixed(1)} µg/m³  •  PM10: ${pm10Val.toStringAsFixed(1)} µg/m³',
            size: 12,
            color: UIColors.textSecondary,
          ),
          const Gap(18),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: activeInfo.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeInfo.color.withOpacity(0.8),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppText.bold(
                                _selectedIndex == 0
                                    ? 'Hiện tại (${_formatTime(activeTime)})'
                                    : '+${_selectedIndex}h (${_formatTime(activeTime)})',
                                size: 11,
                                color: UIColors.textPrimary,
                              ),
                              const Gap(2),
                              AppText.bold(
                                'AQI $activeAqi (${activeInfo.label})',
                                size: 11,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color: activeInfo.color,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  GestureDetector(
                    onTap: () {
                      if (_selectedIndex != 0) {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AppText.regular(
                      _selectedIndex == 0 ? 'Dự báo 24 giờ' : 'Về hiện tại',
                      size: 11,
                      color: _selectedIndex == 0
                          ? UIColors.textSecondary
                          : UIColors.primary,
                    ),
                  ),
                ],
              ),
              const Gap(10),

              SizedBox(
                height: 34,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(24, (i) {
                    final isSelected = i == _selectedIndex;
                    final isNow = i == 0;
                    final aqi = _getAqiAt(i);
                    final info = AQIHelper.getAQIInfo(aqi);
                    final factor = (aqi / 200).clamp(0.25, 1.0);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = i;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 1.2),
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            height: isSelected ? 34 * factor + 3 : 30 * factor,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? info.color
                                  : info.color.withOpacity(isNow ? 0.95 : 0.75),
                              borderRadius: BorderRadius.circular(3),
                              border: isSelected
                                  ? Border.all(
                                      color: UIColors.white,
                                      width: 1.4,
                                    )
                                  : (isNow
                                        ? Border.all(
                                            color: UIColors.white.withOpacity(
                                              0.55,
                                            ),
                                            width: 0.8,
                                          )
                                        : null),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: info.color.withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const Gap(8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimelineMilestone(
                    label: 'Hiện tại',
                    timeText: _formatHour(_getTimeAt(0)),
                    isHighlighted: _selectedIndex == 0,
                    alignment: CrossAxisAlignment.start,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _buildTimelineMilestone(
                    label: '+6h',
                    timeText: _formatHour(_getTimeAt(6)),
                    isHighlighted: _selectedIndex == 6,
                    alignment: CrossAxisAlignment.center,
                    onTap: () => setState(() => _selectedIndex = 6),
                  ),
                  _buildTimelineMilestone(
                    label: '+12h',
                    timeText: _formatHour(_getTimeAt(12)),
                    isHighlighted: _selectedIndex == 12,
                    alignment: CrossAxisAlignment.center,
                    onTap: () => setState(() => _selectedIndex = 12),
                  ),
                  _buildTimelineMilestone(
                    label: '+18h',
                    timeText: _formatHour(_getTimeAt(18)),
                    isHighlighted: _selectedIndex == 18,
                    alignment: CrossAxisAlignment.center,
                    onTap: () => setState(() => _selectedIndex = 18),
                  ),
                  _buildTimelineMilestone(
                    label: '+24h',
                    timeText: _formatHour(_getTimeAt(23)),
                    isHighlighted: _selectedIndex == 23,
                    alignment: CrossAxisAlignment.end,
                    onTap: () => setState(() => _selectedIndex = 23),
                  ),
                ],
              ),
            ],
          ),

          const Gap(14),
          const Divider(height: 1, color: UIColors.surfaceVariant),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.regular(
                widget.updateTimeText,
                size: 11,
                color: UIColors.textMuted,
              ),
              if (widget.onDetailTap != null)
                GestureDetector(
                  onTap: widget.onDetailTap,
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

  Widget _buildTimelineMilestone({
    required String label,
    required String timeText,
    required bool isHighlighted,
    required CrossAxisAlignment alignment,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.bold(
            timeText,
            size: 11,
            color: isHighlighted ? UIColors.primary : UIColors.textSecondary,
          ),
          const Gap(1),
          AppText.medium(
            label,
            size: 9.5,
            color: isHighlighted ? UIColors.primary : UIColors.textMuted,
          ),
        ],
      ),
    );
  }
}
