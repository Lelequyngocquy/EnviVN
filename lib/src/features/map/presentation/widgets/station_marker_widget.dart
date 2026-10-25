import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/features/map/domain/entities/station_entity.dart';
import 'package:flutter/material.dart';

class StationMarkerWidget extends StatelessWidget {
  final StationEntity station;
  final bool isSelected;
  final VoidCallback onTap;
  final MapLayerType activeLayer;

  const StationMarkerWidget({
    super.key,
    required this.station,
    required this.isSelected,
    required this.onTap,
    this.activeLayer = MapLayerType.weather,
  });

  @override
  Widget build(BuildContext context) {
    final aqiInfo = AQIHelper.getAQIInfo(station.aqi);
    final weatherInfo = WeatherCodeHelper.getInfo(station.weatherCode);

    Color badgeColor;
    Widget content;

    switch (activeLayer) {
      case MapLayerType.weather:
        badgeColor = weatherInfo.color;
        final tempStr = (station.temperature ?? 28.0).toStringAsFixed(0);
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              weatherInfo.icon,
              size: 13,
              color: isSelected ? badgeColor : UIColors.bg,
            ),
            const Gap(3),
            AppText.extraBold(
              '$tempStr°',
              color: isSelected ? badgeColor : UIColors.bg,
              size: 11.5,
            ),
          ],
        );
        break;

      case MapLayerType.airQuality:
        badgeColor = aqiInfo.color;
        content = AppText.extraBold(
          '${station.aqi}',
          color: isSelected ? badgeColor : UIColors.bg,
          size: 12,
        );
        break;

      case MapLayerType.thermal:
        badgeColor = station.heatRiskLevel.color;
        final heatStr = station.calculatedHeatIndex.toStringAsFixed(0);
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              Icons.local_fire_department_rounded,
              size: 12,
              color: isSelected ? badgeColor : UIColors.bg,
            ),
            const Gap(2),
            AppText.extraBold(
              '$heatStr°',
              color: isSelected ? badgeColor : UIColors.bg,
              size: 11.5,
            ),
          ],
        );
        break;

      case MapLayerType.flood:
        final rainVal = station.precipitation ?? 0.0;
        final isHeavyRain = rainVal >= 20.0;
        final hasRain = rainVal > 0.0;

        if (isHeavyRain) {
          badgeColor = UIColors.markerRed;
        } else if (hasRain) {
          badgeColor = UIColors.secondary;
        } else {
          badgeColor = UIColors.aqiGood;
        }

        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              isHeavyRain
                  ? Icons.waves_rounded
                  : (hasRain ? Icons.water_drop_rounded : Icons.check_rounded),
              size: 11.5,
              color: isSelected ? badgeColor : UIColors.bg,
            ),
            const Gap(2),
            AppText.extraBold(
              '${rainVal.toStringAsFixed(0)}mm',
              color: isSelected ? badgeColor : UIColors.bg,
              size: 11.0,
            ),
          ],
        );
        break;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
          decoration: BoxDecoration(
            color: isSelected ? UIColors.white : badgeColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withOpacity(0.65),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isSelected ? badgeColor : UIColors.white,
              width: 1.8,
            ),
          ),
          child: FittedBox(fit: BoxFit.scaleDown, child: content),
        ),
      ),
    );
  }
}
