import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.errorMessage,
  });
}

class LocationService {
  // Default coordinates: Hà Nội, Việt Nam
  static const double defaultLat = 21.0285;
  static const double defaultLon = 105.8542;

  Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          isDefault: true,
          errorMessage: 'Dịch vụ định vị GPS đang tắt. Sử dụng vị trí mặc định (Hà Nội).',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            latitude: defaultLat,
            longitude: defaultLon,
            isDefault: true,
            errorMessage: 'Quyền định vị bị từ chối. Sử dụng vị trí mặc định (Hà Nội).',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          isDefault: true,
          errorMessage: 'Quyền định vị bị từ chối vĩnh viễn trong Cài đặt.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isDefault: false,
      );
    } catch (e) {
      debugPrint('⚠️ [LocationService] Lỗi khi lấy GPS: $e');
      return const LocationResult(
        latitude: defaultLat,
        longitude: defaultLon,
        isDefault: true,
        errorMessage: 'Không lấy được GPS. Đang dùng tọa độ mặc định.',
      );
    }
  }
}
