import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/city_selector_sheet.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_cubit.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_state.dart';
import 'package:envivn/src/features/details/presentation/widgets/aqi_24h_chart_card.dart';
import 'package:envivn/src/features/details/presentation/widgets/aqi_pollutants_grid.dart';
import 'package:envivn/src/features/details/presentation/widgets/detail_segmented_filter.dart';
import 'package:envivn/src/features/details/presentation/widgets/details_hero_detail_card.dart';
import 'package:envivn/src/features/details/presentation/widgets/health_advisory_card.dart';
import 'package:envivn/src/features/details/presentation/widgets/hourly_details_slider.dart';
import 'package:envivn/src/features/details/presentation/widgets/seven_day_forecast_card.dart';
import 'package:envivn/src/features/details/presentation/widgets/twenty_four_hour_temp_chart.dart';
import 'package:envivn/src/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TwentyFourHourDetailPage extends StatelessWidget {
  const TwentyFourHourDetailPage({super.key});

  void _openCitySelector(BuildContext context, HomeDashboardState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: UIColors.transparent,
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
            return BlocBuilder<DetailsCubit, DetailsState>(
              builder: (context, detailsState) {
                final aqi = aqiState.airQuality;
                final details = detailsState.details;
                final weatherInfo = WeatherCodeHelper.getInfo(
                  details.weatherCode,
                );
                final aqiInfo = AQIHelper.getAQIInfo(aqi.usAqi);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                      decoration: BoxDecoration(
                        color: UIColors.bg.withOpacity(0.92),
                        border: Border(
                          bottom: BorderSide(
                            color: UIColors.white.withOpacity(0.06),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const AppBackButton(),
                              const Gap(8),
                              Expanded(
                                child: AppText.semiBold(
                                  dateStr,
                                  size: 13,
                                  color: UIColors.textSecondary,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Gap(8),
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 110,
                                            ),
                                            child: AppText.semiBold(
                                              homeState.currentCity.name,
                                              size: 13,
                                              color: UIColors.primaryDark,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const Gap(4),
                                          const AppIcon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: UIColors.textSecondary,
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
                          const Gap(12),

                          DetailSegmentedFilter(
                            activeTab: detailsState.activeDetailTab,
                            onTabChanged: (tab) =>
                                context.read<DetailsCubit>().setDetailTab(tab),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ClipRect(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (detailsState.showWeatherSection) ...[
                                _buildSectionHeader(
                                  title: 'DỰ BÁO THỜI TIẾT 24 GIỜ TỚI',
                                  icon: Icons.wb_sunny_rounded,
                                  iconColor: UIColors.warning,
                                  tag: weatherInfo.shortLabel,
                                  tagColor: weatherInfo.color,
                                ),
                                const Gap(12),
                                DetailsHeroDetailCard(details: details),
                                const Gap(16),
                                TwentyFourHourTempChart(
                                  hourlyList: details.hourlyForecast,
                                ),
                                const Gap(16),
                                HourlyDetailsSlider(
                                  hourlyList: details.hourlyForecast,
                                ),
                                const Gap(16),
                                if (details.dailyForecast.isNotEmpty) ...[
                                  SevenDayForecastCard(
                                    dailyForecast: details.dailyForecast,
                                  ),
                                  const Gap(18),
                                ],
                              ],

                              if (detailsState.showAirQualitySection) ...[
                                _buildSectionHeader(
                                  title: 'CHẤT LƯỢNG KHÔNG KHÍ & BỤI MỊN',
                                  icon: Icons.air_rounded,
                                  iconColor: UIColors.primary,
                                  tag: 'AQI ${aqi.usAqi} • ${aqiInfo.label}',
                                  tagColor: aqiInfo.color,
                                ),
                                const Gap(12),
                                AqiPollutantsGrid(aqi: aqi),
                                const Gap(16),
                                Aqi24hChartCard(hourlyPoints: aqi.hourlyAqi),
                                const Gap(16),
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
              const Gap(6),
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
        const Gap(8),
        AppStatusTag(label: tag, color: tagColor, size: AppTagSize.small),
      ],
    );
  }
}
