import '../../../../core/domain/entities/base.dart';
import '../entities/details_entity.dart';

abstract class IDetailsRepository {
  Future<BaseResult<DetailsEntity>> getDetailsForecast({
    required double latitude,
    required double longitude,
  });

  DetailsEntity? getCachedDetails();

  // Backward-compatibility methods
  Future<BaseResult<DetailsEntity>> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) => getDetailsForecast(latitude: latitude, longitude: longitude);

  DetailsEntity? getCachedWeather() => getCachedDetails();
}

// Backward-compatibility alias
typedef IWeatherRepository = IDetailsRepository;
