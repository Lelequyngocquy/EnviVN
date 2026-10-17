import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/base.dart';
import '../../../../core/infrastructure/datasources/local/local_storage.dart';
import '../../../../core/infrastructure/datasources/network/api/configs/endpoint.dart';
import '../../../../core/infrastructure/datasources/network/api/restful_request.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/interfaces/i_weather_repository.dart';
import '../models/weather_model.dart';
import '../paths/weather_paths.dart';

class WeatherRepository implements IWeatherRepository {
  final RestfulRequest network;
  final LocalStorage storage;

  WeatherRepository({
    required this.network,
    required this.storage,
  });

  @override
  Future<BaseResult<WeatherEntity>> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final endpoint = EndpointType(
        path: WeatherPaths.forecast,
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
        final weather = WeatherModel.fromJson(dataMap);

        // Cache into local storage for offline-first resilience
        await storage.saveCachedWeather(dataMap);

        return BaseResult(success: true, data: weather);
      }

      // If network response was not successful, fallback to offline cache
      final cached = getCachedWeather();
      if (cached != null) {
        return BaseResult(
          success: true,
          message: 'Đang hiển thị dữ liệu đã lưu ngoại tuyến',
          data: cached,
        );
      }

      return BaseResult(
        success: false,
        message: response.message ?? 'Không thể tải dự báo thời tiết',
        data: const WeatherEntity(),
      );
    } catch (e) {
      debugPrint('❌ [WeatherRepository] Lỗi: $e');
      final cached = getCachedWeather();
      if (cached != null) {
        return BaseResult(
          success: true,
          message: 'Đang hiển thị dữ liệu lưu trong bộ nhớ máy',
          data: cached,
        );
      }

      return BaseResult(
        success: false,
        message: 'Lỗi tải thời tiết: $e',
        data: const WeatherEntity(),
      );
    }
  }

  @override
  WeatherEntity? getCachedWeather() {
    final cachedJson = storage.getCachedWeather();
    if (cachedJson != null) {
      return WeatherModel.fromJson(cachedJson, isOfflineCache: true);
    }
    return null;
  }
}
