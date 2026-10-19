import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';
import '../widgets/detail_segmented_filter.dart';

enum WeatherStatus { initial, loading, success, failure }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherEntity weather;
  final String? errorMessage;
  final String? noticeMessage;
  final DetailTab activeDetailTab;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather = const WeatherEntity(),
    this.errorMessage,
    this.noticeMessage,
    this.activeDetailTab = DetailTab.all,
  });

  bool get showWeatherSection =>
      activeDetailTab == DetailTab.all || activeDetailTab == DetailTab.weather;

  bool get showAirQualitySection =>
      activeDetailTab == DetailTab.all || activeDetailTab == DetailTab.airQuality;

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherEntity? weather,
    String? errorMessage,
    String? noticeMessage,
    DetailTab? activeDetailTab,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      errorMessage: errorMessage ?? this.errorMessage,
      noticeMessage: noticeMessage ?? this.noticeMessage,
      activeDetailTab: activeDetailTab ?? this.activeDetailTab,
    );
  }

  @override
  List<Object?> get props => [
        status,
        weather,
        errorMessage,
        noticeMessage,
        activeDetailTab,
      ];
}
