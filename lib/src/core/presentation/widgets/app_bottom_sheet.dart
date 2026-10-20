import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

/// Vỏ BottomSheet dùng chung cho toàn bộ ứng dụng EnviVN theo chuẩn Liquid Glass.
/// Đồng bộ giao diện kính mờ cao cấp, thanh kéo (drag handle), header chuẩn hóa (leading, title, subtitle, close/trailing),
/// nội dung con (child) và nút hành động dưới cùng (bottom button).
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final Widget child;
  final String? bottomButtonText;
  final VoidCallback? onBottomButtonPressed;
  final Widget? bottomButton;
  final double? maxHeightFactor;
  final EdgeInsetsGeometry padding;
  final bool showDragHandle;
  final bool showCloseButton;
  final double borderRadius;
  final Color? glassColor;

  const AppBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.trailing,
    required this.child,
    this.bottomButtonText,
    this.onBottomButtonPressed,
    this.bottomButton,
    this.maxHeightFactor,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.borderRadius = 32,
    this.glassColor,
  });

  /// Phương thức tiện ích tĩnh mở BottomSheet với thiết lập Liquid Glass chuẩn.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Widget? titleWidget,
    Widget? leading,
    Widget? trailing,
    required Widget child,
    String? bottomButtonText,
    VoidCallback? onBottomButtonPressed,
    Widget? bottomButton,
    double? maxHeightFactor,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool showCloseButton = true,
    double borderRadius = 32,
    Color? glassColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: UIColors.transparent,
      barrierColor: UIColors.black.withOpacity(0.65),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (sheetContext) => AppBottomSheet(
        title: title,
        subtitle: subtitle,
        titleWidget: titleWidget,
        leading: leading,
        trailing: trailing,
        bottomButtonText: bottomButtonText,
        onBottomButtonPressed:
            onBottomButtonPressed ?? () => Navigator.of(sheetContext).pop(),
        bottomButton: bottomButton,
        maxHeightFactor: maxHeightFactor,
        padding: padding,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        borderRadius: borderRadius,
        glassColor: glassColor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = maxHeightFactor != null
        ? mediaQuery.size.height * maxHeightFactor!
        : mediaQuery.size.height * 0.90;

    final hasHeaderContent =
        title != null ||
        titleWidget != null ||
        leading != null ||
        trailing != null;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom + 24),
      child: AppGlass(
        borderRadius: borderRadius,
        color: glassColor,
        padding: padding,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle
              if (showDragHandle) ...[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: UIColors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Header (Leading + Title/Subtitle + Trailing or Close button)
              if (hasHeaderContent) ...[
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child:
                          titleWidget ??
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                AppText.bold(
                                  title!,
                                  size: 16.5,
                                  color: UIColors.textPrimary,
                                  maxLines: 2,
                                ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                AppText.regular(
                                  subtitle!,
                                  size: 12,
                                  color: UIColors.textSecondary,
                                  maxLines: 3,
                                ),
                              ],
                            ],
                          ),
                    ),
                    if (trailing != null)
                      trailing!
                    else if (showCloseButton)
                      IconButton(
                        icon: const AppIcon(
                          Icons.close_rounded,
                          color: UIColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 3. Child Widget
              Flexible(fit: FlexFit.loose, child: child),

              // 4. Bottom Action Button
              if (bottomButton != null) ...[
                const SizedBox(height: 16),
                bottomButton!,
              ] else if (bottomButtonText != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColors.primary,
                      foregroundColor: UIColors.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed:
                        onBottomButtonPressed ??
                        () => Navigator.of(context).pop(),
                    child: AppText.bold(
                      bottomButtonText!,
                      size: 14,
                      color: UIColors.bg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
