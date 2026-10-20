import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

/// Đại diện cho 4 chế độ bản đồ trên EnviVN
/// Đóng vai trò là Single Source of Truth cho các layer bản đồ
enum MapLayerType {
  weather(
    label: 'Thời tiết',
    shortLabel: 'Thời tiết',
    description: 'Nắng, mưa, bão, độ ẩm & nhiệt độ thời gian thực',
    icon: Icons.wb_sunny_rounded,
    badgeColor: UIColors.secondary,
  ),
  airQuality(
    label: 'Chất lượng không khí',
    shortLabel: 'Không khí',
    description: 'Chỉ số ô nhiễm AQI, bụi mịn PM2.5 & PM10 chuyên sâu',
    icon: Icons.air_rounded,
    badgeColor: UIColors.primary,
  ),
  thermal(
    label: 'Nhiệt độ & Điểm cháy',
    shortLabel: 'Nhiệt & Cháy',
    description: 'Chỉ số sốc nhiệt Heat Index, tia UV & điểm nhiệt vệ tinh',
    icon: Icons.local_fire_department_rounded,
    badgeColor: UIColors.warning,
  ),
  flood(
    label: 'Nguy cơ ngập úng',
    shortLabel: 'Ngập úng',
    description: 'Lượng mưa lớn cục bộ & mạng lưới điểm đen ngập đô thị',
    icon: Icons.water_rounded,
    badgeColor: UIColors.gpsBlue,
  );

  final String label;
  final String shortLabel;
  final String description;
  final IconData icon;
  final Color badgeColor;

  const MapLayerType({
    required this.label,
    required this.shortLabel,
    required this.description,
    required this.icon,
    required this.badgeColor,
  });
}
