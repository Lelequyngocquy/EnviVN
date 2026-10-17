import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/extensions/context_x.dart';
import 'package:envivn/src/core/presentation/widgets/loading.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/city_selector_sheet.dart';
import 'package:envivn/src/features/home/presentation/widgets/hero_aqi_card.dart';
import 'package:envivn/src/features/home/presentation/widgets/home_top_bar.dart';
import 'package:envivn/src/features/home/presentation/widgets/liquid_glass_bottom_bar.dart';
import 'package:envivn/src/features/home/presentation/widgets/map_shortcut_card.dart';
import 'package:envivn/src/features/home/presentation/widgets/outdoor_activity_advice_card.dart';
import 'package:envivn/src/features/home/presentation/widgets/weather_metrics_grid.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_cubit.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_state.dart';
import 'package:envivn/src/shared/router/router_key_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeDashboardCubit>().initDashboard();
  }

  void _openCitySelector(HomeDashboardState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CitySelectorSheet(
        currentCity: state.currentCity,
        onCitySelected: (city) {
          context.read<HomeDashboardCubit>().changeCity(city);
        },
        onSelectGps: () {
          context.read<HomeDashboardCubit>().detectGpsLocation();
        },
      ),
    );
  }

  void _handleTabSelected(int index) {
    switch (index) {
      case 0:
        setState(() => _currentTab = 0);
        break;
      case 1:
        Navigator.pushNamed(context, RouterPath.pollutionMap);
        break;
      case 2:
        Navigator.pushNamed(context, RouterPath.twentyFourHours);
        break;
      case 3:
        Navigator.pushNamed(context, RouterPath.permission);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd \'tháng\' MM', 'vi').format(now);

    return Scaffold(
      backgroundColor: UIColors.bg,
      body: Stack(
        children: [
          // Background ambient radial glows
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    UIColors.primary.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    UIColors.secondary.withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            bottom: false,
            child: BlocConsumer<HomeDashboardCubit, HomeDashboardState>(
              listener: (context, state) {
                if (state.noticeMessage != null && state.noticeMessage!.isNotEmpty) {
                  context.showSnackBar(state.noticeMessage!);
                }
              },
              builder: (context, dashState) {
                return BlocBuilder<WeatherCubit, WeatherState>(
                  builder: (context, weatherState) {
                    return BlocBuilder<AirQualityCubit, AirQualityState>(
                      builder: (context, aqiState) {
                        final isInitialLoading = dashState.status == DashboardStatus.loading &&
                            weatherState.weather.hourlyForecast.isEmpty;

                        if (isInitialLoading) {
                          return const LoadingWidget(message: 'Đang tải dữ liệu môi trường...');
                        }

                        return RefreshIndicator(
                          color: UIColors.primary,
                          backgroundColor: UIColors.cardBg,
                          onRefresh: () => context.read<HomeDashboardCubit>().refresh(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Top Bar: Location Selector & Notification Bell
                                HomeTopBar(
                                  cityName: dashState.currentCity.name,
                                  isGps: dashState.currentCity.isGps,
                                  dateText: dateStr,
                                  onLocationTap: () => _openCitySelector(dashState),
                                  onNotificationTap: () {
                                    context.showSnackBar('Chất lượng không khí đang ổn định.');
                                  },
                                ),
                                const SizedBox(height: 20),

                                // 2. Hero AQI Liquid Glass Card
                                HeroAQICard(
                                  airQuality: aqiState.airQuality,
                                  onDetailTap: () {
                                    Navigator.pushNamed(context, RouterPath.twentyFourHours);
                                  },
                                ),
                                const SizedBox(height: 16),

                                // 3. 2x2 Weather Metrics Grid
                                WeatherMetricsGrid(weather: weatherState.weather),
                                const SizedBox(height: 16),

                                // 4. Outdoor Sports & Activity Advice Card
                                OutdoorActivityAdviceCard(
                                  airQuality: aqiState.airQuality,
                                  weather: weatherState.weather,
                                ),
                                const SizedBox(height: 16),

                                // 5. Map Shortcut Card
                                MapShortcutCard(
                                  onTap: () {
                                    Navigator.pushNamed(context, RouterPath.pollutionMap);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // 6. iPhone Style Floating Liquid Glass Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: LiquidGlassBottomBar(
              currentTab: _currentTab,
              onTabSelected: _handleTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}
