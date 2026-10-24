import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/shared/widgets/app_button.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeTopBar extends StatelessWidget {
  final String cityName;
  final bool isGps;
  final String dateText;
  final bool hasNotification;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onSelectCurrentLocation;
  final bool? showCurrentLocationSuggestion;

  const HomeTopBar({
    super.key,
    required this.cityName,
    this.isGps = false,
    required this.dateText,
    this.hasNotification = true,
    required this.onLocationTap,
    required this.onNotificationTap,
    this.onSelectCurrentLocation,
    this.showCurrentLocationSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentLocation =
        isGps || cityName.trim().toLowerCase().contains('vị trí hiện tại');
    final shouldShowSuggestion =
        showCurrentLocationSuggestion ??
        (!isCurrentLocation && onSelectCurrentLocation != null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onLocationTap,
                      child: AppGlass(
                        isFixed: true,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(
                              isGps
                                  ? Icons.my_location_rounded
                                  : Icons.location_on_rounded,
                              color: UIColors.primary,
                              size: 16,
                            ),
                            const Gap(6),
                            AppText.bold(
                              cityName,
                              color: UIColors.textPrimary,
                              size: 14,
                            ),
                            const Gap(4),
                            const AppIcon(
                              Icons.keyboard_arrow_down_rounded,
                              color: UIColors.textSecondary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (shouldShowSuggestion) ...[
                      const Gap(8),
                      AppCircleButton(
                        icon: Icons.my_location_rounded,
                        onTap: onSelectCurrentLocation,
                        iconSize: 16,
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AppText.medium(
                  dateText,
                  color: UIColors.textSecondary,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        AppCircleButton(
          icon: Icons.notifications_none_rounded,
          iconColor: UIColors.textPrimary,
          iconSize: 22,
          onTap: onNotificationTap,
          showDot: hasNotification,
          isLoading: false,
        ),
      ],
    );
  }
}
