import 'package:flutter/material.dart';
import '../../../../common/constants/colors.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../domain/entities/air_quality_entity.dart';

class PollutantGridWidget extends StatelessWidget {
  final AirQualityEntity airQuality;

  const PollutantGridWidget({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UIColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              AppIcon(Icons.grain_rounded, color: UIColors.primary, size: 20),
              SizedBox(width: 8),
              AppText.bold(
                'Nồng độ các chất ô nhiễm',
                size: 14,
                color: UIColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              _PollutantItem(
                name: 'PM2.5',
                value: airQuality.pm25.toStringAsFixed(1),
                unit: 'µg/m³',
                isWarning: airQuality.pm25 > 35.0,
              ),
              _PollutantItem(
                name: 'PM10',
                value: airQuality.pm10.toStringAsFixed(1),
                unit: 'µg/m³',
                isWarning: airQuality.pm10 > 50.0,
              ),
              _PollutantItem(
                name: 'O₃ (Ozone)',
                value: airQuality.ozone.toStringAsFixed(1),
                unit: 'µg/m³',
                isWarning: airQuality.ozone > 100.0,
              ),
              _PollutantItem(
                name: 'NO₂',
                value: airQuality.nitrogenDioxide.toStringAsFixed(1),
                unit: 'µg/m³',
                isWarning: airQuality.nitrogenDioxide > 40.0,
              ),
              _PollutantItem(
                name: 'SO₂',
                value: airQuality.sulphurDioxide.toStringAsFixed(1),
                unit: 'µg/m³',
                isWarning: airQuality.sulphurDioxide > 20.0,
              ),
              _PollutantItem(
                name: 'CO',
                value: airQuality.carbonMonoxide.toStringAsFixed(0),
                unit: 'µg/m³',
                isWarning: airQuality.carbonMonoxide > 1000.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PollutantItem extends StatelessWidget {
  final String name;
  final String value;
  final String unit;
  final bool isWarning;

  const _PollutantItem({
    required this.name,
    required this.value,
    required this.unit,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade50 : UIColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? Colors.red.shade200 : UIColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText.semiBold(
            name,
            size: 11,
            color: isWarning ? Colors.red.shade800 : UIColors.textSecondary,
          ),
          const SizedBox(height: 4),
          AppText.bold(
            value,
            size: 15,
            color: isWarning ? Colors.red.shade900 : UIColors.textPrimary,
          ),
          AppText.regular(
            unit,
            size: 9,
            color: isWarning ? Colors.red.shade700 : UIColors.textLight,
          ),
        ],
      ),
    );
  }
}
