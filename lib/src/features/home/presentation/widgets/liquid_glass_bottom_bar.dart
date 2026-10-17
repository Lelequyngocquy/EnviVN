import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class LiquidGlassBottomBar extends StatelessWidget {
  final int currentTab;
  final void Function(int index) onTabSelected;

  const LiquidGlassBottomBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlass(
      borderRadius: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavBarItem(
            icon: Icons.home_rounded,
            label: 'Trang chủ',
            isActive: currentTab == 0,
            onTap: () => onTabSelected(0),
          ),
          NavBarItem(
            icon: Icons.map_outlined,
            label: 'Bản đồ',
            isActive: currentTab == 1,
            onTap: () => onTabSelected(1),
          ),
          NavBarItem(
            icon: Icons.bar_chart_rounded,
            label: '24 Giờ',
            isActive: currentTab == 2,
            onTap: () => onTabSelected(2),
          ),
          NavBarItem(
            icon: Icons.tune_rounded,
            label: 'Cài đặt',
            isActive: currentTab == 3,
            onTap: () => onTabSelected(3),
          ),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? UIColors.primary : UIColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? UIColors.primary : UIColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
