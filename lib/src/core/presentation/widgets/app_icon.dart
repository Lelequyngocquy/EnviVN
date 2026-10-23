import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

/// Widget biểu tượng quy chuẩn cho toàn bộ ứng dụng EnviVN (AppIcon).
///
/// Tích hợp trực tiếp hệ màu [UIColors], tránh gây bất đồng bộ khi phải
/// chọn Colors gốc của Flutter và đảm bảo icon luôn có kích thước & màu sắc
/// mặc định hài hòa với phong cách Liquid Glass Dark Theme.
///
/// Các hàm tạo tiện ích:
/// - [AppIcon]: Mặc định cỡ 20.0, màu [UIColors.textPrimary]
/// - [AppIcon.small]: Cỡ nhỏ 14.0
/// - [AppIcon.medium]: Cỡ vừa 20.0
/// - [AppIcon.large]: Cỡ lớn 28.0
/// - [AppIcon.primary]: Màu chủ đạo [UIColors.primary]
/// - [AppIcon.secondary]: Màu phụ [UIColors.textSecondary]
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final List<Shadow>? shadows;

  /// Khởi tạo icon chuẩn với kích thước mặc định 20.0 và màu [UIColors.textPrimary].
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 20.0,
    this.color = UIColors.textPrimary,
    this.semanticLabel,
    this.textDirection,
    this.shadows,
  });

  /// Icon kích thước nhỏ (14.0)
  const AppIcon.small(
    this.icon, {
    super.key,
    this.size = 14.0,
    this.color = UIColors.textPrimary,
    this.semanticLabel,
    this.textDirection,
    this.shadows,
  });

  /// Icon kích thước lớn (28.0)
  const AppIcon.large(
    this.icon, {
    super.key,
    this.size = 28.0,
    this.color = UIColors.textPrimary,
    this.semanticLabel,
    this.textDirection,
    this.shadows,
  });

  /// Icon màu chủ đạo [UIColors.primary]
  const AppIcon.primary(
    this.icon, {
    super.key,
    this.size = 20.0,
    this.color = UIColors.primary,
    this.semanticLabel,
    this.textDirection,
    this.shadows,
  });

  /// Icon màu phụ [UIColors.textSecondary]
  const AppIcon.secondary(
    this.icon, {
    super.key,
    this.size = 20.0,
    this.color = UIColors.textSecondary,
    this.semanticLabel,
    this.textDirection,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? UIColors.textPrimary,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      shadows: shadows,
    );
  }
}
