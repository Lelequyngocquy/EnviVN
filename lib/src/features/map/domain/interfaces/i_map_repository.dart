import '../../../../core/domain/entities/base.dart';
import '../entities/station_entity.dart';

abstract class IMapRepository {
  Future<BaseResult<List<StationEntity>>> getVietnamStations();
}
