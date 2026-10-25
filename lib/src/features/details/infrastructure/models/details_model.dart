import '../../domain/entities/details_entity.dart';

class DetailsModel extends DetailsEntity {
  const DetailsModel({
    super.currentTemp,
    super.apparentTemp,
    super.relativeHumidity,
    super.precipitation,
    super.weatherCode,
    super.windSpeed,
    super.uvIndex,
    super.surfacePressure,
    super.hourlyForecast,
    super.dailyForecast,
    super.isOfflineCache,
  });

  factory DetailsModel.fromJson(
    Map<String, dynamic> json, {
    bool isOfflineCache = false,
  }) {
    final current = (json['current'] is Map)
        ? json['current'] as Map<String, dynamic>
        : <String, dynamic>{};
    final hourly = (json['hourly'] is Map)
        ? json['hourly'] as Map<String, dynamic>
        : <String, dynamic>{};
    final daily = (json['daily'] is Map)
        ? json['daily'] as Map<String, dynamic>
        : <String, dynamic>{};

    final hourlyList = <HourlyDetailsPoint>[];
    if (hourly['time'] is List) {
      final times = hourly['time'] as List;
      final temps = (hourly['temperature_2m'] is List)
          ? hourly['temperature_2m'] as List
          : [];
      final humids = (hourly['relative_humidity_2m'] is List)
          ? hourly['relative_humidity_2m'] as List
          : [];
      final rainProbs = (hourly['precipitation_probability'] is List)
          ? hourly['precipitation_probability'] as List
          : [];
      final codes = (hourly['weather_code'] is List)
          ? hourly['weather_code'] as List
          : [];

      final now = DateTime.now();
      int count = 0;
      for (int i = 0; i < times.length && count < 24; i++) {
        final pointTime = DateTime.tryParse(times[i].toString()) ?? now;

        if (pointTime.isAfter(now.subtract(const Duration(hours: 1)))) {
          hourlyList.add(
            HourlyDetailsPoint(
              time: pointTime,
              temperature: (i < temps.length)
                  ? (double.tryParse(temps[i].toString()) ?? 0.0)
                  : 0.0,
              humidity: (i < humids.length)
                  ? (int.tryParse(humids[i].toString()) ?? 0)
                  : 0,
              precipitationProbability: (i < rainProbs.length)
                  ? (int.tryParse(rainProbs[i].toString()) ?? 0)
                  : 0,
              weatherCode: (i < codes.length)
                  ? (int.tryParse(codes[i].toString()) ?? 0)
                  : 0,
            ),
          );
          count++;
        }
      }
    }

    final dailyList = <DailyDetailsPoint>[];
    if (daily['time'] is List) {
      final dates = daily['time'] as List;
      final codes = (daily['weather_code'] is List)
          ? daily['weather_code'] as List
          : [];
      final maxTemps = (daily['temperature_2m_max'] is List)
          ? daily['temperature_2m_max'] as List
          : [];
      final minTemps = (daily['temperature_2m_min'] is List)
          ? daily['temperature_2m_min'] as List
          : [];
      final rainSums = (daily['precipitation_sum'] is List)
          ? daily['precipitation_sum'] as List
          : [];

      for (int i = 0; i < dates.length && i < 7; i++) {
        dailyList.add(
          DailyDetailsPoint(
            date: DateTime.tryParse(dates[i].toString()) ?? DateTime.now(),
            weatherCode: (i < codes.length)
                ? (int.tryParse(codes[i].toString()) ?? 0)
                : 0,
            maxTemp: (i < maxTemps.length)
                ? (double.tryParse(maxTemps[i].toString()) ?? 0.0)
                : 0.0,
            minTemp: (i < minTemps.length)
                ? (double.tryParse(minTemps[i].toString()) ?? 0.0)
                : 0.0,
            precipitationSum: (i < rainSums.length)
                ? (double.tryParse(rainSums[i].toString()) ?? 0.0)
                : 0.0,
          ),
        );
      }
    }

    return DetailsModel(
      currentTemp:
          double.tryParse(current['temperature_2m']?.toString() ?? '0') ?? 0.0,
      apparentTemp:
          double.tryParse(current['apparent_temperature']?.toString() ?? '0') ??
          0.0,
      relativeHumidity:
          int.tryParse(current['relative_humidity_2m']?.toString() ?? '0') ?? 0,
      precipitation:
          double.tryParse(current['precipitation']?.toString() ?? '0') ?? 0.0,
      weatherCode:
          int.tryParse(current['weather_code']?.toString() ?? '0') ?? 0,
      windSpeed:
          double.tryParse(current['wind_speed_10m']?.toString() ?? '0') ?? 0.0,
      uvIndex: double.tryParse(current['uv_index']?.toString() ?? '0') ?? 0.0,
      surfacePressure:
          double.tryParse(current['surface_pressure']?.toString() ?? '1013') ??
          1013.0,
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
      isOfflineCache: isOfflineCache,
    );
  }
}

// Backward-compatibility alias
typedef WeatherModel = DetailsModel;
