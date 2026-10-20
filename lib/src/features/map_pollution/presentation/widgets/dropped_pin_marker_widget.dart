import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class DroppedPinMarkerWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const DroppedPinMarkerWidget({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [UIColors.pinPurple, UIColors.pinPurpleDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: UIColors.white, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: UIColors.pinPurple.withOpacity(0.65),
                blurRadius: 10,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: UIColors.black.withOpacity(0.35),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        UIColors.white,
                      ),
                    ),
                  )
                : const AppIcon(
                    Icons.pin_drop_rounded,
                    color: UIColors.white,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
