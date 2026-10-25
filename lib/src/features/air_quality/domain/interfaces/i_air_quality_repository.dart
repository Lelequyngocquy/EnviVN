import '../../../../core/domain/entities/base.dart';
import '../entities/air_quality_entity.dart';

abstract class IAirQualityRepository {
  Future<BaseResult<AirQualityEntity>> getAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  });

  AirQualityEntity? getCachedAirQuality({double? latitude, double? longitude});
}
