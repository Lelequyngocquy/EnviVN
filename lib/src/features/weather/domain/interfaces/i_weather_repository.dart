import '../../../../core/domain/entities/base.dart';
import '../entities/weather_entity.dart';

abstract class IWeatherRepository {
  
  Future<BaseResult<WeatherEntity>> getWeatherForecast({
    required double latitude,
    required double longitude,
  });

  
  WeatherEntity? getCachedWeather();
}
