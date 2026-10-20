import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../common/utils/geo_distance_helper.dart';
import '../../../../core/infrastructure/services/location_service.dart';
import '../../../air_quality/domain/entities/air_quality_entity.dart';
import '../../../air_quality/domain/interfaces/i_air_quality_repository.dart';
import '../../../home/domain/entities/city_entity.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../../../weather/domain/interfaces/i_weather_repository.dart';
import '../../domain/entities/map_layer_type.dart';
import '../../domain/entities/quick_city_target.dart';
import '../../domain/entities/station_pollution_entity.dart';
import '../../domain/entities/vietnam_province.dart';
import '../../domain/interfaces/i_map_pollution_repository.dart';
import '../../domain/interfaces/i_nasa_firms_repository.dart';
import 'map_pollution_state.dart';

class MapPollutionCubit extends Cubit<MapPollutionState> {
  final IMapPollutionRepository repository;
  final IWeatherRepository? weatherRepository;
  final IAirQualityRepository? airQualityRepository;
  final LocationService? locationService;
  final INasaFirmsRepository? nasaFirmsRepository;

  MapPollutionCubit({
    required this.repository,
    this.weatherRepository,
    this.airQualityRepository,
    this.locationService,
    this.nasaFirmsRepository,
  }) : super(const MapPollutionState());

