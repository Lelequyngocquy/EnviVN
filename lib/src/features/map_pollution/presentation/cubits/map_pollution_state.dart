import 'package:equatable/equatable.dart';
import '../../domain/entities/station_pollution_entity.dart';

enum MapPollutionStatus { initial, loading, success, failure }

class MapPollutionState extends Equatable {
  final MapPollutionStatus status;
  final List<StationPollutionEntity> stations;
  final StationPollutionEntity? selectedStation;
  final String? errorMessage;

  const MapPollutionState({
    this.status = MapPollutionStatus.initial,
    this.stations = const [],
    this.selectedStation,
    this.errorMessage,
  });

  MapPollutionState copyWith({
    MapPollutionStatus? status,
    List<StationPollutionEntity>? stations,
    StationPollutionEntity? selectedStation,
    String? errorMessage,
  }) {
    return MapPollutionState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      selectedStation: selectedStation ?? this.selectedStation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stations, selectedStation, errorMessage];
}
