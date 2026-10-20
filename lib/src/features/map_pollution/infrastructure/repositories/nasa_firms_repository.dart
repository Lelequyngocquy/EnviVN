import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/domain/entities/base.dart';
import '../../../../core/infrastructure/configs/env_config.dart';
import '../../../../core/infrastructure/datasources/local/local_storage.dart';
import '../../domain/interfaces/i_nasa_firms_repository.dart';
import '../models/thermal_hotspot_model.dart';
import '../paths/nasa_firms_paths.dart';

class NasaFirmsRepository implements INasaFirmsRepository {
  final http.Client _client;
  final LocalStorage storage;
  final String? _apiKeyOverride;
  final String? _baseUrlOverride;

  NasaFirmsRepository({
    http.Client? client,
    required this.storage,
    String? apiKey,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _apiKeyOverride = apiKey,
        _baseUrlOverride = baseUrl;

  static const Duration cacheTtl = Duration(minutes: 15);
  static const Duration rateLimitCooldown = Duration(minutes: 10);

  DateTime? _lastRateLimitTime;
  Future<BaseResult<List<ThermalHotspotModel>>>? _activeFetchOperation;
  bool _isServingCachedData = false;

  @override
  bool get isServingCachedData => _isServingCachedData;

  @override
  DateTime? getLastUpdateTime() => storage.getThermalLastUpdateTime();

  @override
  Future<BaseResult<List<ThermalHotspotModel>>> getVietnamActiveFires({
    bool forceRefresh = false,
  }) {
    if (_activeFetchOperation != null) {
      return _activeFetchOperation!;
    }

    final future = _fetchInternal(forceRefresh: forceRefresh);
    _activeFetchOperation = future;

    return future.whenComplete(() {
      _activeFetchOperation = null;
    });
  }

  Future<BaseResult<List<ThermalHotspotModel>>> _fetchInternal({
    required bool forceRefresh,
  }) async {
    final now = DateTime.now();
    final lastUpdate = storage.getThermalLastUpdateTime();

    // 1. Kiểm tra Cache TTL (nếu chưa quá 15 phút và không ép refresh)
    if (!forceRefresh && lastUpdate != null && now.difference(lastUpdate) < cacheTtl) {
      final cachedSpots = _loadFromStorage();
      if (cachedSpots.isNotEmpty) {
        _isServingCachedData = false;
        return BaseResult(
          data: cachedSpots,
          message: 'Vệ tinh NOAA-20 (VIIRS 375m) • Cập nhật gần đây',
        );
      }
    }

    // 2. Kiểm tra Cooldown 10 phút nếu từng chạm giới hạn 5000 lượt / 10 phút
    if (_lastRateLimitTime != null &&
        now.difference(_lastRateLimitTime!) < rateLimitCooldown) {
      return _fallbackToStaleCache(
        reason: 'Đang tạm dừng đợi hạn ngạch 10 phút của NASA FIRMS',
      );
    }

    final apiKey = _apiKeyOverride ?? EnvConfig.nasaFirmsMapKey;
    final baseUrl = _baseUrlOverride ?? EnvConfig.nasaFirmsBaseUrl;

    if (apiKey.isEmpty) {
      return _fallbackToStaleCache(reason: 'Chưa cấu hình NASA FIRMS MAP_KEY');
    }

    try {
      // Thử lấy dữ liệu 1 ngày gần nhất
      final result1Day = await _requestCsv(
        baseUrl: baseUrl,
        apiKey: apiKey,
        dayRange: 1,
      );

      if (result1Day.code == '429' || result1Day.code == '403') {
        return _fallbackToStaleCache(
          reason: result1Day.message ??
              'Đã chạm giới hạn hạn ngạch NASA (5000 lượt / 10 phút)',
        );
      }

      if (result1Day.isSuccess && (result1Day.data?.isNotEmpty ?? false)) {
        await _saveToStorage(result1Day.data!);
        _isServingCachedData = false;
        return BaseResult(
          data: result1Day.data,
          message: 'Vệ tinh NOAA-20 (VIIRS 375m) • Thời gian thực',
        );
      }

      // Thử mở rộng sang 2 ngày gần nhất
      final result2Days = await _requestCsv(
        baseUrl: baseUrl,
        apiKey: apiKey,
        dayRange: 2,
      );

      if (result2Days.code == '429' || result2Days.code == '403') {
        return _fallbackToStaleCache(
          reason: result2Days.message ??
              'Đã chạm giới hạn hạn ngạch NASA (5000 lượt / 10 phút)',
        );
      }

      if (result2Days.isSuccess && (result2Days.data?.isNotEmpty ?? false)) {
        await _saveToStorage(result2Days.data!);
        _isServingCachedData = false;
        return BaseResult(
          data: result2Days.data,
          message: 'Vệ tinh NOAA-20 (VIIRS 375m) • 48h qua',
        );
      }

      return _fallbackToStaleCache(
        reason: 'Vệ tinh không ghi nhận điểm nhiệt mới trong 48h qua',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NasaFirmsRepository] Lỗi kết nối NASA: $e');
      }
      return _fallbackToStaleCache(reason: 'Không thể kết nối máy chủ NASA ($e)');
    }
  }

  Future<BaseResult<List<ThermalHotspotModel>>> _requestCsv({
    required String baseUrl,
    required String apiKey,
    required int dayRange,
  }) async {
    final url = NasaFirmsPaths.areaCsv(
      baseUrl: baseUrl,
      apiKey: apiKey,
      dayRange: dayRange,
    );

    final response = await _client.get(Uri.parse(url)).timeout(
          const Duration(seconds: 12),
        );

    // Xử lý Rate Limit (HTTP 429) hoặc Forbidden (HTTP 403)
    if (response.statusCode == 429 || response.statusCode == 403) {
      _lastRateLimitTime = DateTime.now();
      return BaseResult(
        success: false,
        code: response.statusCode.toString(),
        message:
            'Đã chạm giới hạn hạn ngạch NASA (5000 lượt / 10 phút), đang hiển thị dữ liệu lưu đệm.',
      );
    }

    if (response.statusCode != 200) {
      return BaseResult(
        success: false,
        code: response.statusCode.toString(),
        message: 'Lỗi HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final csvText = response.body.trim();
    if (csvText.startsWith('Invalid') || csvText.isEmpty) {
      return BaseResult(
        success: false,
        code: '400',
        message: csvText.isEmpty ? 'Dữ liệu CSV trống' : csvText,
      );
    }

    final hotspots = ThermalHotspotModel.fromCsv(csvText);
    return BaseResult(data: hotspots);
  }

  BaseResult<List<ThermalHotspotModel>> _fallbackToStaleCache({
    required String reason,
  }) {
    _isServingCachedData = true;
    final cached = _loadFromStorage();
    if (cached.isNotEmpty) {
      final lastUpdate = storage.getThermalLastUpdateTime();
      final timeStr = lastUpdate != null
          ? 'lúc ${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}'
          : '';
      return BaseResult(
        data: cached,
        message: 'Đang hiển thị dữ liệu vệ tinh lưu đệm $timeStr ($reason)',
      );
    }

    return BaseResult(
      data: ThermalHotspotModel.sampleHotspots,
      message: 'Đang hiển thị danh mục điểm nhiệt thực địa ($reason)',
    );
  }

  List<ThermalHotspotModel> _loadFromStorage() {
    final rawList = storage.getCachedThermalHotspots();
    if (rawList == null || rawList.isEmpty) return [];
    try {
      return rawList.map((m) => ThermalHotspotModel.fromJson(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveToStorage(List<ThermalHotspotModel> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await storage.saveCachedThermalHotspots(jsonList);
  }
}
