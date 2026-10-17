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

    emit(state.copyWith(
      status: DashboardStatus.success,
      currentCity: targetCity,
      lastUpdated: storage.getLastUpdateTime() ?? DateTime.now(),
    ));

    await _fetchDataForCity(targetCity);
  }

  Future<void> changeCity(CityEntity city) async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
      currentCity: city,
      noticeMessage: null,
    ));

    await storage.saveSelectedCity(city.name, city.latitude, city.longitude);
    await _fetchDataForCity(city);
  }

  Future<void> detectGpsLocation() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    final locationResult = await locationService.getCurrentLocation();
    final gpsCity = CityEntity(
      name: 'Vị trí hiện tại',
      province: 'Định vị GPS',
      latitude: locationResult.latitude,
      longitude: locationResult.longitude,
      isGps: true,
    );

    emit(state.copyWith(
      currentCity: gpsCity,
      noticeMessage: locationResult.errorMessage,
    ));

    await _fetchDataForCity(gpsCity);
  }

  Future<void> refresh() async {
    await _fetchDataForCity(state.currentCity);
  }

  Future<void> _fetchDataForCity(CityEntity city) async {
    await Future.wait([
      weatherCubit.fetchWeather(latitude: city.latitude, longitude: city.longitude),
      airQualityCubit.fetchAirQuality(latitude: city.latitude, longitude: city.longitude),
    ]);

    emit(state.copyWith(
      status: DashboardStatus.success,
      lastUpdated: DateTime.now(),
    ));
  }

  void setTab(int index) {
    if (state.currentTab != index) {
      emit(state.copyWith(currentTab: index));
    }
  }
}
