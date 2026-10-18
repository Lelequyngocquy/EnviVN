import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/location_service.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_cubit.dart';
import 'home_dashboard_state.dart';

class HomeDashboardCubit extends Cubit<HomeDashboardState> {
  final LocalStorage storage;
  final LocationService locationService;
  final WeatherCubit weatherCubit;
  final AirQualityCubit airQualityCubit;

  HomeDashboardCubit({
    required this.storage,
    required this.locationService,
    required this.weatherCubit,
    required this.airQualityCubit,
  }) : super(const HomeDashboardState());

  Future<void> initDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    // Check if city was previously saved
    final savedCity = storage.getSelectedCity();
    CityEntity targetCity = CityEntity.defaultCity;

    if (savedCity != null) {
      targetCity = CityEntity(
        name: savedCity['name']?.toString() ?? 'Hà Nội',
        province: savedCity['name']?.toString() ?? 'Hà Nội',
        latitude: double.tryParse(savedCity['lat']?.toString() ?? '') ?? 21.0285,
        longitude: double.tryParse(savedCity['lon']?.toString() ?? '') ?? 105.8542,
      );
    }

    final isGrantedInOs = await locationService.checkPermissionGranted();

    // If permission was revoked in OS settings, sync storage to false
    if (!isGrantedInOs && storage.isLocationPermissionGranted()) {
      await storage.saveLocationPermission(false);
    } else if (isGrantedInOs && !storage.isLocationPermissionGranted()) {
      await storage.saveLocationPermission(true);
    }

    // If previously saved city was a GPS location but OS permission is now revoked:
    // Reset to default city Hà Nội!
    if ((targetCity.isGps || targetCity.name.startsWith('Vị trí hiện tại')) && !isGrantedInOs) {
      targetCity = CityEntity.defaultCity;
      await storage.saveSelectedCity(targetCity.name, targetCity.latitude, targetCity.longitude);
    }

    emit(state.copyWith(
      currentCity: targetCity,
      lastUpdated: storage.getLastUpdateTime() ?? DateTime.now(),
      isLocationPermissionGranted: isGrantedInOs,
    ));

