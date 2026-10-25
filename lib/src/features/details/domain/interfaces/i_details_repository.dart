import '../../../../core/domain/entities/base.dart';
import '../entities/details_entity.dart';

abstract class IDetailsRepository {
  Future<BaseResult<DetailsEntity>> getDetailsForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  });

  DetailsEntity? getCachedDetails({double? latitude, double? longitude});

  Future<BaseResult<DetailsEntity>> getWeatherForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) => getDetailsForecast(
    latitude: latitude,
    longitude: longitude,
    forceRefresh: forceRefresh,
  );

  DetailsEntity? getCachedWeather({double? latitude, double? longitude}) =>
      getCachedDetails(latitude: latitude, longitude: longitude);
}

typedef IWeatherRepository = IDetailsRepository;
