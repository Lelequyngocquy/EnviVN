class WeatherEntity {
  final double currentTemp;
  final double apparentTemp;
  final int relativeHumidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final double uvIndex;
  final double surfacePressure;
  final List<HourlyWeatherPoint> hourlyForecast;
  final List<DailyWeatherPoint> dailyForecast;
  final bool isOfflineCache;

  const WeatherEntity({
    this.currentTemp = 0.0,
    this.apparentTemp = 0.0,
    this.relativeHumidity = 0,
    this.precipitation = 0.0,
    this.weatherCode = 0,
    this.windSpeed = 0.0,
    this.uvIndex = 0.0,
    this.surfacePressure = 1013.0,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
    this.isOfflineCache = false,
  });
}

class HourlyWeatherPoint {
  final DateTime time;
  final double temperature;
  final int humidity;
  final int precipitationProbability;
  final int weatherCode;

  const HourlyWeatherPoint({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitationProbability,
    required this.weatherCode,
  });
}

class DailyWeatherPoint {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final double precipitationSum;

  const DailyWeatherPoint({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationSum,
  });
}
