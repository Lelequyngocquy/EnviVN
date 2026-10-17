import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class HomeTopBar extends StatelessWidget {
  final String cityName;
  final bool isGps;
  final String dateText;
  final bool hasNotification;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  const HomeTopBar({
    super.key,
    required this.cityName,
    this.isGps = false,
    required this.dateText,
    this.hasNotification = true,
    required this.onLocationTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Dropdown in Liquid Glass Pill
            GestureDetector(
              onTap: onLocationTap,
              child: AppGlass(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGps ? Icons.my_location_rounded : Icons.location_on_rounded,
                      color: UIColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cityName,
                      style: const TextStyle(
                        color: UIColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: UIColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                dateText,
                style: const TextStyle(
                  fontSize: 12,
                  color: UIColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        // Notification Bell in Liquid Glass Button
        AppGlass(
          borderRadius: 22,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                  onPressed: onNotificationTap,
                ),
                if (hasNotification)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: UIColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
