import 'package:equatable/equatable.dart';
import '../../domain/entities/air_quality_entity.dart';

enum AirQualityStatus { initial, loading, success, failure }

class AirQualityState extends Equatable {
  final AirQualityStatus status;
  final AirQualityEntity airQuality;
  final String? errorMessage;
  final String? noticeMessage;

  const AirQualityState({
    this.status = AirQualityStatus.initial,
    this.airQuality = const AirQualityEntity(),
    this.errorMessage,
    this.noticeMessage,
  });

  AirQualityState copyWith({
    AirQualityStatus? status,
    AirQualityEntity? airQuality,
    String? errorMessage,
    String? noticeMessage,
  }) {
    return AirQualityState(
      status: status ?? this.status,
      airQuality: airQuality ?? this.airQuality,
      errorMessage: errorMessage ?? this.errorMessage,
      noticeMessage: noticeMessage ?? this.noticeMessage,
    );
  }

  @override
  List<Object?> get props => [status, airQuality, errorMessage, noticeMessage];
}
