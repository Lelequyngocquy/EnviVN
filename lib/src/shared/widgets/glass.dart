import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../common/constants/colors.dart';

class AppGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isFigma;
  final Color? color;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isFixed;
  final bool enableBlur;

  const AppGlass({
    super.key,
    required this.child,
    required this.borderRadius,
    this.isFigma = true,
    this.color,
    this.border,
    this.padding,
    this.margin,
    this.isFixed = false,
    this.enableBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    Widget glassBackground;

    if (isFixed) {
      glassBackground = LiquidGlassLayer(
        fake: false,
        settings: LiquidGlassSettings.figma(
          refraction: 85,
          depth: 24,
          dispersion: 45,
          frost: 3,
          lightAngle: -pi / 4,
          lightIntensity: 65,
          glassColor: color ?? UIColors.white.withValues(alpha: 0.04),
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
          child: const SizedBox.expand(),
        ),
      );
    } else {
      final innerBox = Container(
        decoration: BoxDecoration(
          color: color ?? UIColors.cardBg.withOpacity(0.85),
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              UIColors.white.withOpacity(0.12),
              UIColors.white.withOpacity(0.03),
              UIColors.white.withOpacity(0.06),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      );

      glassBackground = enableBlur
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 16,
                sigmaY: 16,
                tileMode: TileMode.mirror,
              ),
              child: innerBox,
            )
          : innerBox;
    }

    final glassWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ??
            Border.all(
              color: UIColors.white.withValues(alpha: isFixed ? 0.0 : 0.14),
              width: 0.8,
            ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(child: glassBackground),

            content,
          ],
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: glassWidget);
    }

    return glassWidget;
  }
}
