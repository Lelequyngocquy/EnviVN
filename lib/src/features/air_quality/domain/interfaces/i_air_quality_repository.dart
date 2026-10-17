import '../../../../core/domain/entities/base.dart';
import '../entities/air_quality_entity.dart';

abstract class IAirQualityRepository {
  /// Fetches real-time air quality data by coordinates
  Future<BaseResult<AirQualityEntity>> getAirQuality({
    required double latitude,
    required double longitude,
  });

  /// Retrieves the last cached air quality data from local storage
  AirQualityEntity? getCachedAirQuality();
}
