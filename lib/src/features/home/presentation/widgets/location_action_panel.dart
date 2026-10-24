import 'package:envivn/src/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';

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
    return AppTwoButtons(
      primaryTitle: primaryButtonText,
      primaryOnTap: onAllow,
      isLoading: isLoading,
      secondaryTitle: secondaryButtonText,
      secondaryOnTap: onSkip,
    );
  }
}
