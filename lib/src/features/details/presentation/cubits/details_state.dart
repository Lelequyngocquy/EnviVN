import 'package:equatable/equatable.dart';
import '../../domain/entities/details_entity.dart';
import '../widgets/detail_segmented_filter.dart';

enum DetailsStatus { initial, loading, success, failure }

class DetailsState extends Equatable {
  final DetailsStatus status;
  final DetailsEntity details;
  final String? errorMessage;
  final String? noticeMessage;
  final DetailTab activeDetailTab;

  const DetailsState({
    this.status = DetailsStatus.initial,
    this.details = const DetailsEntity(),
    this.errorMessage,
    this.noticeMessage,
    this.activeDetailTab = DetailTab.all,
  });

  DetailsEntity get weather => details;

  bool get showWeatherSection =>
      activeDetailTab == DetailTab.all || activeDetailTab == DetailTab.weather;

  bool get showAirQualitySection =>
      activeDetailTab == DetailTab.all ||
      activeDetailTab == DetailTab.airQuality;

  DetailsState copyWith({
    DetailsStatus? status,
    DetailsEntity? details,
    DetailsEntity? weather,
    String? errorMessage,
    String? noticeMessage,
    DetailTab? activeDetailTab,
  }) {
    return DetailsState(
      status: status ?? this.status,
      details: details ?? weather ?? this.details,
      errorMessage: errorMessage ?? this.errorMessage,
      noticeMessage: noticeMessage ?? this.noticeMessage,
      activeDetailTab: activeDetailTab ?? this.activeDetailTab,
    );
  }

  @override
  List<Object?> get props => [
    status,
    details,
    errorMessage,
    noticeMessage,
    activeDetailTab,
  ];
}

// Backward-compatibility aliases
typedef WeatherStatus = DetailsStatus;
typedef WeatherState = DetailsState;
