import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../common/constants/colors.dart';
import '../../core/presentation/widgets/app_icon.dart';
import '../../core/presentation/widgets/app_text.dart';
import 'glass.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onTap,
    this.title,
    this.icon,
    this.enable = true,
    this.isLoading,
  });

  /// Hàm được gọi khi ấn nút. Có thể là sync hoặc async (Future).
  final FutureOr<dynamic> Function()? onTap;
  final String? title;
  final IconData? icon;
  final bool enable;

  /// Cho phép truyền trạng thái loading từ bên ngoài (nếu có Bloc/Riverpod quản lý).
  /// Nếu không truyền, nút sẽ tự động quản lý loading theo vòng đời của [onTap].
  final bool? isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _internalLoading = false;

  bool get _isLoading => widget.isLoading ?? _internalLoading;

  Future<void> _handleTap() async {
    if (_isLoading || !widget.enable || widget.onTap == null) return;

    setState(() {
      _internalLoading = true;
    });

    try {
      final result = widget.onTap!();
      if (result is Future) {
        await result;
      }
    } finally {
      if (mounted) {
        setState(() {
          _internalLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive =
        widget.enable && !_isLoading && widget.onTap != null;

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isInteractive ? _handleTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.enable
                ? UIColors.primary
                : UIColors.disabled,
            disabledBackgroundColor: widget.enable
                ? UIColors.primary
                : UIColors.disabled,
            foregroundColor: UIColors.bg,
            disabledForegroundColor: UIColors.bg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(UIColors.bg),
                    ),
                  )
                : Row(
                    key: const ValueKey('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        AppIcon(widget.icon!, size: 18, color: UIColors.bg),
                        const Gap(8),
                      ],
                      if (widget.title != null) ...[
                        AppText.bold(
                          widget.title!,
                          size: 15,
                          color: UIColors.bg,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
