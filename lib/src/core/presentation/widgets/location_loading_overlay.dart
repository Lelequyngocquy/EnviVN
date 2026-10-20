import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_dialog.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';

/// Lớp phủ hiệu ứng kính mờ (Glass Overlay) hiển thị trong quá trình đổi vị trí GPS / Thành phố.
/// Được xây dựng hoàn toàn dựa trên [AppDialog] dùng chung của core widgets.
class LocationLoadingOverlay extends StatefulWidget {
  final String cityName;
  final String? message;

  const LocationLoadingOverlay({
    super.key,
    required this.cityName,
    this.message,
  });

  @override
  State<LocationLoadingOverlay> createState() => _LocationLoadingOverlayState();
}

class _LocationLoadingOverlayState extends State<LocationLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      canPop: false,
      barrierDismissible: false,
      showButtons: false,
      glowColor: UIColors.primary.withOpacity(0.24),
      header: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ambient Glow Ring
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: UIColors.primary.withOpacity(0.08),
              ),
            ),

            // Circular Progress Spinner
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(UIColors.primary),
                backgroundColor: UIColors.cardGlass,
              ),
            ),

            // Breathing Pin in Center
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: UIColors.primary.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const AppIcon(
                  Icons.location_on_rounded,
                  color: UIColors.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
      title: 'Đang cập nhật vị trí',
      childrenWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Highlighted Target City Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: UIColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: UIColors.primary.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(
                  Icons.near_me_rounded,
                  color: UIColors.primary,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: AppText.bold(
                    widget.cityName,
                    color: UIColors.primary,
                    size: 13,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Explanatory Subtitle
          AppText.regular(
            widget.message ??
                'Đang tải dữ liệu thời tiết & chỉ số không khí thời gian thực...',
            textAlign: TextAlign.center,
            size: 12,
            color: UIColors.textSecondary,
            height: 1.45,
          ),
        ],
      ),
    );
  }
}
