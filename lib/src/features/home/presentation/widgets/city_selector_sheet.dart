import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class CitySelectorSheet extends StatefulWidget {
  final CityEntity currentCity;
  final ValueChanged<CityEntity> onCitySelected;
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
    final filteredCities = CityEntity.popularCities.where((city) {
      final q = _searchQuery.toLowerCase();
      return city.name.toLowerCase().contains(q) || city.province.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: UIColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Chọn khu vực theo dõi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          // Search Box in Dark Glass Style
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tỉnh/thành phố...',
              hintStyle: const TextStyle(color: UIColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: UIColors.textSecondary),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: UIColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // GPS Option Tile in Liquid Glass
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
                child: const Icon(Icons.my_location_rounded, color: UIColors.primary, size: 20),
              ),
              title: const Text(
                'Sử dụng vị trí hiện tại (GPS)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              subtitle: const Text(
                'Tự động cập nhật theo tọa độ GPS của máy',
                style: TextStyle(fontSize: 12, color: UIColors.textSecondary),
              ),
              trailing: widget.currentCity.isGps
                  ? const Icon(Icons.check_circle_rounded, color: UIColors.primary)
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tỉnh & Thành phố phổ biến:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: UIColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Cities List
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: filteredCities.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: Colors.white.withOpacity(0.08)),
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final isSelected = !widget.currentCity.isGps &&
                    widget.currentCity.latitude == city.latitude &&
                    widget.currentCity.longitude == city.longitude;

                return ListTile(
                  onTap: () {
                    widget.onCitySelected(city);
                    Navigator.pop(context);
                  },
                  title: Text(
                    city.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? UIColors.primary : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    city.province,
                    style: const TextStyle(fontSize: 12, color: UIColors.textSecondary),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: UIColors.primary)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
