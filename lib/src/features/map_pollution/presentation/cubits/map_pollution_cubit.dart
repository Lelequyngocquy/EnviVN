import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/infrastructure/services/location_service.dart';
import '../../../weather/domain/interfaces/i_weather_repository.dart';
import '../../domain/entities/quick_city_target.dart';
import '../../domain/entities/station_pollution_entity.dart';
import '../../domain/interfaces/i_map_pollution_repository.dart';
import 'map_pollution_state.dart';

class MapPollutionCubit extends Cubit<MapPollutionState> {
  final IMapPollutionRepository repository;
  final IWeatherRepository? weatherRepository;
  final LocationService? locationService;

  MapPollutionCubit({
    required this.repository,
    this.weatherRepository,
    this.locationService,
  }) : super(const MapPollutionState());

  Future<void> fetchVietnamStations({
    String? initialCity,
    LatLng? initialCoords,
  }) async {
    emit(state.copyWith(status: MapPollutionStatus.loading, errorMessage: null));

    final result = await repository.getVietnamStations();

    if (result.isSuccess && result.data != null) {
      final stations = result.data!;
      emit(state.copyWith(
        status: MapPollutionStatus.success,
        stations: stations,
      ));

      await loadUserGpsLocation();

      if (initialCoords != null) {
        selectLocationCoordinates(
          initialCoords.latitude,
          initialCoords.longitude,
          label: initialCity,
        );
      } else if (initialCity != null && initialCity.isNotEmpty) {
        selectLocationByCityName(initialCity);
      }
    } else {
      emit(state.copyWith(
        status: MapPollutionStatus.failure,
        errorMessage: result.message ?? 'Không thể tải trạm quan trắc trên bản đồ',
      ));
    }
  }

  void setUserGpsLocation(LatLng? coords) {
    if (coords == null) {
      clearUserGpsLocation();
    } else if (state.userGpsLocation != coords) {
      emit(state.copyWith(userGpsLocation: coords));
    }
  }

  void clearUserGpsLocation() {
    if (state.userGpsLocation != null) {
      emit(state.copyWith(clearUserGpsLocation: true));
    }
  }

  Future<void> loadUserGpsLocation({LatLng? fallbackCoords}) async {
    if (locationService == null) {
      emit(state.copyWith(clearUserGpsLocation: true));
      return;
    }
    try {
      final isGranted = await locationService!.checkPermissionGranted();
      if (!isGranted) {
        emit(state.copyWith(clearUserGpsLocation: true));
        return;
      }
      if (fallbackCoords != null && state.userGpsLocation == null) {
        emit(state.copyWith(userGpsLocation: fallbackCoords));
      }
      final loc = await locationService!.getCurrentLocation();
      if (!loc.isDefault && !loc.isPermissionDenied) {
        emit(state.copyWith(userGpsLocation: LatLng(loc.latitude, loc.longitude)));
      } else {
        emit(state.copyWith(clearUserGpsLocation: true));
      }
    } catch (_) {
      emit(state.copyWith(clearUserGpsLocation: true));
    }
  }

  void selectStation(StationPollutionEntity station) {
    emit(state.copyWith(
      selectedStation: station,
      targetLocation: LatLng(station.latitude, station.longitude),
      targetZoom: 12.0,
      selectedCityName: station.province,
      isHomeSelected: false,
    ));

    _enrichStationWeather(station);
  }

  Future<void> _enrichStationWeather(StationPollutionEntity station) async {
    if (weatherRepository == null) return;
    try {
      final res = await weatherRepository!.getWeatherForecast(
        latitude: station.latitude,
        longitude: station.longitude,
      );
      if (res.isSuccess && res.data != null && state.selectedStation?.id == station.id) {
        final weather = res.data!;
        final updatedStation = station.copyWith(
          temperature: weather.currentTemp,
          weatherCode: weather.weatherCode,
          humidity: weather.relativeHumidity,
          windSpeed: weather.windSpeed,
        );
        emit(state.copyWith(selectedStation: updatedStation));
      }
    } catch (_) {}
  }

  void selectLocationByCityName(String cityName) {
    final normQuery = _normalize(cityName);
    // 1. Try to find an exact or substring match in stations
    StationPollutionEntity? matchedStation;
    for (final st in state.stations) {
      final normProvince = _normalize(st.province);
      final normName = _normalize(st.name);
      if (normProvince.contains(normQuery) ||
          normQuery.contains(normProvince) ||
          normName.contains(normQuery) ||
          normQuery.contains(normName)) {
        matchedStation = st;
        break;
      }
    }

    if (matchedStation != null) {
      selectStation(matchedStation);
      return;
    }

    // Standard fallback Vietnam cities coordinates if no direct station matched
    final cityCoords = _getCityCoordinates(cityName);
    if (cityCoords != null) {
      selectLocationCoordinates(
        cityCoords.latitude,
        cityCoords.longitude,
        zoom: 11.5,
        label: cityName,
      );
    }
  }

