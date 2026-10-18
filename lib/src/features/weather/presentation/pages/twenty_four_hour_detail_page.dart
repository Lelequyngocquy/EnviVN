import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/city_selector_sheet.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_cubit.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_state.dart';
import 'package:envivn/src/features/weather/presentation/widgets/aqi_24h_chart_card.dart';
import 'package:envivn/src/features/weather/presentation/widgets/aqi_pollutants_grid.dart';
import 'package:envivn/src/features/weather/presentation/widgets/detail_segmented_filter.dart';
import 'package:envivn/src/features/weather/presentation/widgets/health_advisory_card.dart';
import 'package:envivn/src/features/weather/presentation/widgets/hourly_weather_slider.dart';
import 'package:envivn/src/features/weather/presentation/widgets/seven_day_forecast_card.dart';
import 'package:envivn/src/features/weather/presentation/widgets/twenty_four_hour_temp_chart.dart';
import 'package:envivn/src/features/weather/presentation/widgets/weather_hero_detail_card.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

class TwentyFourHourDetailPage extends StatelessWidget {
  const TwentyFourHourDetailPage({super.key});

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
    final dateStr = DateHelper.formatVietnameseFull(now);

    return Scaffold(
      backgroundColor: UIColors.bg,
      body: SafeArea(
        child: BlocBuilder<AirQualityCubit, AirQualityState>(
          builder: (context, aqiState) {
            return BlocBuilder<WeatherCubit, WeatherState>(
              builder: (context, weatherState) {
                final aqi = aqiState.airQuality;
                final weather = weatherState.weather;
                final weatherInfo = WeatherCodeHelper.getInfo(
                  weather.weatherCode,
                );
                final aqiInfo = AQIHelper.getAQIInfo(aqi.usAqi);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Fixed Top Header & Filter Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                      decoration: BoxDecoration(
                        color: UIColors.bg.withOpacity(0.92),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.06),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppText.bold(
                                      'Chi tiết 24 giờ',
                                      size: 22,
                                      color: UIColors.textPrimary,
                                    ),
                                    const SizedBox(height: 2),
                                    AppText.regular(
                                      dateStr,
                                      size: 12,
                                      color: UIColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              BlocBuilder<
                                HomeDashboardCubit,
                                HomeDashboardState
                              >(
                                buildWhen: (prev, curr) =>
                                    prev.currentCity != curr.currentCity,
                                builder: (context, homeState) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _openCitySelector(context, homeState),
                                    child: AppGlass(
                                      isFixed: true,
                                      borderRadius: 18,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          AppText.semiBold(
                                            homeState.currentCity.name,
                                            size: 13,
                                            color: UIColors.primaryDark,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(width: 4),
                                          const AppIcon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.grey,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Segmented Filter Pills (State managed via WeatherCubit)
                          DetailSegmentedFilter(
                            activeTab: weatherState.activeDetailTab,
                            onTabChanged: (tab) =>
                                context.read<WeatherCubit>().setDetailTab(tab),
                          ),
                        ],
                      ),
                    ),

                    // 2. Scrollable Body
                    Expanded(
                      child: ClipRect(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 3. WEATHER SECTION (Controlled by WeatherState getter)
                              if (weatherState.showWeatherSection) ...[
                                _buildSectionHeader(
                                  title: 'DỰ BÁO THỜI TIẾT 24 GIỜ TỚI',
                                  icon: Icons.wb_sunny_rounded,
                                  iconColor: UIColors.warning,
                                  tag: weatherInfo.shortLabel,
                                  tagColor: weatherInfo.color,
                                ),
                                const SizedBox(height: 12),
                                WeatherHeroDetailCard(weather: weather),
                                const SizedBox(height: 16),
                                TwentyFourHourTempChart(
                                  hourlyList: weather.hourlyForecast,
                                ),
                                const SizedBox(height: 16),
                                HourlyWeatherSlider(
                                  hourlyList: weather.hourlyForecast,
                                ),
                                const SizedBox(height: 16),
                                if (weather.dailyForecast.isNotEmpty) ...[
                                  SevenDayForecastCard(
                                    dailyForecast: weather.dailyForecast,
                                  ),
                                  const SizedBox(height: 18),
                                ],
                              ],

                              // 4. AIR QUALITY SECTION (Controlled by WeatherState getter)
                              if (weatherState.showAirQualitySection) ...[
                                _buildSectionHeader(
                                  title: 'CHẤT LƯỢNG KHÔNG KHÍ & BỤI MỊN',
                                  icon: Icons.air_rounded,
                                  iconColor: UIColors.primary,
                                  tag: 'AQI ${aqi.usAqi} • ${aqiInfo.label}',
                                  tagColor: aqiInfo.color,
                                ),
                                const SizedBox(height: 12),
                                AqiPollutantsGrid(aqi: aqi),
                                const SizedBox(height: 16),
                                Aqi24hChartCard(hourlyPoints: aqi.hourlyAqi),
                                const SizedBox(height: 16),
                                const HealthAdvisoryCard(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String tag,
    required Color tagColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              AppIcon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.bold(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  size: 11,
                  letterSpacing: 0.8,
                  color: UIColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AppStatusTag(label: tag, color: tagColor, size: AppTagSize.small),
      ],
    );
  }
}
