import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../configs/env_config.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? cityName;
  final bool isDefault;
  final bool isPermissionDenied;
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.isDefault = false,
    this.isPermissionDenied = false,
    this.errorMessage,
  });
}

class LocationService {
  // Default coordinates: Hà Nội, Việt Nam
  static const double defaultLat = 21.0285;
  static const double defaultLon = 105.8542;

  Future<bool> checkPermissionGranted() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<LocationResult> getCurrentLocation({bool allowIpFallback = false}) async {
    // 1. Try Hardware GPS / OS Location
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // If user explicitly denied permission or denied forever:
      // Strictly return default city (Hà Nội) and NEVER fallback to IP Geolocation!
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          cityName: 'Hà Nội',
          isDefault: true,
          isPermissionDenied: true,
          errorMessage: permission == LocationPermission.deniedForever
              ? 'Quyền truy cập vị trí bị chặn. Vui lòng cấp quyền trong Cài đặt thiết bị.'
              : 'Quyền truy cập vị trí bị từ chối. Sử dụng vị trí mặc định (Hà Nội).',
        );
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          cityName: 'Hà Nội',
          isDefault: true,
          isPermissionDenied: true,
          errorMessage: 'Dịch vụ định vị GPS trên thiết bị đang tắt. Sử dụng vị trí mặc định (Hà Nội).',
        );
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Quick attempt with last known position
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return LocationResult(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            isDefault: false,
            isPermissionDenied: false,
          );
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );

        return LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          isDefault: false,
          isPermissionDenied: false,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [LocationService] Lỗi định vị GPS hoặc timeout: $e');
    }

    // 2. IP Geolocation is ONLY used if explicitly allowed (e.g. desktop/emulator testing without GPS)
    // NEVER when the user explicitly denied GPS permissions on a phone!
    if (allowIpFallback) {
      final ipResult = await _getLocationByIp();
      if (ipResult != null) {
        debugPrint('📍 [LocationService] Định vị qua IP: ${ipResult.latitude}, ${ipResult.longitude} (${ipResult.cityName})');
        return ipResult;
      }
    }

    // 3. Fallback: Default City (Hà Nội)
    debugPrint('⚠️ [LocationService] Định vị GPS không thành công, sử dụng vị trí mặc định Hà Nội.');
    return const LocationResult(
      latitude: defaultLat,
      longitude: defaultLon,
      cityName: 'Hà Nội',
      isDefault: true,
      isPermissionDenied: true,
      errorMessage: 'Không thể nhận diện vị trí GPS. Sử dụng vị trí mặc định (Hà Nội).',
    );
  }

  Future<LocationResult?> _getLocationByIp() async {
    try {
      final response = await http
          .get(Uri.parse(EnvConfig.ipApiBaseUrl))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          final lat = (data['lat'] as num?)?.toDouble();
          final lon = (data['lon'] as num?)?.toDouble();
          final city = data['city']?.toString() ?? data['regionName']?.toString();
          if (lat != null && lon != null) {
            return LocationResult(
              latitude: lat,
              longitude: lon,
              cityName: city,
              isDefault: false,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [LocationService] Lỗi khi lấy vị trí qua IP: $e');
    }
    return null;
  }
}
