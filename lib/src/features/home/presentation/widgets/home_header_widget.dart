import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/shared/router/router_key_manager.dart';

class HomeHeaderWidget extends StatelessWidget {
  final CityEntity city;
  final DateTime? lastUpdated;
  final WeatherEntity weather;
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
            // Top Bar: Location Selector & Action Buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onSelectCity,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            city.isGps ? Icons.my_location_rounded : Icons.location_on_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              city.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDetectGps,
                  icon: const Icon(Icons.gps_fixed_rounded, color: Colors.white),
                  tooltip: 'Định vị GPS của tôi',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouterPath.pollutionMap);
                  },
                  icon: const Icon(Icons.map_rounded, color: Colors.white),
                  tooltip: 'Bản đồ ô nhiễm',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Weather Overview Hero Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.currentTemp.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'C',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cảm giác như: ${weather.apparentTemp.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      weatherInfo.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    weatherInfo.icon,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lastUpdated != null)
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 12, color: Colors.white60),
                  const SizedBox(width: 4),
                  Text(
                    'Cập nhật: ${DateFormat('HH:mm - dd/MM/yyyy').format(lastUpdated!)}',
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                  if (weather.isOfflineCache) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Ngoại tuyến',
                        style: TextStyle(fontSize: 10, color: Colors.white),
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
