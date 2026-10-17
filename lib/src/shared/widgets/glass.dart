import 'dart:ui';
import 'package:flutter/material.dart';

class AppGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isFigma;
  final Color? color;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppGlass({
    super.key,
    required this.child,
    required this.borderRadius,
    this.isFigma = true,
    this.color,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    Widget glassContainer = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1.0,
                ),
          ),
          child: content,
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: glassContainer);
    }

    return glassContainer;
  }
}