    await _fetchDataForCity(targetCity);
  }

  Future<void> changeCity(CityEntity city) async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
      isChangingLocation: true,
      currentCity: city,
      hasPendingMapSync: true,
      clearNotice: true,
    ));

    await storage.saveSelectedCity(city.name, city.latitude, city.longitude);
    await _fetchDataForCity(city);
  }

  Future<void> detectGpsLocation() async {
    final isGranted = await locationService.checkPermissionGranted();

    emit(state.copyWith(
      status: DashboardStatus.loading,
      isChangingLocation: true,
      noticeMessage: isGranted ? null : 'Quyền truy cập vị trí đang bị tắt',
      clearNotice: isGranted,
    ));

    final locationResult = await locationService.getCurrentLocation();

    // Check if permission was denied or GPS unavailable:
    // Fallback strictly to default Hà Nội, never to IP or GPS city!
    if (locationResult.isDefault || locationResult.isPermissionDenied) {
      await storage.saveLocationPermission(false);

      final defaultCity = CityEntity.defaultCity;
      await storage.saveSelectedCity(defaultCity.name, defaultCity.latitude, defaultCity.longitude);

      emit(state.copyWith(
        currentCity: defaultCity,
        isLocationPermissionGranted: false,
        hasPendingMapSync: true,
        clearNotice: true,
      ));

      await _fetchDataForCity(defaultCity);
      return;
    }

    // GPS location succeeded
    final nearestCity = _resolveNearestCityName(locationResult.latitude, locationResult.longitude);
    final displayName = nearestCity.isNotEmpty
        ? 'Vị trí hiện tại ($nearestCity)'
        : (locationResult.cityName != null && locationResult.cityName!.isNotEmpty
            ? 'Vị trí hiện tại (${locationResult.cityName})'
            : 'Vị trí hiện tại');

    final gpsCity = CityEntity(
      name: displayName,
      province: 'Định vị GPS',
      latitude: locationResult.latitude,
      longitude: locationResult.longitude,
      isGps: true,
    );

    await storage.saveLocationPermission(true);
    await storage.saveSelectedCity(gpsCity.name, gpsCity.latitude, gpsCity.longitude);

    emit(state.copyWith(
      currentCity: gpsCity,
      isLocationPermissionGranted: true,
      hasPendingMapSync: true,
      noticeMessage: null,
      clearNotice: true,
    ));

    await _fetchDataForCity(gpsCity);
  }

  String _resolveNearestCityName(double lat, double lon) {
    CityEntity? nearest;
    double minDistanceSq = double.infinity;
    for (final city in CityEntity.popularCities) {
      final dLat = lat - city.latitude;
      final dLon = lon - city.longitude;
      final dSq = dLat * dLat + dLon * dLon;
      if (dSq < minDistanceSq) {
        minDistanceSq = dSq;
        nearest = city;
      }
    }
    // If within ~50km (0.45 degree squared is ~0.20)
    if (nearest != null && minDistanceSq < 0.25) {
      return nearest.name;
    }
    return '';
  }

  void clearNotice() {
    if (state.noticeMessage != null) {
      emit(state.copyWith(clearNotice: true));
    }
  }

  Future<void> refresh() async {
    await _fetchDataForCity(state.currentCity);
  }

  Future<void> _fetchDataForCity(CityEntity city) async {
    try {
      await Future.wait([
        weatherCubit.fetchWeather(latitude: city.latitude, longitude: city.longitude),
        airQualityCubit.fetchAirQuality(latitude: city.latitude, longitude: city.longitude),
      ]);

      final aqi = airQualityCubit.state.airQuality.usAqi;
      final weather = weatherCubit.state.weather;
      final hasAlert = aqi > 100 ||
          weather.uvIndex >= 8 ||
          (weather.hourlyForecast.isNotEmpty && weather.hourlyForecast.first.precipitationProbability >= 50);

      emit(state.copyWith(
        status: DashboardStatus.success,
        isChangingLocation: false,
        lastUpdated: DateTime.now(),
        hasNotification: hasAlert,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        isChangingLocation: false,
        noticeMessage: 'Không thể tải toàn bộ dữ liệu vị trí mới: $e',
      ));
    }
  }

  void setTab(int index) {
    if (state.currentTab != index) {
      emit(state.copyWith(currentTab: index));
      if (index == 3) {
        checkLocationPermissionStatus();
      }
    }
  }

  Future<void> checkLocationPermissionStatus() async {
    final isGrantedInOs = await locationService.checkPermissionGranted();
    if (!isGrantedInOs && storage.isLocationPermissionGranted()) {
      await storage.saveLocationPermission(false);
    } else if (isGrantedInOs && !storage.isLocationPermissionGranted()) {
      await storage.saveLocationPermission(true);
    }
    if (isGrantedInOs != state.isLocationPermissionGranted) {
      emit(state.copyWith(isLocationPermissionGranted: isGrantedInOs));
    }
  }

  void markPendingMapSync() {
    if (!state.hasPendingMapSync) {
      emit(state.copyWith(hasPendingMapSync: true));
    }
  }

  void consumeMapSync() {
    if (state.hasPendingMapSync) {
      emit(state.copyWith(hasPendingMapSync: false));
    }
  }

  bool handleBackPress() {
    if (state.currentTab != 0) {
      setTab(0);
      return true;
    }
    return false;
  }

  Future<void> requestLocationPermission({void Function()? onCompleted}) async {
    await detectGpsLocation();
    if (state.isLocationPermissionGranted) {
      setTab(0);
    }
    onCompleted?.call();
  }

  void skipLocationPermission({void Function()? onCompleted}) {
    setTab(0);
    onCompleted?.call();
  }
}
