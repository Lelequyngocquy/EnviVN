import 'package:flutter/material.dart';
import '../../../common/constants/colors.dart';
import 'app_icon.dart';
import 'app_text.dart';

class CustomErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(
              Icons.cloud_off_rounded,
              size: 64,
              color: UIColors.error,
            ),
            const SizedBox(height: 16),
            const AppText.bold(
              'Không thể tải dữ liệu',
              size: 16,
              color: UIColors.textPrimary,
            ),
            const SizedBox(height: 8),
            AppText.regular(
              message,
              textAlign: TextAlign.center,
              color: UIColors.textSecondary,
              size: 14,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.primary,
                  foregroundColor: UIColors.bg,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const AppIcon(Icons.refresh_rounded, size: 18, color: UIColors.bg),
                label: const AppText.bold('Thử lại', size: 14, color: UIColors.bg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
