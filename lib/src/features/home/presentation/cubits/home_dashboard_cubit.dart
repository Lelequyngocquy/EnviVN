import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/location_service.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_cubit.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'home_dashboard_state.dart';

class HomeDashboardCubit extends Cubit<HomeDashboardState> {
  final LocalStorage storage;
  final LocationService locationService;
  final DetailsCubit detailsCubit;
  final AirQualityCubit airQualityCubit;

  HomeDashboardCubit({
    required this.storage,
    required this.locationService,
    required this.detailsCubit,
    required this.airQualityCubit,
  }) : super(const HomeDashboardState());

  DetailsCubit get weatherCubit => detailsCubit;

  Future<void> initDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    final savedCity = storage.getSelectedCity();
    CityEntity targetCity = CityEntity.defaultCity;

    if (savedCity != null) {
      final rawName =
          savedCity['name']?.toString() ?? CityEntity.defaultCity.name;
      final normalizedName = rawName.startsWith('Vị trí hiện tại')
          ? 'Vị trí hiện tại'
          : rawName;
      final isGpsCity = normalizedName == 'Vị trí hiện tại';

      targetCity = CityEntity(
        name: normalizedName,
        province: isGpsCity
            ? 'Định vị GPS'
            : (savedCity['province']?.toString() ??
                  (savedCity['name']?.toString() ??
                      CityEntity.defaultCity.province)),
        latitude:
            double.tryParse(savedCity['lat']?.toString() ?? '') ??
            CityEntity.defaultCity.latitude,
        longitude:
            double.tryParse(savedCity['lon']?.toString() ?? '') ??
            CityEntity.defaultCity.longitude,
        isGps: isGpsCity,
      );
    }

    final isGrantedInOs = await locationService.checkPermissionGranted();

    if (!isGrantedInOs && storage.isLocationPermissionGranted()) {
      await storage.saveLocationPermission(false);
    } else if (isGrantedInOs && !storage.isLocationPermissionGranted()) {
      await storage.saveLocationPermission(true);
    }

    if ((targetCity.isGps || targetCity.name.startsWith('Vị trí hiện tại')) &&
        !isGrantedInOs) {
      targetCity = CityEntity.defaultCity;
      await storage.saveSelectedCity(
        targetCity.name,
        targetCity.latitude,
        targetCity.longitude,
      );
    }

    emit(
      state.copyWith(
        currentCity: targetCity,
        lastUpdated: storage.getLastUpdateTime() ?? DateTime.now(),
        isLocationPermissionGranted: isGrantedInOs,
      ),
    );

    await _fetchDataForCity(targetCity);
  }

  Future<void> changeCity(CityEntity city) async {
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        isChangingLocation: true,
        currentCity: city,
        hasPendingMapSync: true,
        clearNotice: true,
      ),
    );

    await storage.saveSelectedCity(city.name, city.latitude, city.longitude);
    await _fetchDataForCity(city);
  }

  Future<void> detectGpsLocation() async {
    final isGranted = await locationService.checkPermissionGranted();

    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        isChangingLocation: true,
        noticeMessage: isGranted ? null : 'Quyền truy cập vị trí đang bị tắt',
        clearNotice: isGranted,
      ),
    );

    final locationResult = await locationService.getCurrentLocation();

    if (locationResult.isDefault || locationResult.isPermissionDenied) {
      await storage.saveLocationPermission(false);

      final defaultCity = CityEntity.defaultCity;
      await storage.saveSelectedCity(
        defaultCity.name,
        defaultCity.latitude,
        defaultCity.longitude,
      );

      emit(
        state.copyWith(
          currentCity: defaultCity,
          isLocationPermissionGranted: false,
          hasPendingMapSync: true,
          clearNotice: true,
        ),
      );

      await _fetchDataForCity(defaultCity);
      return;
    }

    const displayName = 'Vị trí hiện tại';

    final gpsCity = CityEntity(
      name: displayName,
      province: 'Định vị GPS',
      latitude: locationResult.latitude,
      longitude: locationResult.longitude,
      isGps: true,
    );

    await storage.saveLocationPermission(true);
    await storage.saveSelectedCity(
      gpsCity.name,
      gpsCity.latitude,
      gpsCity.longitude,
    );

    emit(
      state.copyWith(
        currentCity: gpsCity,
        isLocationPermissionGranted: true,
        hasPendingMapSync: true,
        noticeMessage: null,
        clearNotice: true,
      ),
    );

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
        detailsCubit.fetchDetails(
          latitude: city.latitude,
          longitude: city.longitude,
        ),
        airQualityCubit.fetchAirQuality(
          latitude: city.latitude,
          longitude: city.longitude,
        ),
      ]);

      final aqi = airQualityCubit.state.airQuality.usAqi;
      final details = detailsCubit.state.details;
      final hasAlert =
          aqi > 100 ||
          details.uvIndex >= 8 ||
          (details.hourlyForecast.isNotEmpty &&
              details.hourlyForecast.first.precipitationProbability >= 50);

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          isChangingLocation: false,
          lastUpdated: DateTime.now(),
          hasNotification: hasAlert,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          isChangingLocation: false,
          noticeMessage: 'Không thể tải toàn bộ dữ liệu vị trí mới: $e',
        ),
      );
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
      onCompleted?.call();
    }
  }

  Future<void> skipLocationPermission({void Function()? onCompleted}) async {
    final defaultCity = CityEntity.defaultCity;
    await storage.saveLocationPermission(false);
    await storage.saveSelectedCity(
      defaultCity.name,
      defaultCity.latitude,
      defaultCity.longitude,
    );
    if (state.currentCity != defaultCity) {
      await changeCity(defaultCity);
    }
    setTab(0);
    onCompleted?.call();
  }
}
