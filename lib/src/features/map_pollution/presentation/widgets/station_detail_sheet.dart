import 'package:flutter/material.dart';
import 'package:envivn/src/core/presentation/widgets/app_bottom_sheet.dart';
import '../../../../common/constants/colors.dart';
import '../../../../common/utils/aqi_helper.dart';
import '../../domain/entities/station_pollution_entity.dart';

class StationDetailSheet extends StatelessWidget {
  final StationPollutionEntity station;

  const StationDetailSheet({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final info = AQIHelper.getAQIInfo(station.aqi);

    return AppBottomSheet(
      title: station.name,
      subtitle: 'Khu vực: ${station.province}',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: info.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: info.color.withOpacity(0.3)),
        ),
        child: Text(
          info.label,
          style: TextStyle(
            color: info.color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      bottomButtonText: 'Đóng',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${station.aqi}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: info.color,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'US AQI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: UIColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _MetricRow(
                      label: 'Bụi mịn PM2.5',
                      value: '${station.pm25.toStringAsFixed(1)} µg/m³',
                      isHigh: station.pm25 > 35,
                    ),
                    const Divider(height: 16, color: UIColors.border),
                    _MetricRow(
                      label: 'Bụi PM10',
                      value: '${station.pm10.toStringAsFixed(1)} µg/m³',
                      isHigh: station.pm10 > 50,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UIColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  info.wearMask ? Icons.masks_rounded : Icons.check_circle_rounded,
                  color: info.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.healthAdvice,
                    style: const TextStyle(
                      fontSize: 12,
                      color: UIColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHigh;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.isHigh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: UIColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHigh ? UIColors.error : UIColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
