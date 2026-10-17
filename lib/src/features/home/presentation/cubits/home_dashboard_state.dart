import 'package:equatable/equatable.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';

enum DashboardStatus { initial, loading, success, failure }

class HomeDashboardState extends Equatable {
  final DashboardStatus status;
  final CityEntity currentCity;
  final DateTime? lastUpdated;
  final String? noticeMessage;
  final int currentTab;
  final bool isChangingLocation;

  const HomeDashboardState({
    this.status = DashboardStatus.initial,
    this.currentCity = CityEntity.defaultCity,
    this.lastUpdated,
    this.noticeMessage,
    this.currentTab = 0,
    this.isChangingLocation = false,
  });

  HomeDashboardState copyWith({
    DashboardStatus? status,
    CityEntity? currentCity,
    DateTime? lastUpdated,
    String? noticeMessage,
    bool clearNotice = false,
    int? currentTab,
    bool? isChangingLocation,
  }) {
    return HomeDashboardState(
      status: status ?? this.status,
      currentCity: currentCity ?? this.currentCity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      noticeMessage: clearNotice ? null : (noticeMessage ?? this.noticeMessage),
      currentTab: currentTab ?? this.currentTab,
      isChangingLocation: isChangingLocation ?? this.isChangingLocation,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentCity,
        lastUpdated,
        noticeMessage,
        currentTab,
        isChangingLocation,
      ];
}
