import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/shared/router/router_key_manager.dart';

class HomeHeaderWidget extends StatelessWidget {
  final CityEntity city;
  final DateTime? lastUpdated;
  final DetailsEntity weather;
  final VoidCallback onSelectCity;
  final VoidCallback onDetectGps;

  const HomeHeaderWidget({
    super.key,
    required this.city,
    this.lastUpdated,
    required this.weather,
    required this.onSelectCity,
    required this.onDetectGps,
  });

  @override
  Widget build(BuildContext context) {
    final weatherInfo = WeatherCodeHelper.getInfo(weather.weatherCode);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: UIColors.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: UIColors.primaryDark.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onSelectCity,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: UIColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            city.isGps
                                ? Icons.my_location_rounded
                                : Icons.location_on_rounded,
                            color: UIColors.white,
                            size: 18,
                          ),
                          const Gap(6),
                          Flexible(
                            child: AppText.bold(
                              city.name,
                              color: UIColors.textPrimary,
                              size: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const AppIcon(
                            Icons.keyboard_arrow_down_rounded,
                            color: UIColors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                IconButton(
                  onPressed: onDetectGps,
                  icon: const AppIcon(
                    Icons.gps_fixed_rounded,
                    color: UIColors.white,
                  ),
                  tooltip: 'Định vị GPS của tôi',
                  style: IconButton.styleFrom(
                    backgroundColor: UIColors.white.withOpacity(0.15),
                  ),
                ),
                const Gap(6),
                IconButton(
                  onPressed: () {
                    try {
                      final cubit = context.read<HomeDashboardCubit>();
                      cubit.markPendingMapSync();
                      cubit.setTab(1);
                    } catch (_) {
                      Navigator.pushNamed(context, RouterPath.map);
                    }
                  },
                  icon: const AppIcon(Icons.map_rounded, color: UIColors.white),
                  tooltip: 'Bản đồ',
                  style: IconButton.styleFrom(
                    backgroundColor: UIColors.white.withOpacity(0.15),
                  ),
                ),
              ],
            ),
            const Gap(18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold(
                          '${weather.currentTemp.toStringAsFixed(0)}°',
                          size: 48,
                          color: UIColors.textPrimary,
                          height: 1.0,
                        ),
                        const Gap(4),
                        const AppText.bold(
                          'C',
                          size: 20,
                          color: UIColors.white70,
                        ),
                      ],
                    ),
                    const Gap(4),
                    AppText.regular(
                      'Cảm giác như: ${weather.apparentTemp.toStringAsFixed(0)}°C',
                      size: 13,
                      color: UIColors.white70,
                    ),
                    AppText.semiBold(
                      weatherInfo.description,
                      size: 14,
                      color: UIColors.textPrimary,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: UIColors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    weatherInfo.icon,
                    size: 48,
                    color: UIColors.white,
                  ),
                ),
              ],
            ),
            const Gap(12),
            if (lastUpdated != null)
              Row(
                children: [
                  const AppIcon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: UIColors.textSecondary,
                  ),
                  const Gap(4),
                  AppText.regular(
                    'Cập nhật: ${DateFormat('HH:mm - dd/MM/yyyy').format(lastUpdated!)}',
                    size: 11,
                    color: UIColors.textSecondary,
                  ),
                  if (weather.isOfflineCache) ...[
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: UIColors.cardGlassBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const AppText.regular(
                        'Ngoại tuyến',
                        size: 10,
                        color: UIColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
