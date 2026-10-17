import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

/// Vỏ BottomSheet dùng chung cho toàn bộ ứng dụng EnviVN.
/// Chuẩn hóa giao diện Liquid Glass / Dark Navy: thanh kéo (drag handle), tiêu đề, phụ đề,
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
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
    this.showDragHandle = true,
  });

  /// Phương thức tiện ích tĩnh mở BottomSheet với thiết lập chuẩn.
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
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = maxHeightFactor != null
        ? mediaQuery.size.height * maxHeightFactor!
        : mediaQuery.size.height * 0.88;

    final hasHeader = title != null || titleWidget != null || leading != null || trailing != null;

    Widget content = Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: UIColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 2. Header (Leading + Title/Subtitle + Trailing)
          if (hasHeader) ...[
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: titleWidget ??
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: UIColors.textPrimary,
                              ),
                            ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: UIColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 3. Child Widget Con
          Flexible(
            fit: FlexFit.loose,
            child: child,
          ),

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
                  foregroundColor: const Color(0xFF0B1220),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                onPressed: onBottomButtonPressed ?? () => Navigator.of(context).pop(),
                child: Text(
                  bottomButtonText!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return content;
  }
}
