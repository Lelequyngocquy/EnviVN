import '../../../../core/domain/entities/base.dart';
import '../entities/weather_entity.dart';

abstract class IWeatherRepository {
  /// Fetches weather forecast from Open-Meteo API by coordinates
  Future<BaseResult<WeatherEntity>> getWeatherForecast({
    required double latitude,
    required double longitude,
  });

  /// Retrieves the last cached weather data from local storage
  WeatherEntity? getCachedWeather();
}
