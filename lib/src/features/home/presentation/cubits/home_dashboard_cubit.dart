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

    final isGrantedInStorage = storage.isLocationPermissionGranted();
    final isGrantedInOs = await locationService.checkPermissionGranted();
    final isGranted = isGrantedInStorage || isGrantedInOs;
    if (isGranted && !isGrantedInStorage) {
      await storage.saveLocationPermission(true);
    }

    emit(state.copyWith(
      currentCity: targetCity,
      lastUpdated: storage.getLastUpdateTime() ?? DateTime.now(),
      isLocationPermissionGranted: isGranted,
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
    emit(state.copyWith(
      status: DashboardStatus.loading,
      isChangingLocation: true,
      clearNotice: true,
    ));

    final locationResult = await locationService.getCurrentLocation();
    final displayName = locationResult.cityName != null && locationResult.cityName!.isNotEmpty
        ? 'Vị trí hiện tại (${locationResult.cityName})'
        : 'Vị trí hiện tại';

    final gpsCity = CityEntity(
      name: displayName,
      province: locationResult.isDefault ? 'Mặc định' : 'Định vị GPS',
      latitude: locationResult.latitude,
      longitude: locationResult.longitude,
      isGps: !locationResult.isDefault,
    );

    final isGpsSuccessful = !locationResult.isDefault;
    if (isGpsSuccessful) {
      await storage.saveLocationPermission(true);
    }

    emit(state.copyWith(
      currentCity: gpsCity,
      isLocationPermissionGranted:
          isGpsSuccessful || storage.isLocationPermissionGranted(),
      hasPendingMapSync: true,
      noticeMessage: locationResult.errorMessage,
      clearNotice: locationResult.errorMessage == null,
    ));

    await _fetchDataForCity(gpsCity);
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
    final isGrantedInStorage = storage.isLocationPermissionGranted();
    final isGrantedInOs = await locationService.checkPermissionGranted();
    final isGranted = isGrantedInStorage || isGrantedInOs;
    if (isGranted != state.isLocationPermissionGranted) {
      if (isGranted && !isGrantedInStorage) {
        await storage.saveLocationPermission(true);
      }
      emit(state.copyWith(isLocationPermissionGranted: isGranted));
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
    await storage.saveLocationPermission(true);
    emit(state.copyWith(isLocationPermissionGranted: true));
    setTab(0);
    onCompleted?.call();
  }

  void skipLocationPermission({void Function()? onCompleted}) {
    setTab(0);
    onCompleted?.call();
  }
}
