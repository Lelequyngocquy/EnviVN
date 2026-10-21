import '../../../../core/domain/entities/base.dart';
import '../../infrastructure/models/thermal_hotspot_model.dart';

abstract class INasaFirmsRepository {
  Future<BaseResult<List<ThermalHotspotModel>>> getVietnamActiveFires({
    bool forceRefresh = false,
  });

  DateTime? getLastUpdateTime();

  bool get isServingCachedData;
}
