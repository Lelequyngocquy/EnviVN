import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/interfaces/i_details_repository.dart';
import '../widgets/detail_segmented_filter.dart';
import 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  final IDetailsRepository repository;

  DetailsCubit({required this.repository}) : super(const DetailsState()) {
    final cached = repository.getCachedDetails();
    if (cached != null) {
      emit(state.copyWith(
        status: DetailsStatus.success,
        details: cached,
        noticeMessage: 'Dữ liệu đã lưu ngoại tuyến',
      ));
    }
  }

  void setDetailTab(DetailTab tab) {
    if (state.activeDetailTab != tab) {
      emit(state.copyWith(activeDetailTab: tab));
    }
  }

  Future<void> fetchDetails({required double latitude, required double longitude}) async {
    emit(state.copyWith(status: DetailsStatus.loading, errorMessage: null));

    final result = await repository.getDetailsForecast(
      latitude: latitude,
      longitude: longitude,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: DetailsStatus.success,
        details: result.data,
        noticeMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        status: DetailsStatus.failure,
        errorMessage: result.message ?? 'Không thể tải dữ liệu chi tiết',
      ));
    }
  }

  // Compatibility alias
  Future<void> fetchWeather({required double latitude, required double longitude}) =>
      fetchDetails(latitude: latitude, longitude: longitude);
}

// Backward-compatibility alias
typedef WeatherCubit = DetailsCubit;
