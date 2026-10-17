import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class MapTopControlBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final bool showHeatmap;
  final VoidCallback onToggleHeatmap;
  final String? selectedCityName;
  final ValueChanged<String> onSelectCity;
  final VoidCallback onSelectAllVietnam;

  const MapTopControlBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.showHeatmap,
    required this.onToggleHeatmap,
    this.selectedCityName,
    required this.onSelectCity,
    required this.onSelectAllVietnam,
  });

  @override
  Widget build(BuildContext context) {
    final curCity = selectedCityName ?? '';

    return Column(
      children: [
        // 1. Filter Glass Bar
        AppGlass(
          borderRadius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              const Icon(
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
                icon: Icon(
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

        // 2. Quick Jump City Pills with Active Selection Highlighting
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickCityGlassChip(
                label: 'Toàn quốc',
                isActive: curCity == 'Toàn quốc',
                onTap: onSelectAllVietnam,
              ),
              const SizedBox(width: 6),
              _QuickCityGlassChip(
                label: 'Hà Nội',
                isActive: curCity.contains('Hà Nội'),
                onTap: () => onSelectCity('Hà Nội'),
              ),
              const SizedBox(width: 6),
              _QuickCityGlassChip(
                label: 'Đà Nẵng',
                isActive: curCity.contains('Đà Nẵng'),
                onTap: () => onSelectCity('Đà Nẵng'),
              ),
              const SizedBox(width: 6),
              _QuickCityGlassChip(
                label: 'TP. Hồ Chí Minh',
                isActive:
                    curCity.contains('Hồ Chí Minh') ||
                    curCity.contains('Quận 1'),
                onTap: () => onSelectCity('TP. Hồ Chí Minh'),
              ),
              const SizedBox(width: 6),
              _QuickCityGlassChip(
                label: 'Hải Phòng',
                isActive: curCity.contains('Hải Phòng'),
                onTap: () => onSelectCity('Hải Phòng'),
              ),
            ],
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF0B1220) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _QuickCityGlassChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickCityGlassChip({
    required this.label,
    this.isActive = false,
    required this.onTap,
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? const Color(0xFF0B1220) : Colors.white,
          ),
        ),
      ),
    );
  }
}
