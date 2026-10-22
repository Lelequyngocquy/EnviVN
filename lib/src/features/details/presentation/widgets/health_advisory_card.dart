import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class HealthAdvisoryCard extends StatelessWidget {
  const HealthAdvisoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGlass(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: UIColors.warning.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const AppIcon(
              Icons.warning_amber_rounded,
              color: UIColors.warning,
              size: 24,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppText.bold(
                  'Khuyến cáo sức khỏe 24h',
                  size: 14,
                  color: UIColors.textPrimary,
                ),
                Gap(6),
                AppText.regular(
                  'Khung giờ 14:00 - 18:00 chất lượng không khí đạt trạng thái trong lành nhất trong ngày, rất thích hợp cho chạy bộ, đạp xe và thông gió nhà cửa.',
                  size: 12,
                  color: UIColors.textSecondary,
                  height: 1.45,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
