import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class MapZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlass(
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
    );
  }
}
