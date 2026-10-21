import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/map_layer_type.dart';
import '../../domain/entities/quick_city_target.dart';
import '../../domain/entities/station_entity.dart';
import '../../infrastructure/models/thermal_hotspot_model.dart';

enum MapStatus { initial, loading, success, failure }

class MapState extends Equatable {
  final MapStatus status;
  final List<StationEntity> stations;
  final StationEntity? selectedStation;
  final LatLng? targetLocation;
  final double? targetZoom;
  final String? selectedCityName;
  final String activeFilter;
  final bool showHeatmap;
  final String? errorMessage;
  final List<QuickCityTarget> quickCities;
  final QuickCityTarget? selectedQuickCity;
  final bool isHomeSelected;
  final LatLng? userGpsLocation;
  final LatLng? pickedLocation;
  final LatLng? pickedReferenceLocation;
  final double? pickedDistanceKm;
  final bool isPickingLocation;
  final bool isLoadingPointData;
  final MapLayerType activeLayer;
  final bool isShowedAllVN;
  final List<ThermalHotspotModel> thermalHotspots;
  final bool isLoadingThermal;
  final String? thermalNotice;
  final bool isThermalFromCache;

  const MapState({
    this.status = MapStatus.initial,
    this.stations = const [],
    this.selectedStation,
    this.targetLocation,
    this.targetZoom,
    this.selectedCityName,
    this.activeFilter = 'all',
    this.showHeatmap = true,
    this.errorMessage,
    this.quickCities = QuickCityTarget.values,
    this.selectedQuickCity,
    this.isHomeSelected = false,
    this.userGpsLocation,
    this.pickedLocation,
    this.pickedReferenceLocation,
    this.pickedDistanceKm,
    this.isPickingLocation = false,
    this.isLoadingPointData = false,
    this.activeLayer = MapLayerType.weather,
    this.isShowedAllVN = false,
    this.thermalHotspots = ThermalHotspotModel.sampleHotspots,
    this.isLoadingThermal = false,
    this.thermalNotice,
    this.isThermalFromCache = false,
  });

  List<StationEntity> get filteredStations {
    if (activeFilter == 'good') {
      return stations.where((st) => st.aqi <= 50).toList();
    }
    if (activeFilter == 'moderate') {
      return stations.where((st) => st.aqi > 50 && st.aqi <= 100).toList();
    }
    if (activeFilter == 'unhealthy' || activeFilter == 'warning') {
      return stations.where((st) => st.aqi > 100).toList();
    }
    return stations;
  }

  MapState copyWith({
    MapStatus? status,
    List<StationEntity>? stations,
    StationEntity? selectedStation,
    bool clearSelectedStation = false,
    LatLng? targetLocation,
    bool clearTargetLocation = false,
    double? targetZoom,
    String? selectedCityName,
    bool clearSelectedCityName = false,
    String? activeFilter,
    bool? showHeatmap,
    String? errorMessage,
    List<QuickCityTarget>? quickCities,
    QuickCityTarget? selectedQuickCity,
    bool clearSelectedQuickCity = false,
    bool? isHomeSelected,
    LatLng? userGpsLocation,
    bool clearUserGpsLocation = false,
    LatLng? pickedLocation,
    bool clearPickedLocation = false,
    LatLng? pickedReferenceLocation,
    bool clearPickedReferenceLocation = false,
    double? pickedDistanceKm,
    bool clearPickedDistanceKm = false,
    bool? isPickingLocation,
    bool? isLoadingPointData,
    MapLayerType? activeLayer,
    bool? isShowedAllVN,
    List<ThermalHotspotModel>? thermalHotspots,
    bool? isLoadingThermal,
    String? thermalNotice,
    bool clearThermalNotice = false,
    bool? isThermalFromCache,
  }) {
    return MapState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      selectedStation: clearSelectedStation
          ? null
          : (selectedStation ?? this.selectedStation),
      targetLocation: clearTargetLocation
          ? null
          : (targetLocation ?? this.targetLocation),
      targetZoom: targetZoom ?? this.targetZoom,
      selectedCityName: clearSelectedCityName
          ? null
          : (selectedCityName ?? this.selectedCityName),
      activeFilter: activeFilter ?? this.activeFilter,
      showHeatmap: showHeatmap ?? this.showHeatmap,
      errorMessage: errorMessage ?? this.errorMessage,
      quickCities: quickCities ?? this.quickCities,
      selectedQuickCity: clearSelectedQuickCity
          ? null
          : (selectedQuickCity ?? this.selectedQuickCity),
      isHomeSelected: isHomeSelected ?? this.isHomeSelected,
      userGpsLocation: clearUserGpsLocation
          ? null
          : (userGpsLocation ?? this.userGpsLocation),
      pickedLocation: clearPickedLocation
          ? null
          : (pickedLocation ?? this.pickedLocation),
      pickedReferenceLocation:
          clearPickedLocation || clearPickedReferenceLocation
          ? null
          : (pickedReferenceLocation ?? this.pickedReferenceLocation),
      pickedDistanceKm: clearPickedLocation || clearPickedDistanceKm
          ? null
          : (pickedDistanceKm ?? this.pickedDistanceKm),
      isPickingLocation: isPickingLocation ?? this.isPickingLocation,
      isLoadingPointData: isLoadingPointData ?? this.isLoadingPointData,
      activeLayer: activeLayer ?? this.activeLayer,
      isShowedAllVN: isShowedAllVN ?? this.isShowedAllVN,
      thermalHotspots: thermalHotspots ?? this.thermalHotspots,
      isLoadingThermal: isLoadingThermal ?? this.isLoadingThermal,
      thermalNotice: clearThermalNotice
          ? null
          : (thermalNotice ?? this.thermalNotice),
      isThermalFromCache: isThermalFromCache ?? this.isThermalFromCache,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stations,
    selectedStation,
    targetLocation,
    targetZoom,
    selectedCityName,
    activeFilter,
    showHeatmap,
    errorMessage,
    quickCities,
    selectedQuickCity,
    isHomeSelected,
    userGpsLocation,
    pickedLocation,
    pickedReferenceLocation,
    pickedDistanceKm,
    isPickingLocation,
    isLoadingPointData,
    activeLayer,
    isShowedAllVN,
    thermalHotspots,
    isLoadingThermal,
    thermalNotice,
    isThermalFromCache,
  ];
}
