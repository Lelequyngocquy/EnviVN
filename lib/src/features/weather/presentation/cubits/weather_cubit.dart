import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/interfaces/i_weather_repository.dart';
import '../widgets/detail_segmented_filter.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final IWeatherRepository repository;

  WeatherCubit({required this.repository}) : super(const WeatherState()) {
    
    final cached = repository.getCachedWeather();
    if (cached != null) {
      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: cached,
        noticeMessage: 'Dữ liệu đã lưu ngoại tuyến',
      ));
    }
  }

  void setDetailTab(DetailTab tab) {
    if (state.activeDetailTab != tab) {
      emit(state.copyWith(activeDetailTab: tab));
    }
  }

  Future<void> fetchWeather({required double latitude, required double longitude}) async {
    emit(state.copyWith(status: WeatherStatus.loading, errorMessage: null));

    final result = await repository.getWeatherForecast(
      latitude: latitude,
      longitude: longitude,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: result.data,
        noticeMessage: result.message,
      ));
    } else {
      emit(state.copyWith(
        status: WeatherStatus.failure,
        errorMessage: result.message ?? 'Không thể tải dữ liệu thời tiết',
      ));
    }
  }
}
