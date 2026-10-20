import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/map_layer_type.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';

class MapSideControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final bool hasPickedLocation;
  final VoidCallback onCancelPicker;
  final VoidCallback onToggleLayer;
  final VoidCallback onWholeCountry;
  final MapLayerType activeLayer;
  final bool isShowedAllVN;

  const MapSideControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.hasPickedLocation,
    required this.onCancelPicker,
    required this.onToggleLayer,
    required this.activeLayer,
    required this.onWholeCountry,
    this.isShowedAllVN = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Zoom Controls Cluster
        AppGlass(
          isFixed: true,
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: UIColors.transparent,
                child: InkWell(
                  onTap: onZoomIn,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 36,
                    height: 38,
                    child: Center(
                      child: AppIcon(
                        Icons.add_rounded,
                        color: UIColors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 1,
                color: UIColors.white.withOpacity(0.12),
              ),
              Material(
                color: UIColors.transparent,
                child: InkWell(
                  onTap: onZoomOut,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 36,
                    height: 38,
                    child: Center(
                      child: AppIcon(
                        Icons.remove_rounded,
                        color: UIColors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        // 2. Cancel Dropped Pin Button (Hiển thị cố định, disable & chuyển xám khi không có ghim)
        AppGlass(
          isFixed: true,
          borderRadius: 50,
          padding: const EdgeInsets.all(4),
          child: Material(
            color: UIColors.transparent,
            child: Tooltip(
              message: hasPickedLocation
                  ? 'Hủy ghim vị trí'
                  : 'Chưa có vị trí ghim',
              child: InkWell(
                onTap: hasPickedLocation ? onCancelPicker : onWholeCountry,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 36,
                  height: 38,
                  alignment: Alignment.center,
                  child: AppIcon(
                    hasPickedLocation
                        ? Icons.location_off_rounded
                        : Icons.zoom_out_map,
                    color: hasPickedLocation
                        ? UIColors.pinPurple
                        : isShowedAllVN
                        ? UIColors.textSecondary.withOpacity(0.4)
                        : UIColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
        // 3. Layer Selector Button (Chạm mở BottomSheet đổi 1 trong 4 loại Map)
        AppGlass(
          isFixed: true,
          borderRadius: 50,
          padding: const EdgeInsets.all(4),
          child: Material(
            color: UIColors.transparent,
            child: Tooltip(
              message: 'Lớp bản đồ: ${activeLayer.label}',
              child: InkWell(
                onTap: onToggleLayer,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 36,
                  height: 38,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AppIcon(
                        Icons.layers_rounded,
                        color: activeLayer.badgeColor,
                        size: 20,
                      ),
                      Positioned(
                        right: 1,
                        top: 2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: activeLayer.badgeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeLayer.badgeColor.withOpacity(0.9),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
