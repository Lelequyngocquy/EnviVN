import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/extensions/context_x.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/core/presentation/widgets/loading.dart';
import 'package:envivn/src/features/home/presentation/widgets/environmental_notification_sheet.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/city_selector_sheet.dart';
import 'package:envivn/src/features/home/presentation/widgets/hero_aqi_card.dart';
import 'package:envivn/src/features/home/presentation/widgets/home_top_bar.dart';
import 'package:envivn/src/features/home/presentation/widgets/home_weather_card.dart';
import 'package:envivn/src/features/home/presentation/widgets/map_shortcut_card.dart';
import 'package:envivn/src/features/home/presentation/widgets/outdoor_activity_advice_card.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_cubit.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_state.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  void _openCitySelector(BuildContext context, HomeDashboardState state) {
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


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateHelper.formatVietnamese(now);

    return Stack(
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

        // Scrollable content
        SafeArea(
          bottom: false,
          child: BlocConsumer<HomeDashboardCubit, HomeDashboardState>(
            listener: (context, state) {
              if (state.noticeMessage != null && state.noticeMessage!.isNotEmpty) {
                context.showSnackBar(state.noticeMessage!);
                context.read<HomeDashboardCubit>().clearNotice();
              }
            },
            builder: (context, dashState) {
              return BlocBuilder<WeatherCubit, WeatherState>(
                builder: (context, weatherState) {
                  return BlocBuilder<AirQualityCubit, AirQualityState>(
                    builder: (context, aqiState) {
                      final isInitialLoading = dashState.isInitialLoading(weatherState.weather.hourlyForecast.length);

                      if (isInitialLoading) {
                        return const LoadingWidget(message: 'Đang tải dữ liệu môi trường...');
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Fixed Top Bar (Location Selector & Notification Bell)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                            decoration: BoxDecoration(
                              // color: UIColors.bg.withOpacity(0.92),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.06),
                                  width: 0.8,
                                ),
                              ),
                            ),
                            child: HomeTopBar(
                              cityName: dashState.currentCity.name,
                              isGps: dashState.currentCity.isGps,
                              dateText: dateStr,
                              hasNotification: dashState.hasNotification,
                              onLocationTap: () => _openCitySelector(context, dashState),
                              onSelectCurrentLocation: () {
                                context.read<HomeDashboardCubit>().detectGpsLocation();
                              },
                              onNotificationTap: () => EnvironmentalNotificationSheet.show(
                                context,
                                cityName: dashState.currentCity.name,
                                airQuality: aqiState.airQuality,
                                weather: weatherState.weather,
                              ),
                            ),
                          ),

                          // 2. Scrollable Body
                          Expanded(
                            child: RefreshIndicator(
                              color: UIColors.primary,
                              backgroundColor: UIColors.cardBg,
                              onRefresh: () => context.read<HomeDashboardCubit>().refresh(),
                              child: ClipRect(
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: ClampingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      // 1. Weather Overview Liquid Glass Card (Mưa gió giông bão nắng mây, dự báo giờ & chỉ số)
                                      HomeWeatherCard(
                                        weather: weatherState.weather,
                                        onDetailTap: () {
                                          context.read<HomeDashboardCubit>().setTab(2);
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      // 2. Hero AQI Liquid Glass Card
                                      HeroAQICard(
                                        airQuality: aqiState.airQuality,
                                        onDetailTap: () {
                                          context.read<HomeDashboardCubit>().setTab(2);
                                        },
                                      ),
                                      const SizedBox(height: 16),


                                      // 3. Outdoor Sports & Activity Advice Card
                                      OutdoorActivityAdviceCard(
                                        airQuality: aqiState.airQuality,
                                        weather: weatherState.weather,
                                      ),
                                      const SizedBox(height: 16),

                                      // 4. Map Shortcut Card
                                      MapShortcutCard(
                                        onTap: () {
                                          final cubit = context.read<HomeDashboardCubit>();
                                          cubit.markPendingMapSync();
                                          cubit.setTab(1);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
