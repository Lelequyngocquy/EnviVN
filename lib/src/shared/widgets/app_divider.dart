import 'package:flutter/material.dart';

import '../../common/constants/colors.dart';
import '../../core/presentation/widgets/app_text.dart';
import 'package:gap/gap.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText.bold(
            (title ?? '').toUpperCase(),
            size: 12,
            letterSpacing: 0.8,
            color: UIColors.textMuted,
          ),
          const Gap(12),
          const Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: UIColors.surfaceVariant,
            ),
          ),
        ],
      );
    } else {
      return Divider(height: 1, thickness: 1, color: UIColors.surfaceVariant);
    }
  }
}
