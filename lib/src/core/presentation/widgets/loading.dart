import 'package:flutter/material.dart';
import '../../../common/constants/colors.dart';
import 'app_text.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: UIColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            AppText.medium(
              message!,
              color: UIColors.textSecondary,
              size: 14,
            ),
          ],
        ],
      ),
    );
  }
}
