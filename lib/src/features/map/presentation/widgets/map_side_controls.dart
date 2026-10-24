import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';

class MapSideControls extends StatelessWidget {
  final bool hasPickedLocation;
  final VoidCallback onCancelPicker;
  final VoidCallback onCurrentLocation;
  final VoidCallback onToggleLayer;
  final VoidCallback onWholeCountry;
  final MapLayerType activeLayer;
  final bool isShowedAllVN;
  final bool isHomeSelected;

  const MapSideControls({
    super.key,
    required this.hasPickedLocation,
    required this.onCancelPicker,
    required this.onCurrentLocation,
    required this.onToggleLayer,
    required this.activeLayer,
    required this.onWholeCountry,
    this.isShowedAllVN = false,
    this.isHomeSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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

        const Gap(10),

        AppGlass(
          isFixed: true,
          borderRadius: 50,
          padding: const EdgeInsets.all(4),
          child: Material(
            color: UIColors.transparent,
            child: Tooltip(
              message: 'Vị trí hiện tại',
              child: InkWell(
                onTap: onCurrentLocation,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 36,
                  height: 38,
                  alignment: Alignment.center,
                  child: AppIcon(
                    Icons.my_location_rounded,
                    color: UIColors.gpsBlue,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
        ),

        const Gap(10),

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
