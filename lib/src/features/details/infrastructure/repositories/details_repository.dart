import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/base.dart';
import '../../../../core/infrastructure/datasources/local/local_storage.dart';
import '../../../../core/infrastructure/datasources/network/api/configs/endpoint.dart';
import '../../../../core/infrastructure/datasources/network/api/restful_request.dart';
import '../../domain/entities/details_entity.dart';
import '../../domain/interfaces/i_details_repository.dart';
import '../models/details_model.dart';
import '../paths/details_paths.dart';

class DetailsRepository implements IDetailsRepository {
  final RestfulRequest network;
  final LocalStorage storage;

  DetailsRepository({
    required this.network,
    required this.storage,
  });

  @override
  Future<BaseResult<DetailsEntity>> getDetailsForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final endpoint = EndpointType(
        path: DetailsPaths.forecast,
        method: HttpMethod.get,
        params: {
          'latitude': latitude,
          'longitude': longitude,
          'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,surface_pressure,uv_index',
          'hourly': 'temperature_2m,relative_humidity_2m,weather_code,precipitation_probability,uv_index',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum',
          'timezone': 'auto',
        },
      );

      final response = await network.requestData(endpoint, showErrorToast: false);

      if (response.isSuccess && response.data is Map) {
        final dataMap = Map<String, dynamic>.from(response.data as Map);
        final details = DetailsModel.fromJson(dataMap);

        await storage.saveCachedWeather(dataMap);

        return BaseResult(success: true, data: details);
      }

      final cached = getCachedDetails();
      if (cached != null) {
        return BaseResult(
          success: true,
          message: 'Đang hiển thị dữ liệu đã lưu ngoại tuyến',
          data: cached,
        );
      }

      return BaseResult(
        success: false,
        message: response.message ?? 'Không thể tải dự báo thời tiết chi tiết',
        data: const DetailsEntity(),
      );
    } catch (e) {
      debugPrint('❌ [DetailsRepository] Lỗi: $e');
      final cached = getCachedDetails();
      if (cached != null) {
        return BaseResult(
          success: true,
          message: 'Đang hiển thị dữ liệu lưu trong bộ nhớ máy',
          data: cached,
        );
      }

      return BaseResult(
        success: false,
        message: 'Lỗi tải dữ liệu chi tiết: $e',
        data: const DetailsEntity(),
      );
    }
  }

  @override
  DetailsEntity? getCachedDetails() {
    final cachedJson = storage.getCachedWeather();
    if (cachedJson != null) {
      return DetailsModel.fromJson(cachedJson, isOfflineCache: true);
    }
    return null;
  }

  // Aliases for compatibility
  @override
  Future<BaseResult<DetailsEntity>> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) => getDetailsForecast(latitude: latitude, longitude: longitude);

  @override
  DetailsEntity? getCachedWeather() => getCachedDetails();
}

// Backward-compatibility alias
typedef WeatherRepository = DetailsRepository;
