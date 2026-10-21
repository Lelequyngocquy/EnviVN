import 'package:flutter/material.dart';

enum SafetyLevel {
  safe(
    label: 'An toàn & Lý tưởng',
    color: Color(0xFF00E676),
    icon: Icons.check_circle_rounded,
  ),
  caution(
    label: 'Cần lưu ý & Thận trọng',
    color: Color(0xFFFFD600),
    icon: Icons.info_rounded,
  ),
  warning(
    label: 'Cảnh báo nguy cơ',
    color: Color(0xFFFF9100),
    icon: Icons.warning_rounded,
  ),
  danger(
    label: 'Nguy hại - Không nên',
    color: Color(0xFFFF1744),
    icon: Icons.dangerous_rounded,
  );

  final String label;
  final Color color;
  final IconData icon;

  const SafetyLevel({
    required this.label,
    required this.color,
    required this.icon,
  });
}
