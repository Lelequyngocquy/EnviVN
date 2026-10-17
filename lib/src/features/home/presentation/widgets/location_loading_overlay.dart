import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

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
    return PopScope(
      canPop: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Completely blocks any touch interaction on the screen below
          const ModalBarrier(
            dismissible: false,
            color: Colors.transparent,
          ),

          // 2. Full-Screen Backdrop Blur (Frosted Dark Glass)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.62),
            ),
          ),

          // 3. Floating Central Glass Card with Glowing Indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: UIColors.primary.withOpacity(0.24),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: AppGlass(
                  borderRadius: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Indicator: Rotating Circular Loader + Pulsing Pin
                      SizedBox(
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
                                backgroundColor: Color(0x1FFFFFFF),
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
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: UIColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Đang cập nhật vị trí',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Highlighted Target City Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: UIColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: UIColors.primary.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              color: UIColors.primary,
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.cityName,
                                style: const TextStyle(
                                  color: UIColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Explanatory Subtitle
                      Text(
                        widget.message ??
                            'Đang tải dữ liệu thời tiết & chỉ số không khí thời gian thực...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: UIColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Slim Accent Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: const SizedBox(
                          width: 130,
                          height: 3,
                          child: LinearProgressIndicator(
                            backgroundColor: Color(0x1FFFFFFF),
                            valueColor: AlwaysStoppedAnimation<Color>(UIColors.primary),
                          ),
                        ),
                      ),
                    ],
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
