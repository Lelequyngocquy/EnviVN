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
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.isDefault = false,
    this.errorMessage,
  });
}

class LocationService {
  // Default coordinates: Hà Nội, Việt Nam
  static const double defaultLat = 21.0285;
  static const double defaultLon = 105.8542;

  Future<LocationResult> getCurrentLocation() async {
    // 1. Try Hardware GPS / OS Location
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
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
            );
          }

          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          );

          return LocationResult(
            latitude: position.latitude,
            longitude: position.longitude,
            isDefault: false,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ [LocationService] GPS không khả dụng hoặc timeout: $e. Thử định vị qua IP...');
    }

    // 2. Fallback: Network IP Geolocation (instant & reliable on desktop/emulators)
    final ipResult = await _getLocationByIp();
    if (ipResult != null) {
      debugPrint('📍 [LocationService] Định vị thành công qua IP: ${ipResult.latitude}, ${ipResult.longitude} (${ipResult.cityName})');
      return ipResult;
    }

    // 3. Fallback: Default City (Hà Nội)
    debugPrint('⚠️ [LocationService] Không lấy được GPS hoặc IP, dùng mặc định Hà Nội.');
    return const LocationResult(
      latitude: defaultLat,
      longitude: defaultLon,
      cityName: 'Hà Nội',
      isDefault: true,
      errorMessage: 'Không thể định vị GPS. Sử dụng vị trí mặc định (Hà Nội).',
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
