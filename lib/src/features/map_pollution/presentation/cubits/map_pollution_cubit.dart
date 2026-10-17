import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/station_pollution_entity.dart';
import '../../domain/interfaces/i_map_pollution_repository.dart';
import 'map_pollution_state.dart';

class MapPollutionCubit extends Cubit<MapPollutionState> {
  final IMapPollutionRepository repository;

  MapPollutionCubit({required this.repository}) : super(const MapPollutionState());

  Future<void> fetchVietnamStations() async {
    emit(state.copyWith(status: MapPollutionStatus.loading, errorMessage: null));

    final result = await repository.getVietnamStations();

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: MapPollutionStatus.success,
        stations: result.data,
      ));
    } else {
      emit(state.copyWith(
        status: MapPollutionStatus.failure,
        errorMessage: result.message ?? 'Không thể tải trạm quan trắc trên bản đồ',
      ));
    }
  }

  void selectStation(StationPollutionEntity station) {
    emit(state.copyWith(selectedStation: station));
  }

  void clearSelection() {
    emit(state.copyWith(selectedStation: null));
  }
}
