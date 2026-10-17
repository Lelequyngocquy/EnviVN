import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_action_panel.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_radar_illustration.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  void _onSkip(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.read<HomeDashboardCubit>().setTab(0);
    }
  }

  Future<void> _onAllowLocation(BuildContext context) async {
    await context.read<HomeDashboardCubit>().detectGpsLocation();
    if (context.mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.read<HomeDashboardCubit>().setTab(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
          child: Column(
            children: [
              const Spacer(),
              // Radar Pulse Location Pin Animation
              const LocationRadarIllustration(),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Theo dõi không khí quanh bạn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: UIColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle
              const Text(
                'EnviVN cần quyền truy cập vị trí để cung cấp chỉ số AQI và thời tiết theo thời gian thực tại nơi bạn sinh sống.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: UIColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // Liquid Glass Action Panel (Apple iOS style)
              LocationActionPanel(
                onAllow: () => _onAllowLocation(context),
                onSkip: () => _onSkip(context),
              ),
              const SizedBox(height: 14),

              // Privacy Footnote
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline_rounded, size: 12, color: UIColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Dữ liệu vị trí chỉ được lưu trên thiết bị của bạn.',
                    style: TextStyle(fontSize: 11, color: UIColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
