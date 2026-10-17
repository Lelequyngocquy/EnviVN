import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';

enum WeatherStatus { initial, loading, success, failure }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherEntity weather;
  final String? errorMessage;
  final String? noticeMessage;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather = const WeatherEntity(),
    this.errorMessage,
    this.noticeMessage,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherEntity? weather,
    String? errorMessage,
    String? noticeMessage,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      errorMessage: errorMessage ?? this.errorMessage,
      noticeMessage: noticeMessage ?? this.noticeMessage,
    );
  }

  @override
  List<Object?> get props => [status, weather, errorMessage, noticeMessage];
}
