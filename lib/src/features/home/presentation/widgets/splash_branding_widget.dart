import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/constants/strings.dart';

class SplashBrandingWidget extends StatelessWidget {
  const SplashBrandingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [UIColors.primary, Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: UIColors.primary.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 52,
            color: Color(0xFF0B1220),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.appSlogan,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: UIColors.textSecondary,
          ),
        ),
        const SizedBox(height: 36),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: UIColors.primary,
          ),
        ),
      ],
    );
  }
}
