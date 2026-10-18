import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/core/presentation/widgets/app_text.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

/// Hộp thoại Popup Dialog dùng chung cho toàn bộ ứng dụng EnviVN.
/// Thiết kế theo ngôn ngữ Liquid Glass / Dark Navy đồng bộ: nền mờ viền sáng,
/// hỗ trợ biểu tượng/header tùy biến, tiêu đề, nội dung dạng văn bản hoặc widget con,
/// cùng hệ thống nút bấm linh hoạt (không nút, 1 nút back, hoặc 2 nút hành động).
class AppDialog extends StatelessWidget {
  /// Widget phần đầu (hình minh họa, animation spinner, custom widget).
  final Widget? header;

  /// Biểu tượng icon hiển thị phía trên tiêu đề (dùng khi không truyền [header]).
  final IconData? icon;

  /// Màu sắc của [icon] (mặc định [UIColors.primary]).
  final Color? iconColor;

  /// Tiêu đề của dialog (dạng chuỗi).
  final String? title;

  /// Widget tiêu đề tùy biến (dùng khi cần format phức tạp).
  final Widget? titleWidget;

  /// Nội dung văn bản mô tả (dùng khi không có [childrenWidget] hoặc kèm theo).
  final String? content;

  /// Widget nội dung con tùy biến (thay thế hoặc bổ sung cho [content]).
  final Widget? childrenWidget;

  /// Tiêu đề nút bên trái / nút quay lại (mặc định là 'Hủy' khi có nút phải, hoặc 'Đóng' khi chỉ có 1 nút).
  final String? leftButtonTitle;

  /// Hàm xử lý khi nhấn nút bên trái (mặc định là đóng dialog qua `Navigator.pop`).
  final VoidCallback? leftButtonFunc;

  /// Có hiển thị nút bên trái hay không. Mặc định là `true` (nếu [showButtons] bật).
  final bool showLeftButton;

  /// Tiêu đề nút bên phải / nút xác nhận.
  final String? rightButtonTitle;

  /// Hàm xử lý khi nhấn nút bên phải.
  final VoidCallback? rightButtonFunc;

  /// Màu sắc chính của nút bên phải (mặc định [UIColors.primary]).
  final Color? rightButtonColor;

  /// Nút bên phải mang tính chất nguy hiểm / cảnh báo (sẽ chuyển màu đỏ [UIColors.error]).
  final bool isDestructive;

  /// Cờ bật/tắt toàn bộ hàng nút (dùng cho dialog chỉ hiển thị thông tin hoặc loading).
  final bool showButtons;

  /// Có cho phép đóng dialog khi chạm vào vùng nền mờ bên ngoài hay không.
  final bool barrierDismissible;

  /// Hàm callback khi chạm vùng ngoài để hủy.
  final VoidCallback? onDismiss;

  /// Có cho phép nhấn nút Back phần cứng / cử chỉ vuốt để thoát không (dùng [PopScope]).
  final bool canPop;

  /// Màu ánh sáng nền tỏa xung quanh thẻ glass (mặc định ánh xanh Mint [UIColors.primary]).
  final Color? glowColor;

  /// Chiều rộng tối đa của hộp thoại (mặc định 310.0).
  final double maxWidth;

  /// Bán kính bo góc thẻ kính (mặc định 28.0).
  final double borderRadius;

  /// Khoảng đệm bên trong thẻ kính.
  final EdgeInsetsGeometry padding;

  /// Độ nhòe của lớp kính nền (mặc định 10.0).
  final double blurSigma;

  /// Màu nền phủ mờ (mặc định đen 62%).
  final Color? barrierColor;

  const AppDialog({
    super.key,
    this.header,
    this.icon,
    this.iconColor,
    this.title,
    this.titleWidget,
    this.content,
    this.childrenWidget,
    this.leftButtonTitle,
    this.leftButtonFunc,
    this.showLeftButton = true,
    this.rightButtonTitle,
    this.rightButtonFunc,
    this.rightButtonColor,
    this.isDestructive = false,
    this.showButtons = true,
    this.barrierDismissible = true,
    this.onDismiss,
    this.canPop = true,
    this.glowColor,
    this.maxWidth = 310.0,
    this.borderRadius = 28.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
    this.blurSigma = 10.0,
    this.barrierColor,
  });

  /// Phương thức tĩnh hiển thị Popup Dialog mượt mà với hiệu ứng phóng to + mờ dần (Scale & Fade).
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? header,
    IconData? icon,
    Color? iconColor,
    String? title,
    Widget? titleWidget,
    String? content,
    Widget? childrenWidget,
    String? leftButtonTitle,
    VoidCallback? leftButtonFunc,
    bool showLeftButton = true,
    String? rightButtonTitle,
    VoidCallback? rightButtonFunc,
    Color? rightButtonColor,
    bool isDestructive = false,
    bool showButtons = true,
    bool barrierDismissible = true,
    VoidCallback? onDismiss,
    bool canPop = true,
    Color? glowColor,
    double maxWidth = 310.0,
    double borderRadius = 28.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
    double blurSigma = 10.0,
    Color? barrierColor,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'AppDialog',
      barrierColor: Colors.transparent, // Được xử lý bên trong AppDialog bằng BackdropFilter
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
          header: header,
          icon: icon,
          iconColor: iconColor,
          title: title,
          titleWidget: titleWidget,
          content: content,
          childrenWidget: childrenWidget,
          leftButtonTitle: leftButtonTitle,
          leftButtonFunc: leftButtonFunc,
          showLeftButton: showLeftButton,
          rightButtonTitle: rightButtonTitle,
          rightButtonFunc: rightButtonFunc,
          rightButtonColor: rightButtonColor,
          isDestructive: isDestructive,
          showButtons: showButtons,
          barrierDismissible: barrierDismissible,
          onDismiss: onDismiss,
          canPop: canPop,
          glowColor: glowColor,
          maxWidth: maxWidth,
          borderRadius: borderRadius,
          padding: padding,
          blurSigma: blurSigma,
          barrierColor: barrierColor,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRightButton = rightButtonTitle != null && rightButtonTitle!.isNotEmpty;
    final bool hasLeftButton = showLeftButton && (leftButtonTitle != null || hasRightButton || !showButtons);

