import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

/// Widget văn bản quy chuẩn cho toàn bộ ứng dụng EnviVN (AppText).
///
/// Hỗ trợ các kiểu định dạng trọng số phông chữ thông dụng:
/// - [AppText.regular]: Trọng số thông thường (w400)
/// - [AppText.medium]: Trọng số vừa (w500)
/// - [AppText.semiBold] / [AppText.semibold]: Trọng số bán đậm (w600)
/// - [AppText.bold]: Trọng số đậm (w700)
/// - [AppText.light]: Trọng số mảnh (w300)
/// - [AppText.extraBold]: Trọng số rất đậm (w800)
///
/// Mặc định:
/// - Cỡ chữ (size): 14.0
/// - Màu sắc (color): [UIColors.textPrimary]
/// - Nếu có [maxLines] mà không truyền [overflow], tự động gán [TextOverflow.ellipsis].
class AppText extends StatelessWidget {
  final String? text;
  final InlineSpan? textSpan;
  final FontWeight fontWeight;
  final double? size;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final double? height;
  final double? letterSpacing;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final bool? softWrap;
  final TextStyle? style;

  /// Khởi tạo AppText với trọng số tuỳ chọn (mặc định w400).
  const AppText(
    String this.text, {
    super.key,
    this.fontWeight = FontWeight.w400,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : textSpan = null,
        size = size ?? fontSize;

  /// Văn bản thông thường (FontWeight.w400)
  const AppText.regular(
    String this.text, {
    super.key,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : fontWeight = FontWeight.w400,
        textSpan = null,
        size = size ?? fontSize;

  /// Văn bản độ đậm vừa (FontWeight.w500)
  const AppText.medium(
    String this.text, {
    super.key,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : fontWeight = FontWeight.w500,
        textSpan = null,
        size = size ?? fontSize;

  /// Văn bản bán đậm (FontWeight.w600)
  const AppText.semiBold(
    String this.text, {
    super.key,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : fontWeight = FontWeight.w600,
        textSpan = null,
        size = size ?? fontSize;

  /// Bí danh của [AppText.semiBold] (FontWeight.w600)
  const AppText.semibold(
    String this.text, {
    super.key,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : fontWeight = FontWeight.w600,
        textSpan = null,
        size = size ?? fontSize;

  /// Văn bản đậm (FontWeight.w700)
  const AppText.bold(
    String this.text, {
    super.key,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : fontWeight = FontWeight.w700,
        textSpan = null,
        size = size ?? fontSize;

  /// Văn bản thanh mảnh (FontWeight.w300)
  const AppText.light(
    String this.text, {
    super.key,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : fontWeight = FontWeight.w300,
        textSpan = null,
        size = size ?? fontSize;

  /// Văn bản cực đậm (FontWeight.w800)
  const AppText.extraBold(
    String this.text, {
    super.key,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : fontWeight = FontWeight.w800,
        textSpan = null,
        size = size ?? fontSize;

  /// Văn bản đa định dạng (Rich Text)
  const AppText.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.fontWeight = FontWeight.w400,
    double? size,
    double? fontSize,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.softWrap,
    this.style,
  })  : text = null,
        size = size ?? fontSize;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = TextStyle(
      fontSize: size ?? 14.0,
      fontWeight: fontWeight,
      color: color ?? UIColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
    ).merge(style);

    final effectiveOverflow = overflow ?? (maxLines != null ? TextOverflow.ellipsis : null);

    if (textSpan != null) {
      return Text.rich(
        textSpan!,
        style: effectiveStyle,
        maxLines: maxLines,
        overflow: effectiveOverflow,
        textAlign: textAlign,
        softWrap: softWrap,
      );
    }

    return Text(
      text ?? '',
      style: effectiveStyle,
      maxLines: maxLines,
      overflow: effectiveOverflow,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}
