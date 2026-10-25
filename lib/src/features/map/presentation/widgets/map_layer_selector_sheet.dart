import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_bottom_sheet.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MapLayerSelectorSheet extends StatelessWidget {
  final MapLayerType currentLayer;
  final ValueChanged<MapLayerType> onLayerSelected;

  const MapLayerSelectorSheet({
    super.key,
    required this.currentLayer,
    required this.onLayerSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required MapLayerType currentLayer,
    required ValueChanged<MapLayerType> onLayerSelected,
  }) {
    return AppBottomSheet.show(
      context,
      title: 'Lớp dữ liệu bản đồ',
      subtitle: 'Chọn góc nhìn thời tiết & môi trường bạn muốn theo dõi',
      icon: Icons.layers_rounded,
      bottomButtonText: 'Đóng',
      child: MapLayerSelectorSheet(
        currentLayer: currentLayer,
        onLayerSelected: onLayerSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: MapLayerType.values.map((layer) {
        final isSelected = layer == currentLayer;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppGlass(
            borderRadius: 18,
            padding: EdgeInsets.zero,
            child: Material(
              color: UIColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  onLayerSelected(layer);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isSelected
                        ? layer.badgeColor.withOpacity(0.12)
                        : UIColors.white.withOpacity(0.02),
                    border: Border.all(
                      color: isSelected
                          ? layer.badgeColor.withOpacity(0.65)
                          : UIColors.cardGlassBorder,
                      width: isSelected ? 1.4 : 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: layer.badgeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: layer.badgeColor.withOpacity(0.4),
                            width: 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: layer.badgeColor.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: AppIcon(
                            layer.icon,
                            color: layer.badgeColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const Gap(14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: AppText.bold(
                                    layer.label,
                                    size: 14,
                                    color: isSelected
                                        ? UIColors.textPrimary
                                        : UIColors.textSecondary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (layer == MapLayerType.weather) ...[
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: UIColors.secondary.withOpacity(
                                        0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const AppText.bold(
                                      'Mặc định',
                                      size: 9.5,
                                      color: UIColors.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(3),
                            AppText.regular(
                              layer.description,
                              size: 11.5,
                              color: UIColors.textSecondary,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const Gap(10),

                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? layer.badgeColor
                              : UIColors.white.withOpacity(0.08),
                          border: Border.all(
                            color: isSelected
                                ? layer.badgeColor
                                : UIColors.white.withOpacity(0.2),
                            width: 1.2,
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: AppIcon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: UIColors.bg,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
