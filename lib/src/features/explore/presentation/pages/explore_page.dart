import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/explore/domain/entities/explore_utility.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_divider.dart';
import '../widgets/utility_card.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFixedHeader(),

            Expanded(
              child: ClipRect(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.15,
                            ),
                        itemCount: ExploreUtility.values.length,
                        itemBuilder: (context, index) {
                          return UtilityCard.fromUtility(
                            utility: ExploreUtility.values[index],
                            context: context,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      color: UIColors.bg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText.bold(
                  'Khám phá',
                  size: 26,
                  color: UIColors.textPrimary,
                ),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: AppIcon.large(
                  Icons.auto_awesome_rounded,
                  color: UIColors.primary,
                ),
              ),
            ],
          ),
          AppDivider(title: 'tiện ích & tính năng mở rộng'),
        ],
      ),
    );
  }
}
