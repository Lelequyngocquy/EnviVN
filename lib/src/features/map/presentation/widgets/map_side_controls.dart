import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/shared/widgets/app_button.dart';

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
        AppCircleButton(
          icon: hasPickedLocation
              ? Icons.location_off_rounded
              : Icons.zoom_out_map,
          iconColor: hasPickedLocation
              ? UIColors.pinPurple
              : isShowedAllVN
              ? UIColors.textSecondary.withOpacity(0.4)
              : UIColors.primary,
          onTap: hasPickedLocation ? onCancelPicker : onWholeCountry,
          tooltip: hasPickedLocation
              ? 'Hủy ghim vị trí'
              : 'Chưa có vị trí ghim',
        ),

        const Gap(10),
        AppCircleButton(
          icon: Icons.my_location_rounded,
          iconColor: UIColors.gpsBlue,
          tooltip: 'Vị trí hiện tại',
          onTap: onCurrentLocation,
        ),

        const Gap(10),
        AppCircleButton(
          icon: Icons.layers_rounded,
          iconColor: activeLayer.badgeColor,
          onTap: onToggleLayer,
          tooltip: 'Lớp bản đồ: ${activeLayer.label}',
          showDot: true,
          dotColor: activeLayer.badgeColor.withOpacity(0.9),
        ),
      ],
    );
  }
}
