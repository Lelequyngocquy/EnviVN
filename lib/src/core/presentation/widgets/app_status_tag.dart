import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:gap/gap.dart';

/// Định nghĩa các kích thước quy chuẩn cho thẻ trạng thái (Tag / Badge).
/// Tự động đồng bộ kích thước khung chứa (padding, border radius) và kích thước chữ/icon.
enum AppTagSize {
  /// Kích thước nhỏ: Thích hợp cho danh sách item, nhãn phụ, tag trong row.
  small(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    borderRadius: 10,
    fontSize: 10.5,
    iconSize: 11,
    borderWidth: 0.8,
    spacing: 3.5,
  ),

  /// Kích thước vừa (Mặc định): Thích hợp cho tiêu đề card, widget con, action pill.
  medium(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
    borderRadius: 14,
    fontSize: 12,
    iconSize: 13,
    borderWidth: 1.0,
    spacing: 5.0,
  ),

  /// Kích thước lớn: Thích hợp cho Hero card, BottomSheet header, nhãn nổi bật chính.
  large(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    borderRadius: 20,
    fontSize: 13.5,
    iconSize: 15,
    borderWidth: 1.0,
    spacing: 6.0,
  );

  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final double iconSize;
  final double borderWidth;
  final double spacing;

  const AppTagSize({
    required this.padding,
    required this.borderRadius,
    required this.fontSize,
    required this.iconSize,
    required this.borderWidth,
    required this.spacing,
  });
}

/// Widget Tag trạng thái (Status Tag / Badge) dùng chung cho toàn bộ ứng dụng EnviVN.
/// Chuẩn hóa thiết kế viền nét thanh, nền mờ kính (translucent tint), màu sắc đồng bộ
/// và hỗ trợ các kích thước: nhỏ (small), vừa (medium), lớn (large).
class AppStatusTag extends StatelessWidget {
  /// Nội dung văn bản hiển thị trong tag.
  final String label;

  /// Màu sắc chủ đạo (dùng để suy biến màu nền, màu viền, màu chữ và icon).
  final Color color;

  /// Cỡ tag quy chuẩn (nhỏ, vừa, lớn). Mặc định là [AppTagSize.medium].
  final AppTagSize size;

  /// Biểu tượng icon hiển thị trước văn bản (tuỳ chọn).
  final IconData? icon;

  /// Widget tùy biến phía trước văn bản (nếu muốn dùng widget phức tạp hơn icon).
  final Widget? leading;

  /// Widget tùy biến phía sau văn bản.
  final Widget? trailing;

  /// Màu nền tùy biến (nếu không truyền, tự động tính bằng [color] với độ mờ [bgOpacity]).
  final Color? backgroundColor;

  /// Màu viền tùy biến (nếu không truyền, tự động tính bằng [color] với độ mờ [borderOpacity]).
  final Color? borderColor;

  /// Màu chữ & icon tùy biến (nếu không truyền, dùng chính [color]).
  final Color? textColor;

  /// Độ đậm của phông chữ (mặc định là [FontWeight.bold]).
  final FontWeight fontWeight;

  /// Độ bo góc tùy biến (nếu không truyền, lấy theo [size]).
  final BorderRadius? borderRadius;

  /// Khoảng đệm bên trong tùy biến (nếu không truyền, lấy theo [size]).
  final EdgeInsetsGeometry? padding;

  /// Độ dày viền tùy biến (nếu không truyền, lấy theo [size]).
  final double? borderWidth;

  /// Độ mờ của nền khi dùng màu tự động (mặc định 0.16).
  final double bgOpacity;

  /// Độ mờ của viền khi dùng màu tự động (mặc định 0.38).
  final double borderOpacity;

  /// Sự kiện khi người dùng nhấn vào tag (nếu có sẽ kích hoạt hiệu ứng chạm InkWell).
  final VoidCallback? onTap;

  const AppStatusTag({
    super.key,
    required this.label,
    this.color = UIColors.primary,
    this.size = AppTagSize.medium,
    this.icon,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.fontWeight = FontWeight.bold,
    this.borderRadius,
    this.padding,
    this.borderWidth,
    this.bgOpacity = 0.16,
    this.borderOpacity = 0.38,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? color.withOpacity(bgOpacity);
    final effectiveBorderColor = borderColor ?? color.withOpacity(borderOpacity);
    final effectiveTextColor = textColor ?? color;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(size.borderRadius);
    final effectivePadding = padding ?? size.padding;
    final effectiveBorderWidth = borderWidth ?? size.borderWidth;

    final tagContent = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          Gap(size.spacing),
        ] else if (icon != null) ...[
          AppIcon(
            icon!,
            size: size.iconSize,
            color: effectiveTextColor,
          ),
          Gap(size.spacing),
        ],
        AppText(
          label,
          color: effectiveTextColor,
          size: size.fontSize,
          fontWeight: fontWeight,
          height: 1.15,
        ),
        if (trailing != null) ...[
          Gap(size.spacing),
          trailing!,
        ],
      ],
    );

    final containerDecoration = BoxDecoration(
      color: effectiveBgColor,
      borderRadius: effectiveBorderRadius,
      border: Border.all(
        color: effectiveBorderColor,
        width: effectiveBorderWidth,
      ),
    );

    if (onTap != null) {
      return Material(
        color: UIColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Ink(
            padding: effectivePadding,
            decoration: containerDecoration,
            child: tagContent,
          ),
        ),
      );
    }

    return Container(
      padding: effectivePadding,
      decoration: containerDecoration,
      child: tagContent,
    );
  }
}

/// Bí danh rút gọn để gọi nhanh [AppStatusTag]
typedef AppTag = AppStatusTag;
