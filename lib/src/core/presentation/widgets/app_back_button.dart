import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/app_icon.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

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
    this.borderRadius = 18,
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
    final button = GestureDetector(
      onTap: () => _handleBack(context),
      behavior: HitTestBehavior.opaque,
      child: AppGlass(
        isFixed: isFixed,
        borderRadius: borderRadius,
        padding: padding,
        child: AppIcon(
          icon,
          color: iconColor ?? UIColors.textPrimary,
          size: iconSize,
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
