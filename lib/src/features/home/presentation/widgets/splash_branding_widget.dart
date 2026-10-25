import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/constants/strings.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:gap/gap.dart';

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
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: UIColors.primary.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/png/app_logo/envivn_logo.png',
            fit: BoxFit.cover,
          ),
        ),
        const Gap(24),
        const AppText.extraBold(
          AppStrings.appName,
          size: 34,
          color: UIColors.textPrimary,
          letterSpacing: 2.0,
        ),
        const Gap(6),
        const AppText.medium(
          AppStrings.appSlogan,
          size: 13,
          color: UIColors.textSecondary,
        ),
        const Gap(36),
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
