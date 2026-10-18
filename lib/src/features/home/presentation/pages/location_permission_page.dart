import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_action_panel.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_radar_illustration.dart';

class LocationPermissionPage extends StatelessWidget {
  final bool isSettings;

  const LocationPermissionPage({
    super.key,
    this.isSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      buildWhen: (prev, curr) =>
          prev.isLocationPermissionGranted != curr.isLocationPermissionGranted ||
          prev.currentTab != curr.currentTab,
      builder: (context, state) {
        final isEnabled = state.isLocationPermissionGranted;
        final isSettingsScreen = isSettings || state.currentTab == 3;
        final showSelectCurrentLocation = isEnabled;

        final titleText = showSelectCurrentLocation
            ? 'Chọn vị trí hiện tại'
            : 'Theo dõi không khí quanh bạn';

        final subtitleText = showSelectCurrentLocation
            ? 'Định vị GPS để cập nhật dữ liệu chất lượng không khí và dự báo thời tiết tại vị trí chính xác của bạn.'
            : 'EnviVN cần quyền truy cập vị trí để cung cấp chỉ số AQI và thời tiết theo thời gian thực tại nơi bạn sinh sống.';

        final primaryButtonText = showSelectCurrentLocation
            ? 'Chọn vị trí hiện tại'
            : 'Cho phép truy cập vị trí';

        final secondaryButtonText = isSettingsScreen && isEnabled
            ? 'Chọn thành phố khác'
            : 'Để sau (Chọn thành phố thủ công)';

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

                  // Title (Tự động cập nhật nếu trong bộ nhớ đã bật quyền vị trí)
                  AppText.bold(
                    titleText,
                    textAlign: TextAlign.center,
                    size: 24,
                    color: UIColors.textPrimary,
                    height: 1.3,
                  ),
                  const SizedBox(height: 14),

                  // Subtitle
                  AppText.regular(
                    subtitleText,
                    textAlign: TextAlign.center,
                    size: 14,
                    color: UIColors.textSecondary,
                    height: 1.5,
                  ),
                  const Spacer(),

                  // Liquid Glass Action Panel (Apple iOS style)
                  LocationActionPanel(
                    primaryButtonText: primaryButtonText,
                    secondaryButtonText: secondaryButtonText,
                    onAllow: () => context
                        .read<HomeDashboardCubit>()
                        .requestLocationPermission(
                          onCompleted: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                    onSkip: () => context
                        .read<HomeDashboardCubit>()
                        .skipLocationPermission(
                          onCompleted: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                  ),
                  const SizedBox(height: 14),

                  // Privacy Footnote
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      AppIcon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: UIColors.textMuted,
                      ),
                      SizedBox(width: 6),
                      AppText.regular(
                        'Dữ liệu vị trí chỉ được lưu trên thiết bị của bạn.',
                        size: 11,
                        color: UIColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
