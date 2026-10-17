import '../../domain/entities/air_quality_entity.dart';

class AirQualityModel extends AirQualityEntity {
  const AirQualityModel({
    super.usAqi,
    super.europeanAqi,
    super.pm25,
    super.pm10,
    super.carbonMonoxide,
    super.nitrogenDioxide,
    super.sulphurDioxide,
    super.ozone,
    super.hourlyAqi,
    super.isOfflineCache,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json, {bool isOfflineCache = false}) {
    final current = (json['current'] is Map) ? json['current'] as Map<String, dynamic> : <String, dynamic>{};
    final hourly = (json['hourly'] is Map) ? json['hourly'] as Map<String, dynamic> : <String, dynamic>{};

    final hourlyList = <HourlyAqiPoint>[];
    if (hourly['time'] is List) {
      final times = hourly['time'] as List;
      final aqis = (hourly['us_aqi'] is List) ? hourly['us_aqi'] as List : [];
      final pm25s = (hourly['pm2_5'] is List) ? hourly['pm2_5'] as List : [];
      final pm10s = (hourly['pm10'] is List) ? hourly['pm10'] as List : [];

      final now = DateTime.now();
      int count = 0;
      for (int i = 0; i < times.length && count < 24; i++) {
        final pointTime = DateTime.tryParse(times[i].toString()) ?? now;
        if (pointTime.isAfter(now.subtract(const Duration(hours: 1)))) {
          hourlyList.add(
            HourlyAqiPoint(
              time: pointTime,
              aqi: (i < aqis.length) ? (int.tryParse(aqis[i].toString()) ?? 0) : 0,
              pm25: (i < pm25s.length) ? (double.tryParse(pm25s[i].toString()) ?? 0.0) : 0.0,
              pm10: (i < pm10s.length) ? (double.tryParse(pm10s[i].toString()) ?? 0.0) : 0.0,
            ),
          );
          count++;
        }
      }
    }

    return AirQualityModel(
      usAqi: int.tryParse(current['us_aqi']?.toString() ?? '0') ?? 0,
      europeanAqi: int.tryParse(current['european_aqi']?.toString() ?? '0') ?? 0,
      pm25: double.tryParse(current['pm2_5']?.toString() ?? '0') ?? 0.0,
      pm10: double.tryParse(current['pm10']?.toString() ?? '0') ?? 0.0,
      carbonMonoxide: double.tryParse(current['carbon_monoxide']?.toString() ?? '0') ?? 0.0,
      nitrogenDioxide: double.tryParse(current['nitrogen_dioxide']?.toString() ?? '0') ?? 0.0,
      sulphurDioxide: double.tryParse(current['sulphur_dioxide']?.toString() ?? '0') ?? 0.0,
      ozone: double.tryParse(current['ozone']?.toString() ?? '0') ?? 0.0,
      hourlyAqi: hourlyList,
      isOfflineCache: isOfflineCache,
    );
  }
}
