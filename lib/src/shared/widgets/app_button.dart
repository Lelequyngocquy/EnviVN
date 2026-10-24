import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../common/constants/colors.dart';
import '../../core/presentation/widgets/app_icon.dart';
import '../../core/presentation/widgets/app_text.dart';
import '../../features/home/presentation/cubits/home_dashboard_cubit.dart';
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

  final FutureOr<dynamic> Function()? onTap;
  final String? title;
  final IconData? icon;
  final bool enable;

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

class AppTwoButtons extends StatefulWidget {
  const AppTwoButtons({
    super.key,
    required this.primaryTitle,
    required this.primaryOnTap,
    this.primaryIcon,
    this.primaryEnable = true,
    this.isPrimaryLoading,
    this.secondaryTitle,
    this.secondaryOnTap,
    this.secondaryIcon,
    this.secondaryEnable = true,
    this.isSecondaryLoading,
    this.isLoading,
  });

  final String primaryTitle;

  final FutureOr<dynamic> Function()? primaryOnTap;

  final IconData? primaryIcon;

  final bool primaryEnable;

  final bool? isPrimaryLoading;

  final String? secondaryTitle;

  final FutureOr<dynamic> Function()? secondaryOnTap;

  final IconData? secondaryIcon;

  final bool secondaryEnable;

  final bool? isSecondaryLoading;

  final bool? isLoading;

  @override
  State<AppTwoButtons> createState() => _AppTwoButtonsState();
}

class _AppTwoButtonsState extends State<AppTwoButtons> {
  bool _internalPrimaryLoading = false;
  bool _internalSecondaryLoading = false;

  bool get _isPrimaryLoading =>
      widget.isLoading ?? widget.isPrimaryLoading ?? _internalPrimaryLoading;

  bool get _isSecondaryLoading =>
      widget.isSecondaryLoading ?? _internalSecondaryLoading;

  bool get _isAnyLoading => _isPrimaryLoading || _isSecondaryLoading;

  Future<void> _handlePrimaryTap() async {
    if (_isAnyLoading || !widget.primaryEnable || widget.primaryOnTap == null) {
      return;
    }

    setState(() {
      _internalPrimaryLoading = true;
    });

    try {
      final result = widget.primaryOnTap!();
      if (result is Future) {
        await result;
      }
    } finally {
      if (mounted) {
        setState(() {
          _internalPrimaryLoading = false;
        });
      }
    }
  }

  Future<void> _handleSecondaryTap() async {
    if (_isAnyLoading ||
        !widget.secondaryEnable ||
        widget.secondaryOnTap == null) {
      return;
    }

    setState(() {
      _internalSecondaryLoading = true;
    });

    try {
      final result = widget.secondaryOnTap!();
      if (result is Future) {
        await result;
      }
    } finally {
      if (mounted) {
        setState(() {
          _internalSecondaryLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPrimaryInteractive =
        widget.primaryEnable && !_isAnyLoading && widget.primaryOnTap != null;
    final bool hasSecondary =
        widget.secondaryTitle != null &&
        widget.secondaryTitle!.trim().isNotEmpty;
    final bool isSecondaryInteractive =
        widget.secondaryEnable &&
        !_isAnyLoading &&
        widget.secondaryOnTap != null;

    return AppGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isPrimaryInteractive ? _handlePrimaryTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryEnable
                    ? UIColors.primary
                    : UIColors.disabled,
                disabledBackgroundColor: widget.primaryEnable
                    ? (_isPrimaryLoading
                          ? UIColors.primary
                          : UIColors.primary.withOpacity(0.6))
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
                child: _isPrimaryLoading
                    ? const SizedBox(
                        key: ValueKey('primary_loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            UIColors.bg,
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('primary_content'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.primaryIcon != null) ...[
                            AppIcon(
                              widget.primaryIcon!,
                              size: 18,
                              color: UIColors.bg,
                            ),
                            const Gap(8),
                          ],
                          AppText.bold(
                            widget.primaryTitle,
                            size: 15,
                            color: UIColors.bg,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          if (hasSecondary) ...[
            const Gap(8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: isSecondaryInteractive ? _handleSecondaryTap : null,
                style: TextButton.styleFrom(
                  foregroundColor: UIColors.textSecondary,
                  disabledForegroundColor: UIColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSecondaryLoading
                      ? const SizedBox(
                          key: ValueKey('secondary_loading'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              UIColors.textSecondary,
                            ),
                          ),
                        )
                      : Row(
                          key: const ValueKey('secondary_content'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.secondaryIcon != null) ...[
                              AppIcon(
                                widget.secondaryIcon!,
                                size: 16,
                                color: UIColors.textSecondary,
                              ),
                              const Gap(8),
                            ],
                            AppText.semiBold(
                              widget.secondaryTitle!,
                              size: 14,
                              color: UIColors.textSecondary,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppCircleButton extends StatefulWidget {
  const AppCircleButton({
    super.key,
    required this.icon,

    this.onTap,
    this.iconSize = 22,
    this.iconColor = UIColors.primary,
    this.tooltip,
    this.borderRadius = 50,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    this.isFixed = true,
    this.enable = true,
    this.isLoading,
    this.showDot = false,
    this.dotColor = UIColors.error,
  });

  final IconData icon;

  final FutureOr<dynamic> Function()? onTap;

  final double iconSize;

  final Color iconColor;

  final String? tooltip;

  final double borderRadius;

  final EdgeInsetsGeometry padding;

  final bool isFixed;

  final bool enable;

  final bool? isLoading;

  final bool? showDot;

  final Color dotColor;

  @override
  State<AppCircleButton> createState() => _AppCircleButtonState();
}

class _AppCircleButtonState extends State<AppCircleButton> {
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
    final Color effectiveColor = widget.enable
        ? (widget.iconColor)
        : UIColors.textMuted;

    Widget button = GestureDetector(
      onTap: (widget.enable && !_isLoading && widget.onTap != null)
          ? _handleTap
          : null,
      behavior: HitTestBehavior.opaque,
      child: AppGlass(
        isFixed: widget.isFixed,
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? SizedBox(
                  key: const ValueKey('circle_loading'),
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.iconColor),
                  ),
                )
              : SizedBox(
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      AppIcon(
                        widget.icon,
                        key: const ValueKey('circle_icon'),
                        color: effectiveColor,
                        size: widget.iconSize,
                      ),
                      if (widget.showDot == true)
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: (widget.iconSize * 0.32).clamp(6.0, 9.0),
                            height: (widget.iconSize * 0.32).clamp(6.0, 9.0),
                            decoration: BoxDecoration(
                              color: widget.dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      return Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final String? tooltip;
  final bool isFixed;

  const AppBackButton({
    super.key,
    this.onTap,
    this.borderRadius = 50,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.iconSize = 16,
    this.iconColor,
    this.tooltip = 'Quay lại',
    this.isFixed = true,
  });

  void _handleBack(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    try {
      context.read<HomeDashboardCubit>().setTab(0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppCircleButton(
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor ?? UIColors.textPrimary,
      borderRadius: borderRadius,
      padding: padding,
      tooltip: tooltip,
      isFixed: isFixed,
      onTap: () => _handleBack(context),
    );
  }
}
