import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/quick_city_target.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class MapTopControlBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final bool showHeatmap;
  final VoidCallback onToggleHeatmap;
  final String? selectedCityName;
  final ValueChanged<String> onSelectCity;
  final VoidCallback onSelectAllVietnam;
  final String? homeCityName;
  final VoidCallback? onSelectHomeCity;
  final bool isHomeSelected;
  final List<QuickCityTarget> quickCities;
  final ValueChanged<QuickCityTarget>? onSelectQuickCity;

  const MapTopControlBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.showHeatmap,
    required this.onToggleHeatmap,
    this.selectedCityName,
    required this.onSelectCity,
    required this.onSelectAllVietnam,
    this.homeCityName,
    this.onSelectHomeCity,
    this.isHomeSelected = false,
    this.quickCities = QuickCityTarget.values,
    this.onSelectQuickCity,
  });

  @override
  Widget build(BuildContext context) {
    final curCity = selectedCityName ?? '';
    final hasHome = homeCityName != null && homeCityName!.isNotEmpty;

    // Loại bỏ khỏi danh sách các chip nếu thành phố đó đã được ghim ở đầu
    final effectiveQuickCities = hasHome
        ? quickCities
              .where((target) => !target.matchesPinnedLocation(homeCityName))
              .toList()
        : quickCities;

    return Column(
      children: [
        // 1. Filter Glass Bar
        AppGlass(
          isFixed: true,
          borderRadius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              const AppIcon(
                Icons.filter_alt_rounded,
                color: UIColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterGlassChip(
                        label: 'Tất cả',
                        isActive: activeFilter == 'all',
                        onTap: () => onFilterChanged('all'),
                      ),
                      const SizedBox(width: 6),
                      _FilterGlassChip(
                        label: 'Tốt',
                        isActive: activeFilter == 'good',
                        onTap: () => onFilterChanged('good'),
                      ),
                      const SizedBox(width: 6),
                      _FilterGlassChip(
                        label: 'Trung bình',
                        isActive: activeFilter == 'moderate',
                        onTap: () => onFilterChanged('moderate'),
                      ),
                      const SizedBox(width: 6),
                      _FilterGlassChip(
                        label: 'Kém',
                        isActive:
                            activeFilter == 'unhealthy' ||
                            activeFilter == 'warning',
                        onTap: () => onFilterChanged('unhealthy'),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: AppIcon(
                  showHeatmap ? Icons.blur_on_rounded : Icons.blur_off_rounded,
                  color: showHeatmap
                      ? UIColors.primary
                      : UIColors.textSecondary,
                ),
                onPressed: onToggleHeatmap,
                tooltip: 'Bật/Tắt Heatmap',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. Quick Jump City Pills with Active Selection Highlighting in ListView
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: (hasHome ? 1 : 0) + effectiveQuickCities.length,
            separatorBuilder: (_, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              if (hasHome && index == 0) {
                final isHomeActive =
                    isHomeSelected ||
                    (curCity.isNotEmpty &&
                        (curCity == homeCityName ||
                            curCity.contains(homeCityName!) ||
                            homeCityName!.contains(curCity)));
                return _QuickCityGlassChip(
                  icon: Icons.my_location_rounded,
                  label: homeCityName!,
                  isActive: isHomeActive,
                  onTap: onSelectHomeCity ?? () => onSelectCity(homeCityName!),
                );
              }

              final targetIndex = hasHome ? index - 1 : index;
              final target = effectiveQuickCities[targetIndex];
              final isTargetActive =
                  !isHomeSelected && target.isSelected(curCity);
              return _QuickCityGlassChip(
                label: target.label,
                isActive: isTargetActive,
                onTap: () {
                  if (onSelectQuickCity != null) {
                    onSelectQuickCity!(target);
                  } else if (target.isAllCountry) {
                    onSelectAllVietnam();
                  } else {
                    onSelectCity(target.label);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterGlassChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterGlassChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? UIColors.primary : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? UIColors.primary : Colors.white.withOpacity(0.2),
          ),
        ),
        child: AppText.bold(
          label,
          size: 12,
          color: isActive ? const Color(0xFF0B1220) : Colors.white,
        ),
      ),
    );
  }
}

class _QuickCityGlassChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  const _QuickCityGlassChip({
    required this.label,
    this.isActive = false,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? UIColors.primary : Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? UIColors.primary : Colors.white.withOpacity(0.18),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(
                icon!,
                size: 13,
                color: isActive ? const Color(0xFF0B1220) : UIColors.primary,
              ),
              const SizedBox(width: 4),
            ],
            AppText(
              label,
              size: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? const Color(0xFF0B1220) : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
