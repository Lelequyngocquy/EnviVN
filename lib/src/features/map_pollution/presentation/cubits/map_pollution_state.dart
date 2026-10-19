import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/quick_city_target.dart';
import '../../domain/entities/station_pollution_entity.dart';

enum MapPollutionStatus { initial, loading, success, failure }

class MapPollutionState extends Equatable {
  final MapPollutionStatus status;
  final List<StationPollutionEntity> stations;
  final StationPollutionEntity? selectedStation;
  final LatLng? targetLocation;
  final double? targetZoom;
  final String? selectedCityName;
  final String activeFilter; // 'all', 'good', 'moderate', 'unhealthy' (hoặc 'warning')
  final bool showHeatmap;
  final String? errorMessage;
  final List<QuickCityTarget> quickCities;
  final bool isHomeSelected;
  final LatLng? userGpsLocation;

  const MapPollutionState({
    this.status = MapPollutionStatus.initial,
    this.stations = const [],
    this.selectedStation,
    this.targetLocation,
    this.targetZoom,
    this.selectedCityName,
    this.activeFilter = 'all',
    this.showHeatmap = true,
    this.errorMessage,
    this.quickCities = QuickCityTarget.values,
    this.isHomeSelected = false,
    this.userGpsLocation,
  });

  List<StationPollutionEntity> get filteredStations {
    if (activeFilter == 'good') {
      return stations.where((st) => st.aqi <= 50).toList();
    }
    if (activeFilter == 'moderate') {
      return stations.where((st) => st.aqi > 50 && st.aqi <= 100).toList();
    }
    if (activeFilter == 'unhealthy' || activeFilter == 'warning') {
      return stations.where((st) => st.aqi > 100).toList();
    }
    return stations;
  }

  MapPollutionState copyWith({
    MapPollutionStatus? status,
    List<StationPollutionEntity>? stations,
    StationPollutionEntity? selectedStation,
    bool clearSelectedStation = false,
    LatLng? targetLocation,
    bool clearTargetLocation = false,
    double? targetZoom,
    String? selectedCityName,
    bool clearSelectedCityName = false,
    String? activeFilter,
    bool? showHeatmap,
    String? errorMessage,
    List<QuickCityTarget>? quickCities,
    bool? isHomeSelected,
    LatLng? userGpsLocation,
    bool clearUserGpsLocation = false,
  }) {
    return MapPollutionState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      selectedStation: clearSelectedStation ? null : (selectedStation ?? this.selectedStation),
      targetLocation: clearTargetLocation ? null : (targetLocation ?? this.targetLocation),
      targetZoom: targetZoom ?? this.targetZoom,
      selectedCityName: clearSelectedCityName ? null : (selectedCityName ?? this.selectedCityName),
      activeFilter: activeFilter ?? this.activeFilter,
      showHeatmap: showHeatmap ?? this.showHeatmap,
      errorMessage: errorMessage ?? this.errorMessage,
      quickCities: quickCities ?? this.quickCities,
      isHomeSelected: isHomeSelected ?? this.isHomeSelected,
      userGpsLocation: clearUserGpsLocation ? null : (userGpsLocation ?? this.userGpsLocation),
    );
  }

  @override
  List<Object?> get props => [
        status,
        stations,
        selectedStation,
        targetLocation,
        targetZoom,
        selectedCityName,
        activeFilter,
        showHeatmap,
        errorMessage,
        quickCities,
        isHomeSelected,
        userGpsLocation,
      ];
}

