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

  Future<void> saveCachedWeather(Map<String, dynamic> data) async {
    await prefs.setString(_keyCachedWeather, jsonEncode(data));
    await saveLastUpdateTime();
  }

  Map<String, dynamic>? getCachedWeather() {
    final raw = prefs.getString(_keyCachedWeather);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedAirQuality(Map<String, dynamic> data) async {
    await prefs.setString(_keyCachedAQI, jsonEncode(data));
    await saveLastUpdateTime();
  }

  Map<String, dynamic>? getCachedAirQuality() {
    final raw = prefs.getString(_keyCachedAQI);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSelectedCity(String cityName, double lat, double lon) async {
    await prefs.setString(_keySelectedCity, jsonEncode({
      'name': cityName,
      'lat': lat,
      'lon': lon,
    }));
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

  Future<void> clearAll() async {
    await prefs.clear();
  }
}