  void selectHomeLocation({
    required double lat,
    required double lon,
    double zoom = 12.0,
    String? label,
  }) {
    // Check if there is a station close to this coordinate (within ~35km)
    StationPollutionEntity? closestStation;
    double minDistance = double.infinity;

    for (final st in state.stations) {
      final d = _calculateDistance(lat, lon, st.latitude, st.longitude);
      if (d < minDistance) {
        minDistance = d;
        closestStation = st;
      }
    }

    if (closestStation != null && minDistance <= 35.0) {
      emit(state.copyWith(
        selectedStation: closestStation,
        targetLocation: LatLng(closestStation.latitude, closestStation.longitude),
        targetZoom: zoom,
        selectedCityName: label ?? closestStation.province,
        isHomeSelected: true,
      ));
      _enrichStationWeather(closestStation);
    } else {
      emit(state.copyWith(
        clearSelectedStation: true,
        targetLocation: LatLng(lat, lon),
        targetZoom: zoom,
        selectedCityName: label ?? 'Vị trí hiện tại',
        isHomeSelected: true,
      ));
    }
  }

  void selectLocationCoordinates(
    double lat,
    double lon, {
    double zoom = 12.0,
    String? label,
    bool isHome = false,
  }) {
    if (isHome) {
      selectHomeLocation(lat: lat, lon: lon, zoom: zoom, label: label);
      return;
    }

    // Check if there is a station close to this coordinate (within ~35km)
    StationPollutionEntity? closestStation;
    double minDistance = double.infinity;

    for (final st in state.stations) {
      final d = _calculateDistance(lat, lon, st.latitude, st.longitude);
      if (d < minDistance) {
        minDistance = d;
        closestStation = st;
      }
    }

    if (closestStation != null && minDistance <= 35.0) {
      selectStation(closestStation);
    } else {
      emit(state.copyWith(
        clearSelectedStation: true,
        targetLocation: LatLng(lat, lon),
        targetZoom: zoom,
        selectedCityName: label,
        isHomeSelected: false,
      ));
    }
  }

  void selectQuickCity(QuickCityTarget target) {
    if (target.isAllCountry) {
      showAllVietnam();
    } else {
      emit(state.copyWith(isHomeSelected: false));
      selectLocationCoordinates(
        target.latitude,
        target.longitude,
        zoom: target.zoom,
        label: target.label,
        isHome: false,
      );
    }
  }

  void updateQuickCities(List<QuickCityTarget> cities) {
    emit(state.copyWith(quickCities: cities));
  }

  void showAllVietnam() {
    emit(state.copyWith(
      clearSelectedStation: true,
      targetLocation: const LatLng(16.0544, 108.2022),
      targetZoom: 5.8,
      selectedCityName: 'Toàn quốc',
      isHomeSelected: false,
    ));
  }

  void clearSelection() {
    emit(state.copyWith(
      clearSelectedStation: true,
      clearTargetLocation: true,
      clearSelectedCityName: true,
      isHomeSelected: false,
    ));
  }

  void setFilter(String filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void toggleHeatmap() {
    emit(state.copyWith(showHeatmap: !state.showHeatmap));
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('tp.', '')
        .replaceAll('thành phố', '')
        .replaceAll('tỉnh', '')
        .trim();
  }

  LatLng? _getCityCoordinates(String cityName) {
    final norm = _normalize(cityName);
    for (final target in state.quickCities) {
      if (!target.isAllCountry && target.isSelected(norm)) {
        return LatLng(target.latitude, target.longitude);
      }
    }
    if (norm.contains('hà nội')) return const LatLng(21.0285, 105.8542);
    if (norm.contains('hồ chí minh') || norm.contains('sài gòn') || norm.contains('hcm')) {
      return const LatLng(10.7769, 106.7009);
    }
    if (norm.contains('đà nẵng')) return const LatLng(16.0544, 108.2022);
    if (norm.contains('hải phòng')) return const LatLng(20.8449, 106.6881);
    if (norm.contains('cần thơ')) return const LatLng(10.0452, 105.7469);
    if (norm.contains('huế')) return const LatLng(16.4637, 107.5909);
    if (norm.contains('nha trang')) return const LatLng(12.2388, 109.1967);
    if (norm.contains('đà lạt')) return const LatLng(11.9404, 108.4583);
    if (norm.contains('quảng ninh') || norm.contains('hạ long')) return const LatLng(20.9505, 107.0734);
    if (norm.contains('vũng tàu')) return const LatLng(10.3460, 107.0843);
    return null;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }
}

