import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/colors.dart';
import '../../../../shared/widgets/glass.dart';
import '../../../../shared/router/router_key_manager.dart';
import '../cubits/home_dashboard_cubit.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              // Radar Pulse Location Pin Animation (matching 01 · Xin quyền vị trí.svg)
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse 1
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: UIColors.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      // Pulse 2
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: UIColors.primary.withOpacity(0.35),
                            width: 2,
                          ),
                        ),
                      ),
                      // Pulse 3
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: UIColors.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      // Shadow beneath pin
                      Positioned(
                        bottom: 70,
                        child: Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      // Main Pin
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: UIColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: UIColors.primary.withOpacity(0.6),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              AppGlass(
                borderRadius: 24,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary Button: Allow Location
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          await context.read<HomeDashboardCubit>().detectGpsLocation();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, RouterPath.home);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColors.primary,
                          foregroundColor: const Color(0xFF0B1220),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cho phép truy cập vị trí',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Secondary Button: Skip / Choose city manually
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, RouterPath.home);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: UIColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Để sau (Chọn thành phố thủ công)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
