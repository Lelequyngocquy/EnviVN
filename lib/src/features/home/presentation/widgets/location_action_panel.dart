import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:gap/gap.dart';

class LocationActionPanel extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onSkip;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final bool isLoading;

  const LocationActionPanel({
    super.key,
    required this.onAllow,
    required this.onSkip,
    this.primaryButtonText = 'Cho phép truy cập vị trí',
    this.secondaryButtonText = 'Để sau (Chọn thành phố thủ công)',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onAllow,
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.primary,
                foregroundColor: UIColors.bg,
                disabledBackgroundColor: UIColors.primary.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: UIColors.bg,
                      ),
                    )
                  : AppText.bold(
                      primaryButtonText,
                      size: 15,
                      color: UIColors.bg,
                    ),
            ),
          ),
          if (secondaryButtonText != null &&
              secondaryButtonText!.isNotEmpty) ...[
            const Gap(8),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: isLoading ? null : onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: UIColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: AppText.semiBold(
                  secondaryButtonText!,
                  size: 14,
                  color: UIColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
