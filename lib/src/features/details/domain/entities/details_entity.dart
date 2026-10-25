class DetailsEntity {
  final double currentTemp;
  final double apparentTemp;
  final int relativeHumidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final double uvIndex;
  final double surfacePressure;
  final List<HourlyDetailsPoint> hourlyForecast;
  final List<DailyDetailsPoint> dailyForecast;
  final bool isOfflineCache;

  const DetailsEntity({
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

class HourlyDetailsPoint {
  final DateTime time;
  final double temperature;
  final int humidity;
  final int precipitationProbability;
  final int weatherCode;

  const HourlyDetailsPoint({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitationProbability,
    required this.weatherCode,
  });
}

class DailyDetailsPoint {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final double precipitationSum;

  const DailyDetailsPoint({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationSum,
  });
}

typedef WeatherEntity = DetailsEntity;
typedef HourlyWeatherPoint = HourlyDetailsPoint;
typedef DailyWeatherPoint = DailyDetailsPoint;
