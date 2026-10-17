import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/pages/location_permission_page.dart';
import 'package:envivn/src/features/home/presentation/widgets/home_dashboard_view.dart';
import 'package:envivn/src/features/home/presentation/widgets/liquid_glass_bottom_bar.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_loading_overlay.dart';
import 'package:envivn/src/features/map_pollution/presentation/pages/pollution_map_page.dart';
import 'package:envivn/src/features/weather/presentation/pages/twenty_four_hour_detail_page.dart';

class HomePage extends StatefulWidget {
  final int initialTab;

  const HomePage({super.key, this.initialTab = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<HomeDashboardCubit>();
    cubit.initDashboard();
    if (widget.initialTab != 0) {
      cubit.setTab(widget.initialTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        final cubit = context.read<HomeDashboardCubit>();
        if (cubit.state.currentTab != 0) {
          cubit.setTab(0);
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: UIColors.bg,
        body: Stack(
          children: [
            // 1. Persistent Tab Views with state retention (IndexedStack)
            BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
              buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
              builder: (context, state) {
                return ClipRect(
                  child: IndexedStack(
                    index: state.currentTab,
                    children: const [
                      HomeDashboardView(),
                      PollutionMapPage(),
                      TwentyFourHourDetailPage(),
                      LocationPermissionPage(),
                    ],
                  ),
                );
              },
            ),

            // 2. Fixed Floating Liquid Glass Bottom Navigation Bar (retains position across all pages)
            BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
              buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
              builder: (context, state) {
                return Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: LiquidGlassBottomBar(
                    currentTab: state.currentTab,
                    onTabSelected: (index) {
                      context.read<HomeDashboardCubit>().setTab(index);
                    },
                  ),
                );
              },
            ),

            // 3. Full-Screen Blocking Glass Loading Popup during Location Change
            BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
              buildWhen: (prev, curr) =>
                  prev.isChangingLocation != curr.isChangingLocation ||
                  (curr.isChangingLocation && prev.currentCity != curr.currentCity),
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: state.isChangingLocation
                      ? LocationLoadingOverlay(
                          key: const ValueKey('location_loading_overlay'),
                          cityName: state.currentCity.name,
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
