import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class MapShortcutCard extends StatelessWidget {
  final VoidCallback onTap;

  const MapShortcutCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppGlass(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UIColors.secondary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_rounded, color: UIColors.secondary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bản đồ trạm quan trắc',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: UIColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Xem các trạm quan trắc chất lượng không khí trên toàn quốc',
                    style: TextStyle(fontSize: 11, color: UIColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: UIColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
