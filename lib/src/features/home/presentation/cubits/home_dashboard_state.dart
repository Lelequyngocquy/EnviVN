import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/app_location_entity.dart';

enum DashboardStatus { initial, loading, success, failure }

class HomeDashboardState extends Equatable {
  final DashboardStatus status;
  final AppLocationEntity currentCity;
  final DateTime? lastUpdated;
  final String? noticeMessage;
  final int currentTab;
  final bool isChangingLocation;
  final bool hasNotification;
  final bool isLocationPermissionGranted;
  final bool hasPendingMapSync;

  const HomeDashboardState({
    this.status = DashboardStatus.initial,
    this.currentCity = AppLocationEntity.defaultLocation,
    this.lastUpdated,
    this.noticeMessage,
    this.currentTab = 0,
    this.isChangingLocation = false,
    this.hasNotification = false,
    this.isLocationPermissionGranted = false,
    this.hasPendingMapSync = true,
  });

  AppLocationEntity get currentLocation => currentCity;

  bool isInitialLoading(int hourlyForecastLength) =>
      status == DashboardStatus.loading && hourlyForecastLength == 0;

  HomeDashboardState copyWith({
    DashboardStatus? status,
    AppLocationEntity? currentCity,
    DateTime? lastUpdated,
    String? noticeMessage,
    bool clearNotice = false,
    int? currentTab,
    bool? isChangingLocation,
    bool? hasNotification,
    bool? isLocationPermissionGranted,
    bool? hasPendingMapSync,
  }) {
    return HomeDashboardState(
      status: status ?? this.status,
      currentCity: currentCity ?? this.currentCity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      noticeMessage: clearNotice ? null : (noticeMessage ?? this.noticeMessage),
      currentTab: currentTab ?? this.currentTab,
      isChangingLocation: isChangingLocation ?? this.isChangingLocation,
      hasNotification: hasNotification ?? this.hasNotification,
      isLocationPermissionGranted:
          isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      hasPendingMapSync: hasPendingMapSync ?? this.hasPendingMapSync,
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
    hasNotification,
    isLocationPermissionGranted,
    hasPendingMapSync,
  ];
}
