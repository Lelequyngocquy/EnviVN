import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/station_pollution_entity.dart';

enum MapPollutionStatus { initial, loading, success, failure }

class MapPollutionState extends Equatable {
  final MapPollutionStatus status;
  final List<StationPollutionEntity> stations;
  final StationPollutionEntity? selectedStation;
  final LatLng? targetLocation;
  final double? targetZoom;
  final String? selectedCityName;
  final String activeFilter; // 'all', 'good', 'warning'
  final bool showHeatmap;
  final String? errorMessage;

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
  });

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
      ];
}

