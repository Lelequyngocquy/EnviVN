import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_bottom_sheet.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:gap/gap.dart';

class CitySelectorSheet extends StatefulWidget {
  final AppLocationEntity currentCity;
  final ValueChanged<AppLocationEntity> onCitySelected;
  final VoidCallback onSelectGps;

  const CitySelectorSheet({
    super.key,
    required this.currentCity,
    required this.onCitySelected,
    required this.onSelectGps,
  });

  @override
  State<CitySelectorSheet> createState() => _CitySelectorSheetState();
}

class _CitySelectorSheetState extends State<CitySelectorSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCities = AppLocationEntity.popularLocations.where((city) {
      final q = _searchQuery.toLowerCase();
      return city.name.toLowerCase().contains(q) ||
          city.province.toLowerCase().contains(q);
    }).toList();

    return AppBottomSheet(
      title: 'Chọn khu vực theo dõi',
      maxHeightFactor: 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: UIColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tỉnh/thành phố...',
              hintStyle: const TextStyle(color: UIColors.textMuted),
              prefixIcon: const AppIcon(
                Icons.search,
                color: UIColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: UIColors.white.withOpacity(0.07),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: UIColors.white.withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: UIColors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: UIColors.primary),
              ),
            ),
          ),
          const Gap(14),

          AppGlass(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: ListTile(
              onTap: () {
                Navigator.pop(context);
                widget.onSelectGps();
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: UIColors.primary.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const AppIcon(
                  Icons.my_location_rounded,
                  color: UIColors.primary,
                  size: 20,
                ),
              ),
              title: const AppText.bold(
                'Sử dụng vị trí hiện tại (GPS)',
                size: 14,
                color: UIColors.textPrimary,
              ),
              subtitle: const AppText.regular(
                'Tự động cập nhật theo tọa độ GPS của máy',
                size: 12,
                color: UIColors.textSecondary,
              ),
              trailing: widget.currentCity.isGps
                  ? const AppIcon(
                      Icons.check_circle_rounded,
                      color: UIColors.primary,
                    )
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Gap(16),
          const AppText.bold(
            'Tỉnh & Thành phố phổ biến:',
            size: 12,
            color: UIColors.textSecondary,
          ),
          const Gap(8),

          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: filteredCities.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: UIColors.white.withOpacity(0.08)),
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final isSelected =
                    !widget.currentCity.isGps &&
                    widget.currentCity.latitude == city.latitude &&
                    widget.currentCity.longitude == city.longitude;

                return ListTile(
                  onTap: () {
                    widget.onCitySelected(city);
                    Navigator.pop(context);
                  },
                  title: AppText(
                    city.name,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? UIColors.primary : UIColors.textPrimary,
                  ),
                  subtitle: AppText.regular(
                    city.province,
                    size: 12,
                    color: UIColors.textSecondary,
                  ),
                  trailing: isSelected
                      ? const AppIcon(
                          Icons.check_circle_rounded,
                          color: UIColors.primary,
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