    final String effectiveLeftTitle = leftButtonTitle ?? (hasRightButton ? 'Hủy' : 'Đóng');
    final VoidCallback effectiveLeftFunc = leftButtonFunc ?? () => Navigator.of(context).maybePop();

    return PopScope(
      canPop: canPop,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Chặn tương tác màn hình bên dưới & bắt sự kiện chạm ra ngoài
          GestureDetector(
            onTap: barrierDismissible ? (onDismiss ?? () => Navigator.of(context).maybePop()) : null,
            child: const ModalBarrier(
              dismissible: false,
              color: Colors.transparent,
            ),
          ),

          // 2. Lớp phủ làm mờ nền toàn màn hình (Frosted Dark Glass)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              color: barrierColor ?? Colors.black.withOpacity(0.62),
            ),
          ),

          // 3. Thẻ kính trung tâm (Floating Glass Dialog Card)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor ?? UIColors.primary.withOpacity(0.24),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: AppGlass(
                  borderRadius: borderRadius,
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Widget / Icon
                      if (header != null) ...[
                        header!,
                        const SizedBox(height: 20),
                      ] else if (icon != null) ...[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (iconColor ?? UIColors.primary).withOpacity(0.12),
                            border: Border.all(
                              color: (iconColor ?? UIColors.primary).withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: AppIcon(
                            icon!,
                            size: 28,
                            color: iconColor ?? UIColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Title
                      if (titleWidget != null) ...[
                        titleWidget!,
                        const SizedBox(height: 8),
                      ] else if (title != null) ...[
                        AppText.bold(
                          title!,
                          textAlign: TextAlign.center,
                          size: 16.5,
                          letterSpacing: 0.2,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Children Widget (nếu có)
                      ?childrenWidget,

                      // Text Content (nếu có và không truyền childrenWidget, hoặc dùng độc lập)
                      if (content != null) ...[
                        if (childrenWidget != null) const SizedBox(height: 8),
                        AppText.regular(
                          content!,
                          textAlign: TextAlign.center,
                          size: 12.5,
                          color: UIColors.textSecondary,
                          height: 1.45,
                        ),
                      ],

                      // Action Buttons
                      if (showButtons && (hasLeftButton || hasRightButton)) ...[
                        const SizedBox(height: 22),
                        _buildButtonsRow(
                          context,
                          hasLeft: hasLeftButton,
                          hasRight: hasRightButton,
                          leftTitle: effectiveLeftTitle,
                          leftFunc: effectiveLeftFunc,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsRow(
    BuildContext context, {
    required bool hasLeft,
    required bool hasRight,
    required String leftTitle,
    required VoidCallback leftFunc,
  }) {
    // Trường hợp cả 2 nút (Left: Hủy/Thoát, Right: Xác nhận/Hành động)
    if (hasLeft && hasRight) {
      return Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: leftFunc,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                      width: 0.8,
                    ),
                  ),
                  child: AppText.semiBold(
                    leftTitle,
                    size: 13.5,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: rightButtonFunc,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? UIColors.error
                        : (rightButtonColor ?? UIColors.primary),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isDestructive
                                ? UIColors.error
                                : (rightButtonColor ?? UIColors.primary))
                            .withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AppText.bold(
                    rightButtonTitle!,
                    size: 13.5,
                    color: isDestructive ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Trường hợp chỉ có 1 nút duy nhất (chiếm toàn bộ chiều ngang)
    final isLeftOnly = hasLeft && !hasRight;
    final title = isLeftOnly ? leftTitle : rightButtonTitle!;
    final func = isLeftOnly ? leftFunc : rightButtonFunc;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: func,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLeftOnly
                  ? Colors.white.withOpacity(0.1)
                  : (isDestructive
                      ? UIColors.error
                      : (rightButtonColor ?? UIColors.primary)),
              borderRadius: BorderRadius.circular(16),
              border: isLeftOnly
                  ? Border.all(color: Colors.white.withOpacity(0.14), width: 0.8)
                  : null,
              boxShadow: isLeftOnly
                  ? null
                  : [
                      BoxShadow(
                        color: (isDestructive
                                ? UIColors.error
                                : (rightButtonColor ?? UIColors.primary))
                            .withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: AppText(
              title,
              size: 13.5,
              fontWeight: isLeftOnly ? FontWeight.w600 : FontWeight.bold,
              color: isLeftOnly
                  ? Colors.white
                  : (isDestructive ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
