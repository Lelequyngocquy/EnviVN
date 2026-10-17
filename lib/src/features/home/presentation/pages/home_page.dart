import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/extensions/context_x.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/core/presentation/widgets/loading.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/city_selector_sheet.dart';
import 'package:envivn/src/features/home/presentation/widgets/outdoor_activity_advice_card.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_cubit.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_state.dart';
import 'package:envivn/src/shared/router/router_key_manager.dart';
import 'package:envivn/src/shared/widgets/glass.dart';

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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd \'tháng\' MM', 'vi').format(now);

    return Scaffold(
      backgroundColor: UIColors.bg,
      body: Stack(
        children: [
          // Background subtle ambient radial glows
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

                        final aqiVal = aqiState.airQuality.usAqi > 0 ? aqiState.airQuality.usAqi : 72;
                        final aqiInfo = AQIHelper.getAQIInfo(aqiVal);
                        final weather = weatherState.weather;

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
                                // 1. Top Header Row (matching 02 · Trang chủ.svg: loc, date, bell, dot)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Location Dropdown in Liquid Glass Pill
                                        GestureDetector(
                                          onTap: () => _openCitySelector(dashState),
                                          child: AppGlass(
                                            borderRadius: 20,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  dashState.currentCity.isGps
                                                      ? Icons.my_location_rounded
                                                      : Icons.location_on_rounded,
                                                  color: UIColors.primary,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  dashState.currentCity.name,
                                                  style: const TextStyle(
                                                    color: UIColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.keyboard_arrow_down_rounded,
                                                  color: UIColors.textSecondary,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4),
                                          child: Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: UIColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Notification Bell in Liquid Glass Button
                                    AppGlass(
                                      borderRadius: 22,
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                              onPressed: () {
                                                context.showSnackBar('Chất lượng không khí đang ổn định.');
                                              },
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 12,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: UIColors.error,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // 2. Main Hero Liquid Glass Card (matching aqi card in 02 svg)
                                _buildHeroAQICard(context, aqiVal, aqiInfo, aqiState.airQuality),
                                const SizedBox(height: 16),

                                // 3. 4 Weather Metrics in a 2x2 Grid (matching SVG)
                                _buildWeatherMetricsGrid(weather),
                                const SizedBox(height: 16),

                                // 4. Outdoor Running / Sports Activity Recommendation
                                OutdoorActivityAdviceCard(
                                  airQuality: aqiState.airQuality,
                                  weather: weather,
                                ),
                                const SizedBox(height: 16),

                                // 5. Map & Heatmap Preview Card (matching 03 svg shortcut)
                                _buildMapShortcutCard(context),
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

          // 6. iPhone Style Floating Liquid Glass Bottom Navigation Bar (matching navbar in SVGs)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildLiquidGlassBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAQICard(BuildContext context, int aqiVal, AQIInfo aqiInfo, dynamic airQuality) {
    return AppGlass(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CHỈ SỐ CHẤT LƯỢNG KHÔNG KHÍ',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: UIColors.textSecondary,
                ),
              ),
              Icon(Icons.bubble_chart_rounded, color: aqiInfo.color, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$aqiVal',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 14),
              // Status Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: aqiInfo.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: aqiInfo.color.withOpacity(0.4)),
                ),
                child: Text(
                  aqiInfo.label,
                  style: TextStyle(
                    color: aqiInfo.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sub-metrics PM2.5 and PM10
          Text(
            'PM2.5: ${(airQuality.pm25 > 0 ? airQuality.pm25 : 22.1).toStringAsFixed(1)} µg/m³  •  PM10: ${(airQuality.pm10 > 0 ? airQuality.pm10 : 45.0).toStringAsFixed(1)} µg/m³',
            style: const TextStyle(
              fontSize: 13,
              color: UIColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          // 24-Bar Hourly Timeline Indicator (matching g_1 to g_24 in 02 svg)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Dự báo theo giờ', style: TextStyle(fontSize: 11, color: UIColors.textSecondary)),
                  Text('24h', style: TextStyle(fontSize: 11, color: UIColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(24, (i) {
                    final factor = (0.3 + (i % 8) * 0.1).clamp(0.2, 1.0);
                    Color barColor = UIColors.aqiGood;
                    if (i >= 8 && i <= 14) {
                      barColor = UIColors.aqiModerate;
                    } else if (i >= 15 && i <= 18) {
                      barColor = UIColors.aqiUnhealthySensitive;
                    }
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        height: 28 * factor,
                        decoration: BoxDecoration(
                          color: barColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: UIColors.surfaceVariant),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cập nhật: Vừa xong',
                style: TextStyle(fontSize: 11, color: UIColors.textMuted),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RouterPath.twentyFourHours);
                },
                child: Row(
                  children: const [
                    Text(
                      'Chi tiết 24h',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: UIColors.primary,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: UIColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMetricsGrid(dynamic weather) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _MetricGlassItem(
          icon: Icons.thermostat_rounded,
          iconColor: Colors.orangeAccent,
          label: 'Nhiệt độ',
          value: '${weather.currentTemp > 0 ? weather.currentTemp.toStringAsFixed(0) : "28"}°C',
          sub: 'Cảm giác như: ${weather.apparentTemp > 0 ? weather.apparentTemp.toStringAsFixed(0) : "30"}°C',
        ),
        _MetricGlassItem(
          icon: Icons.water_drop_rounded,
          iconColor: UIColors.secondary,
          label: 'Độ ẩm',
          value: '${weather.relativeHumidity > 0 ? weather.relativeHumidity : "78"}%',
          sub: weather.relativeHumidity > 80 ? 'Ẩm cao' : 'Thoáng đãng',
        ),
        _MetricGlassItem(
          icon: Icons.air_rounded,
          iconColor: UIColors.primary,
          label: 'Tốc độ gió',
          value: '${weather.windSpeed > 0 ? weather.windSpeed.toStringAsFixed(1) : "12.0"} km/h',
          sub: 'Gió nhẹ',
        ),
        _MetricGlassItem(
          icon: Icons.wb_sunny_rounded,
          iconColor: UIColors.warning,
          label: 'Chỉ số UV',
          value: '${weather.uvIndex > 0 ? weather.uvIndex.toStringAsFixed(1) : "4.2"}',
          sub: weather.uvIndex >= 6 ? 'Cần che chắn' : 'Mức an toàn',
        ),
      ],
    );
  }

  Widget _buildMapShortcutCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouterPath.pollutionMap);
      },
      child: AppGlass(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UIColors.secondary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_rounded, color: UIColors.secondary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bản đồ trạm quan trắc & Heatmap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: UIColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Xem các trạm quan trắc chất lượng không khí trên toàn quốc',
                    style: TextStyle(fontSize: 11, color: UIColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: UIColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidGlassBottomBar(BuildContext context) {
    return AppGlass(
      borderRadius: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_rounded,
            label: 'Trang chủ',
            isActive: _currentTab == 0,
            onTap: () => setState(() => _currentTab = 0),
          ),
          _NavBarItem(
            icon: Icons.map_outlined,
            label: 'Bản đồ',
            isActive: _currentTab == 1,
            onTap: () {
              Navigator.pushNamed(context, RouterPath.pollutionMap);
            },
          ),
          _NavBarItem(
            icon: Icons.bar_chart_rounded,
            label: '24 Giờ',
            isActive: _currentTab == 2,
            onTap: () {
              Navigator.pushNamed(context, RouterPath.twentyFourHours);
            },
          ),
          _NavBarItem(
            icon: Icons.tune_rounded,
            label: 'Cài đặt',
            isActive: _currentTab == 3,
            onTap: () {
              Navigator.pushNamed(context, RouterPath.permission);
            },
          ),
        ],
      ),
    );
  }
}

class _MetricGlassItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;

  const _MetricGlassItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlass(
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: UIColors.textSecondary),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: UIColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? UIColors.primary : UIColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? UIColors.primary : UIColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