  Future<void> fetchVietnamStations({
    String? initialCity,
    LatLng? initialCoords,
  }) async {
    emit(
      state.copyWith(status: MapPollutionStatus.loading, errorMessage: null),
    );

    final result = await repository.getVietnamStations();

    if (result.isSuccess && result.data != null) {
      final stations = result.data!;
      emit(
        state.copyWith(status: MapPollutionStatus.success, stations: stations),
      );

      await loadUserGpsLocation();

      // Nếu state đã có sẵn trạm hoặc vị trí mục tiêu được chọn từ trước, giữ nguyên không ghi đè
      if (state.selectedStation != null || state.targetLocation != null) {
        return;
      }

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
      emit(
        state.copyWith(
          status: MapPollutionStatus.failure,
          errorMessage:
              result.message ?? 'Không thể tải trạm quan trắc trên bản đồ',
        ),
      );
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
        emit(
          state.copyWith(userGpsLocation: LatLng(loc.latitude, loc.longitude)),
        );
      } else {
        emit(state.copyWith(clearUserGpsLocation: true));
      }
    } catch (_) {
      emit(state.copyWith(clearUserGpsLocation: true));
    }
  }

  QuickCityTarget? _matchQuickCity(String cityName) {
    return QuickCityTarget.findByQuery(cityName);
  }

  QuickCityTarget? _findQuickCityForStation(StationPollutionEntity station) {
    return QuickCityTarget.findForStation(
      name: station.name,
      province: station.province,
      lat: station.latitude,
      lon: station.longitude,
    );
  }

  ({StationPollutionEntity? station, double distanceKm}) _findClosestStation(
    double lat,
    double lon,
  ) {
    StationPollutionEntity? closestStation;
    double minDistance = double.infinity;
    for (final st in state.stations) {
      final d = GeoDistanceHelper.distanceInKm(lat, lon, st.latitude, st.longitude);
      if (d < minDistance) {
        minDistance = d;
        closestStation = st;
      }
    }
    return (station: closestStation, distanceKm: minDistance);
  }

  void selectStation(
    StationPollutionEntity station, {
    QuickCityTarget? quickCity,
  }) {
    final matchedQuickCity = quickCity ?? _findQuickCityForStation(station);
    final bool needsWeather = station.temperature == null;
    emit(
      state.copyWith(
        selectedStation: station,
        targetLocation: LatLng(station.latitude, station.longitude),
        targetZoom: 12.0,
        selectedCityName: matchedQuickCity?.label ?? station.province,
        selectedQuickCity: matchedQuickCity,
        clearSelectedQuickCity: matchedQuickCity == null,
        isHomeSelected: false,
        clearPickedLocation: true,
        isLoadingPointData: needsWeather,
        isShowedAllVN: false,
      ),
    );

    if (needsWeather) {
      _enrichStationWeather(station);
    }
  }

  void switchMapLayer(MapLayerType layer) {
    if (state.activeLayer != layer) {
      emit(state.copyWith(activeLayer: layer));
      if (layer == MapLayerType.thermal) {
        fetchThermalHotspots();
      }
    }
  }

  Future<void> fetchThermalHotspots({bool forceRefresh = false}) async {
    if (nasaFirmsRepository == null) return;
    emit(state.copyWith(isLoadingThermal: true));
    try {
      final result = await nasaFirmsRepository!.getVietnamActiveFires(
        forceRefresh: forceRefresh,
      );
      if (result.isSuccess && result.data != null) {
        emit(
          state.copyWith(
            thermalHotspots: result.data!,
            isLoadingThermal: false,
            thermalNotice: result.message,
            isThermalFromCache: nasaFirmsRepository!.isServingCachedData,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoadingThermal: false,
            thermalNotice: result.message,
            isThermalFromCache: true,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(isLoadingThermal: false, isThermalFromCache: true));
    }
  }

  Future<void> _enrichStationWeather(StationPollutionEntity station) async {
    if (weatherRepository == null) {
      if (state.isLoadingPointData) {
        emit(state.copyWith(isLoadingPointData: false));
      }
      return;
    }
    try {
      final res = await weatherRepository!.getWeatherForecast(
        latitude: station.latitude,
        longitude: station.longitude,
      );
      if (res.isSuccess &&
          res.data != null &&
          state.selectedStation?.id == station.id) {
        final weather = res.data!;
        final updatedStation = station.copyWith(
          temperature: weather.currentTemp,
          apparentTemp: weather.apparentTemp,
          weatherCode: weather.weatherCode,
          humidity: weather.relativeHumidity,
          windSpeed: weather.windSpeed,
          precipitation: weather.precipitation,
          uvIndex: weather.uvIndex,
        );
        emit(
          state.copyWith(
            selectedStation: updatedStation,
            isLoadingPointData: false,
          ),
        );
      } else {
        if (state.isLoadingPointData) {
          emit(state.copyWith(isLoadingPointData: false));
        }
      }
    } catch (_) {
      if (state.isLoadingPointData) {
        emit(state.copyWith(isLoadingPointData: false));
      }
    }
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

    final matchedQuickCity = _matchQuickCity(cityName);

    if (matchedStation != null) {
      selectStation(matchedStation, quickCity: matchedQuickCity);
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
        quickCity: matchedQuickCity,
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
    final closest = _findClosestStation(lat, lon);
    final closestStation = closest.station;
    final minDistance = closest.distanceKm;

    if (closestStation != null && minDistance <= 35.0) {
      final bool needsWeather = closestStation.temperature == null;
      emit(
        state.copyWith(
          selectedStation: closestStation,
          targetLocation: LatLng(
            closestStation.latitude,
            closestStation.longitude,
          ),
          targetZoom: zoom,
          selectedCityName: label ?? closestStation.province,
          isHomeSelected: true,
          clearSelectedQuickCity: true,
          clearPickedLocation: true,
          isLoadingPointData: needsWeather,
          isShowedAllVN: false,
        ),
      );
      if (needsWeather) {
        _enrichStationWeather(closestStation);
      }
    } else {
      emit(
        state.copyWith(
          clearSelectedStation: true,
          targetLocation: LatLng(lat, lon),
          targetZoom: zoom,
          selectedCityName: label ?? 'Vị trí hiện tại',
          isHomeSelected: true,
          clearSelectedQuickCity: true,
          clearPickedLocation: true,
          isLoadingPointData: false,
        ),
      );
    }
  }

  void selectLocationCoordinates(
    double lat,
    double lon, {
    double zoom = 12.0,
    String? label,
    bool isHome = false,
    QuickCityTarget? quickCity,
  }) {
    if (isHome) {
      selectHomeLocation(lat: lat, lon: lon, zoom: zoom, label: label);
      return;
    }

    final matchedQuickCity =
        quickCity ?? (label != null ? _matchQuickCity(label) : null);

    // Check if there is a station close to this coordinate (within ~35km)
    final closest = _findClosestStation(lat, lon);
    final closestStation = closest.station;
    final minDistance = closest.distanceKm;

    if (closestStation != null && minDistance <= 35.0) {
      selectStation(closestStation, quickCity: matchedQuickCity);
    } else {
      emit(
        state.copyWith(
          clearSelectedStation: true,
          targetLocation: LatLng(lat, lon),
          targetZoom: zoom,
          selectedCityName: label,
          selectedQuickCity: matchedQuickCity,
          clearSelectedQuickCity: matchedQuickCity == null,
          isHomeSelected: false,
          clearPickedLocation: true,
          isLoadingPointData: false,
        ),
      );
    }
  }

  void selectQuickCity(QuickCityTarget target) {
    if (target.isAllCountry) {
      showAllVietnam();
    } else {
      selectLocationCoordinates(
        target.latitude,
        target.longitude,
        zoom: target.zoom,
        label: target.label,
        isHome: false,
        quickCity: target,
      );
    }
  }

  void updateQuickCities(List<QuickCityTarget> cities) {
    emit(state.copyWith(quickCities: cities));
  }

  void showAllVietnam() {
    emit(
      state.copyWith(
        clearSelectedStation: true,
        targetLocation: const LatLng(16.0544, 108.2022),
        targetZoom: 5.8,
        selectedCityName: 'Toàn quốc',
        selectedQuickCity: QuickCityTarget.allVietnam,
        isHomeSelected: false,
        clearPickedLocation: true,
        isLoadingPointData: false,
        isShowedAllVN: true,
      ),
    );
  }

  Future<void> pickCustomLocation(
    LatLng point, {
    String? customName,
    String? customProvince,
    double zoom = 12.5,
  }) async {
    // 1. Tìm trạm quan trắc gần nhất để lấy tham chiếu tỉnh/thành nếu không có custom
    final closest = _findClosestStation(point.latitude, point.longitude);
    final closestStation = closest.station;
    double minDistance = closest.distanceKm;

    String province = customProvince ?? (closestStation?.province ?? '');
    LatLng? referenceCoords = closestStation != null
        ? LatLng(closestStation.latitude, closestStation.longitude)
        : null;

    // Nếu danh sách trạm trống (ví dụ lúc vừa mở app hoặc kiểm thử), tìm theo Single Source of Truth
    if (province.isEmpty) {
      QuickCityTarget? closestCity;
      for (final city in state.quickCities) {
        if (city.isAllCountry) continue;
        final d = GeoDistanceHelper.distanceInKm(
          point.latitude,
          point.longitude,
          city.latitude,
          city.longitude,
        );
        if (d < minDistance) {
          minDistance = d;
          closestCity = city;
        }
      }
      if (closestCity != null) {
        province = closestCity.label;
        referenceCoords = LatLng(closestCity.latitude, closestCity.longitude);
      } else {
        final prov = VietnamProvince.findClosest(point.latitude, point.longitude);
        province = prov.province.provinceName;
        minDistance = prov.distanceKm;
        referenceCoords = LatLng(prov.province.latitude, prov.province.longitude);
      }
    }

    if (province.isEmpty) {
      province = 'Tọa độ GPS';
    }

    // Luôn tính toán khoảng cách từ điểm ghim đến thành phố/trạm tham chiếu
    final String distStr = GeoDistanceHelper.formatDistance(minDistance);

    final name =
        customName ??
        (minDistance.isFinite && distStr.isNotEmpty
            ? 'Điểm ghim ($distStr từ $province)'
            : 'Điểm ghim (${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)})');

    // 2. Tạo placeholder station trong lúc gọi API thời gian thực
    final placeholderStation = StationPollutionEntity(
      id: 'picked_${point.latitude.toStringAsFixed(4)}_${point.longitude.toStringAsFixed(4)}',
      name: name,
      province: province,
      latitude: point.latitude,
      longitude: point.longitude,
      aqi: 0,
      pm25: 0.0,
      pm10: 0.0,
      updatedAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        pickedLocation: point,
        pickedReferenceLocation: referenceCoords,
        pickedDistanceKm: minDistance.isFinite ? minDistance : null,
        isPickingLocation: true,
        isLoadingPointData: true,
        selectedStation: placeholderStation,
        targetLocation: point,
        targetZoom: zoom,
        isHomeSelected: false,
        clearSelectedCityName: true,
        clearSelectedQuickCity: true,
      ),
    );

    try {
      // 3. Gọi đồng thời cả API Air Quality và Weather cho tọa độ bất kỳ vừa pick
      final airFuture = airQualityRepository?.getAirQuality(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      final weatherFuture = weatherRepository?.getWeatherForecast(
        latitude: point.latitude,
        longitude: point.longitude,
      );

      final airRes = airFuture != null ? await airFuture : null;
      final weatherRes = weatherFuture != null ? await weatherFuture : null;

      // Đảm bảo người dùng vẫn đang chọn điểm này (chưa hủy chọn hoặc đổi điểm)
      if (state.pickedLocation == point) {
        int aqi = 0;
        double pm25 = 0.0;
        double pm10 = 0.0;

        if (airRes != null && airRes.isSuccess && airRes.data != null) {
          final AirQualityEntity airData = airRes.data!;
          aqi = airData.usAqi;
          pm25 = airData.pm25;
          pm10 = airData.pm10;
        }

        double? temp;
        double? apparentTemp;
        int? weatherCode;
        int? humidity;
        double? windSpeed;
        double? precipitation;
        double? uvIndex;

        if (weatherRes != null &&
            weatherRes.isSuccess &&
            weatherRes.data != null) {
          final WeatherEntity weatherData = weatherRes.data!;
          temp = weatherData.currentTemp;
          apparentTemp = weatherData.apparentTemp;
          weatherCode = weatherData.weatherCode;
          humidity = weatherData.relativeHumidity;
          windSpeed = weatherData.windSpeed;
          precipitation = weatherData.precipitation;
          uvIndex = weatherData.uvIndex;
        }

        final enrichedStation = placeholderStation.copyWith(
          aqi: aqi,
          pm25: pm25,
          pm10: pm10,
          temperature: temp,
          apparentTemp: apparentTemp,
          weatherCode: weatherCode,
          humidity: humidity,
          windSpeed: windSpeed,
          precipitation: precipitation,
          uvIndex: uvIndex,
        );

        emit(
          state.copyWith(
            selectedStation: enrichedStation,
            isPickingLocation: false,
            isLoadingPointData: false,
            clearSelectedCityName: true,
            clearSelectedQuickCity: true,
            isHomeSelected: false,
          ),
        );
      }
    } catch (_) {
      if (state.pickedLocation == point) {
        emit(
          state.copyWith(
            isPickingLocation: false,
            isLoadingPointData: false,
            clearSelectedCityName: true,
            clearSelectedQuickCity: true,
            isHomeSelected: false,
          ),
        );
      }
    }
  }

  void clearPickedLocation() {
    final wasPickedSelected =
        state.selectedStation?.id.startsWith('picked_') ?? false;
    emit(
      state.copyWith(
        clearPickedLocation: true,
        isPickingLocation: false,
        isLoadingPointData: false,
        clearSelectedStation: wasPickedSelected,
        clearSelectedQuickCity: wasPickedSelected,
        clearSelectedCityName: wasPickedSelected,
      ),
    );
    showAllVietnam();
  }

  void clearSelection() {
    emit(
      state.copyWith(
        clearSelectedStation: true,
        clearTargetLocation: true,
        clearSelectedCityName: true,
        clearSelectedQuickCity: true,
        clearPickedLocation: true,
        isPickingLocation: false,
        isLoadingPointData: false,
        isHomeSelected: false,
      ),
    );
  }

  void setFilter(String filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void toggleHeatmap() {
    emit(state.copyWith(showHeatmap: !state.showHeatmap));
  }

  String _normalize(String input) => GeoDistanceHelper.normalizeName(input);

  LatLng? _getCityCoordinates(String cityName) {
    // 1. Thử khớp theo QuickCityTarget
    final target = _matchQuickCity(cityName);
    if (target != null) {
      return LatLng(target.latitude, target.longitude);
    }

    // 2. Thử khớp theo danh sách thành phố phổ biến (CityEntity.popularCities)
    final norm = GeoDistanceHelper.normalizeName(cityName);
    for (final city in CityEntity.popularCities) {
      final normCity = GeoDistanceHelper.normalizeName(city.name);
      if (normCity.contains(norm) || norm.contains(normCity)) {
        return LatLng(city.latitude, city.longitude);
      }
    }

    // 3. Thử khớp theo danh mục tỉnh thành Việt Nam (VietnamProvince)
    for (final prov in VietnamProvince.values) {
      final normProv = GeoDistanceHelper.normalizeName(prov.provinceName);
      if (normProv.contains(norm) || norm.contains(normProv)) {
        return LatLng(prov.latitude, prov.longitude);
      }
    }

    return null;
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) =>
      GeoDistanceHelper.distanceInKm(lat1, lon1, lat2, lon2);
}
