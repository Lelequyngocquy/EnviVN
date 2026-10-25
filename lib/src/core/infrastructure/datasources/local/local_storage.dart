import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences prefs;

  LocalStorage({required this.prefs});

  static const String _keyCachedWeather = 'cached_weather_data';
  static const String _keyCachedAQI = 'cached_aqi_data';
  static const String _keySelectedCity = 'selected_city';
  static const String _keyLastUpdate = 'last_update_timestamp';
  static const String _keyLocationPermission = 'location_permission_granted';
  static const String _keyCachedThermalHotspots = 'cached_nasa_firms_hotspots';
  static const String _keyThermalLastUpdate =
      'nasa_firms_last_update_timestamp';
  static const String _keyAiModelDownloaded = 'ai_model_is_downloaded';
  static const String _keyAiModelPath = 'ai_model_file_path';
  static const String _keyAiModelSize = 'ai_model_byte_size';
  static const String _keyAiModelDownloadedAt = 'ai_model_downloaded_at';

  static String _weatherKey(double lat, double lon) =>
      'cached_weather_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  static String _aqiKey(double lat, double lon) =>
      'cached_aqi_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  Future<void> saveCachedWeather(
    Map<String, dynamic> data, {
    double? lat,
    double? lon,
    Duration ttl = const Duration(minutes: 30),
  }) async {
    final entry = {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'ttlMillis': ttl.inMilliseconds,
      'data': data,
    };
    final encoded = jsonEncode(entry);
    await prefs.setString(_keyCachedWeather, encoded);
    if (lat != null && lon != null) {
      await prefs.setString(_weatherKey(lat, lon), encoded);
    }
    await saveLastUpdateTime();
  }

  Map<String, dynamic>? getCachedWeather({
    double? lat,
    double? lon,
    bool checkTtl = false,
  }) {
    final key = (lat != null && lon != null)
        ? _weatherKey(lat, lon)
        : _keyCachedWeather;
    final raw = prefs.getString(key) ?? prefs.getString(_keyCachedWeather);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded.containsKey('cachedAt')) {
          if (checkTtl) {
            final cachedAt = decoded['cachedAt'] as int? ?? 0;
            final ttlMillis = decoded['ttlMillis'] as int? ?? (30 * 60 * 1000);
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - cachedAt > ttlMillis) {
              return null;
            }
          }
          return decoded['data'] as Map<String, dynamic>?;
        }
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool isWeatherCacheValid({required double lat, required double lon}) {
    return getCachedWeather(lat: lat, lon: lon, checkTtl: true) != null;
  }

  Future<void> saveCachedAirQuality(
    Map<String, dynamic> data, {
    double? lat,
    double? lon,
    Duration ttl = const Duration(minutes: 30),
  }) async {
    final entry = {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'ttlMillis': ttl.inMilliseconds,
      'data': data,
    };
    final encoded = jsonEncode(entry);
    await prefs.setString(_keyCachedAQI, encoded);
    if (lat != null && lon != null) {
      await prefs.setString(_aqiKey(lat, lon), encoded);
    }
    await saveLastUpdateTime();
  }

  Map<String, dynamic>? getCachedAirQuality({
    double? lat,
    double? lon,
    bool checkTtl = false,
  }) {
    final key = (lat != null && lon != null)
        ? _aqiKey(lat, lon)
        : _keyCachedAQI;
    final raw = prefs.getString(key) ?? prefs.getString(_keyCachedAQI);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded.containsKey('cachedAt')) {
          if (checkTtl) {
            final cachedAt = decoded['cachedAt'] as int? ?? 0;
            final ttlMillis = decoded['ttlMillis'] as int? ?? (30 * 60 * 1000);
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - cachedAt > ttlMillis) {
              return null;
            }
          }
          return decoded['data'] as Map<String, dynamic>?;
        }
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool isAirQualityCacheValid({required double lat, required double lon}) {
    return getCachedAirQuality(lat: lat, lon: lon, checkTtl: true) != null;
  }

  Future<void> saveSelectedCity(String cityName, double lat, double lon) async {
    await prefs.setString(
      _keySelectedCity,
      jsonEncode({'name': cityName, 'lat': lat, 'lon': lon}),
    );
  }

  Map<String, dynamic>? getSelectedCity() {
    final raw = prefs.getString(_keySelectedCity);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastUpdateTime() async {
    await prefs.setInt(_keyLastUpdate, DateTime.now().millisecondsSinceEpoch);
  }

  DateTime? getLastUpdateTime() {
    final millis = prefs.getInt(_keyLastUpdate);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> saveLocationPermission(bool isGranted) async {
    await prefs.setBool(_keyLocationPermission, isGranted);
  }

  bool isLocationPermissionGranted() {
    return prefs.getBool(_keyLocationPermission) ?? false;
  }

  Future<void> saveCachedThermalHotspots(
    List<Map<String, dynamic>> spots,
  ) async {
    await prefs.setString(_keyCachedThermalHotspots, jsonEncode(spots));
    await prefs.setInt(
      _keyThermalLastUpdate,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<Map<String, dynamic>>? getCachedThermalHotspots() {
    final raw = prefs.getString(_keyCachedThermalHotspots);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return null;
    }
  }

  DateTime? getThermalLastUpdateTime() {
    final millis = prefs.getInt(_keyThermalLastUpdate);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> saveAiModelInfo({
    required String path,
    required int sizeBytes,
  }) async {
    await prefs.setBool(_keyAiModelDownloaded, true);
    await prefs.setString(_keyAiModelPath, path);
    await prefs.setInt(_keyAiModelSize, sizeBytes);
    await prefs.setInt(
      _keyAiModelDownloadedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool isAiModelDownloaded() {
    return prefs.getBool(_keyAiModelDownloaded) ?? false;
  }

  String? getAiModelPath() {
    return prefs.getString(_keyAiModelPath);
  }

  int? getAiModelSize() {
    return prefs.getInt(_keyAiModelSize);
  }

  DateTime? getAiModelDownloadedAt() {
    final millis = prefs.getInt(_keyAiModelDownloadedAt);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> clearAiModelInfo() async {
    await prefs.remove(_keyAiModelDownloaded);
    await prefs.remove(_keyAiModelPath);
    await prefs.remove(_keyAiModelSize);
    await prefs.remove(_keyAiModelDownloadedAt);
  }

  Future<void> clearAll() async {
    await prefs.clear();
  }
}
