import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

enum DetailTab { all, weather, airQuality }

class DetailSegmentedFilter extends StatelessWidget {
  final DetailTab activeTab;
  final ValueChanged<DetailTab> onTabChanged;

  const DetailSegmentedFilter({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
      ),
      child: Row(
        children: [
          _buildFilterPill('📊 Tất cả', DetailTab.all),
          _buildFilterPill('🌤️ Thời tiết', DetailTab.weather),
          _buildFilterPill('🍃 Không khí (AQI)', DetailTab.airQuality),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title, DetailTab tab) {
    final isSelected = activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (tab == DetailTab.weather
                      ? UIColors.secondary.withOpacity(0.22)
                      : (tab == DetailTab.airQuality
                            ? UIColors.primary.withOpacity(0.22)
                            : Colors.white.withOpacity(0.12)))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (tab == DetailTab.weather
                        ? UIColors.secondary.withOpacity(0.5)
                        : (tab == DetailTab.airQuality
                              ? UIColors.primary.withOpacity(0.5)
                              : Colors.white.withOpacity(0.25)))
                  : Colors.transparent,
              width: 0.8,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (tab == DetailTab.weather
                        ? UIColors.secondary
                        : (tab == DetailTab.airQuality
                              ? UIColors.primary
                              : Colors.white))
                  : UIColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
