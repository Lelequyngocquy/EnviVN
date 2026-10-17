import '../../../../core/domain/entities/base.dart';
import '../entities/station_pollution_entity.dart';

abstract class IMapPollutionRepository {
  /// Fetches real-time environmental data across key monitoring stations in Vietnam
  Future<BaseResult<List<StationPollutionEntity>>> getVietnamStations();
}
