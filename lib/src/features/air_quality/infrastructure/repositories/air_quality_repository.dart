import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/base.dart';
import '../../../../core/infrastructure/datasources/local/local_storage.dart';
import '../../../../core/infrastructure/datasources/network/api/configs/endpoint.dart';
import '../../../../core/infrastructure/datasources/network/api/restful_request.dart';
import '../../domain/entities/air_quality_entity.dart';
import '../../domain/interfaces/i_air_quality_repository.dart';
import '../models/air_quality_model.dart';
import '../paths/air_quality_paths.dart';

class AirQualityRepository implements IAirQualityRepository {
  final RestfulRequest network;
  final LocalStorage storage;

  AirQualityRepository({
    required this.network,
    required this.storage,
  });

  @override
  Future<BaseResult<AirQualityEntity>> getAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final endpoint = EndpointType(
        path: AirQualityPaths.airQuality,
        customBaseUrl: AirQualityPaths.airQualityBaseUrl,
        method: HttpMethod.get,
        params: {
          'latitude': latitude,
          'longitude': longitude,
          'current': 'european_aqi,us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone',
          'hourly': 'pm2_5,pm10,us_aqi',
          'timezone': 'auto',
        },
      );

      final response = await network.requestData(endpoint, showErrorToast: false);

      if (response.isSuccess && response.data is Map) {
        final dataMap = Map<String, dynamic>.from(response.data as Map);
        final airQuality = AirQualityModel.fromJson(dataMap);

        // Cache for offline resilience
        await storage.saveCachedAirQuality(dataMap);

        return BaseResult(success: true, data: airQuality);
      }

      // Fallback to cache
      final cached = getCachedAirQuality();
      if (cached != null) {
        return BaseResult(
          success: true,
          message: 'Đang hiển thị chỉ số không khí lưu ngoại tuyến',
          data: cached,
        );
      }

      return BaseResult(
        success: false,
        message: response.message ?? 'Không thể tải chỉ số chất lượng không khí',
        data: const AirQualityEntity(),
      );
    } catch (e) {
      debugPrint('❌ [AirQualityRepository] Lỗi: $e');
      final cached = getCachedAirQuality();
      if (cached != null) {
        return BaseResult(
          success: true,
          message: 'Đang hiển thị chỉ số không khí từ bộ nhớ đệm',
          data: cached,
        );
      }

      return BaseResult(
        success: false,
        message: 'Lỗi tải chất lượng không khí: $e',
        data: const AirQualityEntity(),
      );
    }
  }

  @override
  AirQualityEntity? getCachedAirQuality() {
    final cachedJson = storage.getCachedAirQuality();
    if (cachedJson != null) {
      return AirQualityModel.fromJson(cachedJson, isOfflineCache: true);
    }
    return null;
  }
}
