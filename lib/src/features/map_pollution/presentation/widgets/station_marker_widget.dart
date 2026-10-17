import 'package:flutter/material.dart';

import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/station_pollution_entity.dart';

class StationMarkerWidget extends StatelessWidget {
  final StationPollutionEntity station;
  final bool isSelected;
  final VoidCallback onTap;

  const StationMarkerWidget({
    super.key,
    required this.station,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = AQIHelper.getAQIInfo(station.aqi);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : info.color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: info.color.withOpacity(0.6),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: isSelected ? info.color : Colors.white,
                width: 2,
              ),
            ),
            child: Text(
              '${station.aqi}',
              style: TextStyle(
                color: isSelected ? info.color : const Color(0xFF0B1220),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 16,
            shadows: [Shadow(blurRadius: 3, color: Colors.black)],
          ),
        ],
      ),
    );
  }
}
