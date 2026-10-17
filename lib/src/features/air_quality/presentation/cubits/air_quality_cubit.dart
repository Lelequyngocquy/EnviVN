import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/interfaces/i_air_quality_repository.dart';
import 'air_quality_state.dart';

class AirQualityCubit extends Cubit<AirQualityState> {
  final IAirQualityRepository repository;

  AirQualityCubit({required this.repository}) : super(const AirQualityState()) {
    // Immediately show offline cached data if present
    final cached = repository.getCachedAirQuality();
    if (cached != null) {
      emit(state.copyWith(
        status: AirQualityStatus.success,
        airQuality: cached,
        noticeMessage: 'Dữ liệu đã lưu ngoại tuyến',
      ));
    }
  }

  Future<void> fetchAirQuality({required double latitude, required double longitude}) async {
    emit(state.copyWith(status: AirQualityStatus.loading, errorMessage: null));

    final result = await repository.getAirQuality(
      latitude: latitude,
      longitude: longitude,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: AirQualityStatus.success,
        airQuality: result.data,
        noticeMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        status: AirQualityStatus.failure,
        errorMessage: result.message ?? 'Không thể tải chỉ số chất lượng không khí',
      ));
    }
  }
}
