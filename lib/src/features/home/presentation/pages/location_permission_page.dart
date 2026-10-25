import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/city_selector_sheet.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_action_panel.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_radar_illustration.dart';
import 'package:envivn/src/shared/router/router_key_manager.dart';

class LocationPermissionPage extends StatelessWidget {
  final bool isSettings;

  const LocationPermissionPage({super.key, this.isSettings = false});

  void _navigateToHome(BuildContext context) {
    if (isSettings) {
      context.read<HomeDashboardCubit>().setTab(0);
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, RouterPath.home);
    }
  }

  void _openCitySelector(BuildContext context, HomeDashboardState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: UIColors.transparent,
      builder: (_) => CitySelectorSheet(
        currentCity: state.currentCity,
        onCitySelected: (city) {
          context.read<HomeDashboardCubit>().changeCity(city);
          _navigateToHome(context);
        },
        onSelectGps: () {
          context.read<HomeDashboardCubit>().detectGpsLocation();
          _navigateToHome(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      buildWhen: (prev, curr) =>
          prev.isLocationPermissionGranted !=
              curr.isLocationPermissionGranted ||
          prev.currentTab != curr.currentTab ||
          prev.isChangingLocation != curr.isChangingLocation,
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

                  const LocationRadarIllustration(),
                  const Gap(32),

                  AppText.bold(
                    titleText,
                    textAlign: TextAlign.center,
                    size: 24,
                    color: UIColors.textPrimary,
                    height: 1.3,
                  ),
                  const Gap(14),

                  AppText.regular(
                    subtitleText,
                    textAlign: TextAlign.center,
                    size: 14,
                    color: UIColors.textSecondary,
                    height: 1.5,
                  ),
                  const Spacer(),

                  LocationActionPanel(
                    primaryButtonText: primaryButtonText,
                    secondaryButtonText: secondaryButtonText,
                    isLoading: state.isChangingLocation,
                    onAllow: () => context
                        .read<HomeDashboardCubit>()
                        .requestLocationPermission(
                          onCompleted: () {
                            if (context.mounted) {
                              _navigateToHome(context);
                            }
                          },
                        ),
                    onSkip: () {
                      if (isSettingsScreen && isEnabled) {
                        _openCitySelector(context, state);
                      } else {
                        context
                            .read<HomeDashboardCubit>()
                            .skipLocationPermission(
                              onCompleted: () {
                                if (context.mounted) {
                                  _navigateToHome(context);
                                }
                              },
                            );
                      }
                    },
                  ),
                  const Gap(14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      AppIcon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: UIColors.textMuted,
                      ),
                      Gap(6),
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
