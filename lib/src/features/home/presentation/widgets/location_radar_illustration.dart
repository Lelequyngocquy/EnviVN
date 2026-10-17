import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

class LocationRadarIllustration extends StatelessWidget {
  const LocationRadarIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse 1
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
            // Pulse 2
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIColors.primary.withOpacity(0.35),
                  width: 2,
                ),
              ),
            ),
            // Pulse 3
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIColors.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
            // Shadow beneath pin
            Positioned(
              bottom: 70,
              child: Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Main Pin
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: UIColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: UIColors.primary.withOpacity(0.6),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
