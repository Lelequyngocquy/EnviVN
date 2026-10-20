import 'package:flutter/material.dart';
import '../../../../common/constants/colors.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherMetricCards extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherMetricCards({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _MetricCard(
            icon: Icons.water_drop_outlined,
            iconColor: UIColors.secondary,
            title: 'Độ ẩm',
            value: '${weather.relativeHumidity}%',
            subText: weather.relativeHumidity > 80 ? 'Ẩm cao' : 'Thoáng đãng',
          ),
          _MetricCard(
            icon: Icons.air_rounded,
            iconColor: UIColors.primaryLight,
            title: 'Gió',
            value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
            subText: weather.windSpeed > 20 ? 'Gió mạnh' : 'Gió nhẹ',
          ),
          _MetricCard(
            icon: Icons.wb_sunny_outlined,
            iconColor: UIColors.warning,
            title: 'Chỉ số UV',
            value: weather.uvIndex.toStringAsFixed(1),
            subText: weather.uvIndex >= 6 ? 'Cần chống nắng' : 'Mức an toàn',
          ),
          _MetricCard(
            icon: Icons.speed_rounded,
            iconColor: UIColors.gpsBlue,
            title: 'Áp suất khí quyển',
            value: '${weather.surfacePressure.toStringAsFixed(0)} hPa',
            subText: 'Chuẩn khí quyển',
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subText;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UIColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UIColors.border),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppIcon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.medium(
                  title,
                  size: 12,
                  color: UIColors.textSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bold(
                value,
                size: 18,
                color: UIColors.textPrimary,
              ),
              const SizedBox(height: 2),
              AppText.semiBold(
                subText,
                size: 11,
                color: iconColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
