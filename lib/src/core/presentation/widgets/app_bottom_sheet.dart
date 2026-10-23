import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/shared/widgets/app_button.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final IconData? icon;
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
    this.icon,
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

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Widget? titleWidget,
    IconData? icon,
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
        icon: icon,
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
        icon != null ||
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
                const Gap(16),
              ],

              if (hasHeaderContent) ...[
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [UIColors.primary, UIColors.secondary],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppIcon(
                            icon ?? Icons.circle,
                            color: UIColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const Gap(12),
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
                                const Gap(2),
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
                const Gap(16),
              ],

              Flexible(fit: FlexFit.loose, child: child),

              if (bottomButton != null) ...[
                const Gap(16),
                bottomButton!,
              ] else if (bottomButtonText != null) ...[
                const Gap(16),
                AppButton(
                  onTap:
                      onBottomButtonPressed ??
                      () => Navigator.of(context).pop(),
                  title: bottomButtonText!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
