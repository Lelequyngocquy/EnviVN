import 'package:equatable/equatable.dart';

enum LocationOriginType { gps, popularCity, monitoringStation, customMapPin }

enum PopularLocation {
  hanoi(
    id: 'city_hanoi',
    displayName: 'Hà Nội',
    provinceOrRegion: 'Thủ đô Hà Nội',
    latitude: 21.0285,
    longitude: 105.8542,
  ),
  hcm(
    id: 'city_hcm',
    displayName: 'TP. Hồ Chí Minh',
    provinceOrRegion: 'TP. Hồ Chí Minh',
    latitude: 10.7769,
    longitude: 106.7009,
  ),
  daNang(
    id: 'city_danang',
    displayName: 'Đà Nẵng',
    provinceOrRegion: 'Đà Nẵng',
    latitude: 16.0544,
    longitude: 108.2022,
  ),
  haiPhong(
    id: 'city_haiphong',
    displayName: 'Hải Phòng',
    provinceOrRegion: 'Hải Phòng',
    latitude: 20.8449,
    longitude: 106.6881,
  ),
  canTho(
    id: 'city_cantho',
    displayName: 'Cần Thơ',
    provinceOrRegion: 'Cần Thơ',
    latitude: 10.0452,
    longitude: 105.7469,
  ),
  hue(
    id: 'city_hue',
    displayName: 'Huế',
    provinceOrRegion: 'Thừa Thiên Huế',
    latitude: 16.4637,
    longitude: 107.5909,
  ),
  nhaTrang(
    id: 'city_nhatrang',
    displayName: 'Nha Trang',
    provinceOrRegion: 'Khánh Hòa',
    latitude: 12.2388,
    longitude: 109.1967,
  ),
  daLat(
    id: 'city_dalat',
    displayName: 'Đà Lạt',
    provinceOrRegion: 'Lâm Đồng',
    latitude: 11.9404,
    longitude: 108.4583,
  ),
  haLong(
    id: 'city_halong',
    displayName: 'Hạ Long',
    provinceOrRegion: 'Quảng Ninh',
    latitude: 20.9505,
    longitude: 107.0734,
  ),
  vungTau(
    id: 'city_vungtau',
    displayName: 'Vũng Tàu',
    provinceOrRegion: 'Bà Rịa - Vũng Tàu',
    latitude: 10.3460,
    longitude: 107.0843,
  ),
  quyNhon(
    id: 'city_quynhon',
    displayName: 'Quy Nhơn',
    provinceOrRegion: 'Bình Định',
    latitude: 13.7820,
    longitude: 109.2197,
  ),
  buonMaThuot(
    id: 'city_buonmathuot',
    displayName: 'Buôn Ma Thuột',
    provinceOrRegion: 'Đắk Lắk',
    latitude: 12.6675,
    longitude: 108.0383,
  ),
  hoangSa(
    id: 'city_hoangsa',
    displayName: 'Quần đảo Hoàng Sa',
    provinceOrRegion: 'TP. Đà Nẵng',
    latitude: 16.5333,
    longitude: 112.0333,
  ),
  truongSa(
    id: 'city_truongsa',
    displayName: 'Quần đảo Trường Sa',
    provinceOrRegion: 'Tỉnh Khánh Hòa',
    latitude: 9.8833,
    longitude: 114.2500,
  );

  final String id;
  final String displayName;
  final String provinceOrRegion;
  final double latitude;
  final double longitude;

  const PopularLocation({
    required this.id,
    required this.displayName,
    required this.provinceOrRegion,
    required this.latitude,
    required this.longitude,
  });

  String get name => displayName;
  String get province => provinceOrRegion;

  AppLocationEntity toEntity() {
    return AppLocationEntity(
      id: id,
      displayName: displayName,
      provinceOrRegion: provinceOrRegion,
      latitude: latitude,
      longitude: longitude,
      originType: LocationOriginType.popularCity,
    );
  }
}

class AppLocationEntity extends Equatable {
  final String id;
  final String displayName;
  final String provinceOrRegion;
  final double latitude;
  final double longitude;
  final LocationOriginType originType;
  final double? distanceToNearestProvinceKm;
  final String? referenceProvinceName;

  const AppLocationEntity({
    required this.id,
    required this.displayName,
    required this.provinceOrRegion,
    required this.latitude,
    required this.longitude,
    this.originType = LocationOriginType.popularCity,
    this.distanceToNearestProvinceKm,
    this.referenceProvinceName,
  });

  String get name => displayName;
  String get province => provinceOrRegion;
  bool get isGps => originType == LocationOriginType.gps;
  bool get isCustomPin => originType == LocationOriginType.customMapPin;
  bool get isStation => originType == LocationOriginType.monitoringStation;

  String get formattedSubtitle {
    if (isCustomPin &&
        distanceToNearestProvinceKm != null &&
        referenceProvinceName != null) {
      final distStr = distanceToNearestProvinceKm! < 10.0
          ? distanceToNearestProvinceKm!.toStringAsFixed(1)
          : distanceToNearestProvinceKm!.toStringAsFixed(0);
      return 'Cách ~$distStr km từ $referenceProvinceName';
    }
    return provinceOrRegion;
  }

  factory AppLocationEntity.gps({
    required double latitude,
    required double longitude,
    String displayName = 'Vị trí hiện tại',
    String provinceOrRegion = 'Định vị GPS',
  }) {
    return AppLocationEntity(
      id: 'gps_current',
      displayName: displayName,
      provinceOrRegion: provinceOrRegion,
      latitude: latitude,
      longitude: longitude,
      originType: LocationOriginType.gps,
    );
  }

  factory AppLocationEntity.city({
    required String name,
    required String province,
    required double latitude,
    required double longitude,
    bool isGps = false,
  }) {
    return AppLocationEntity(
      id: isGps
          ? 'gps_current'
          : 'city_${name.toLowerCase().replaceAll(' ', '_')}',
      displayName: name,
      provinceOrRegion: province,
      latitude: latitude,
      longitude: longitude,
      originType: isGps
          ? LocationOriginType.gps
          : LocationOriginType.popularCity,
    );
  }

  factory AppLocationEntity.station({
    required String id,
    required String name,
    required String province,
    required double latitude,
    required double longitude,
  }) {
    return AppLocationEntity(
      id: 'station_$id',
      displayName: name,
      provinceOrRegion: province,
      latitude: latitude,
      longitude: longitude,
      originType: LocationOriginType.monitoringStation,
      referenceProvinceName: province,
    );
  }

  factory AppLocationEntity.customPin({
    required double latitude,
    required double longitude,
    String? customName,
    String? referenceProvince,
    double? distanceKm,
  }) {
    final distStr = distanceKm != null
        ? (distanceKm < 10.0
              ? distanceKm.toStringAsFixed(1)
              : distanceKm.toStringAsFixed(0))
        : '';
    final name =
        customName ??
        (referenceProvince != null &&
                referenceProvince.isNotEmpty &&
                distStr.isNotEmpty
            ? 'Điểm ghim (~$distStr km từ $referenceProvince)'
            : 'Điểm ghim (${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)})');

    return AppLocationEntity(
      id: 'custom_${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}',
      displayName: name,
      provinceOrRegion: referenceProvince ?? 'Tọa độ GPS',
      latitude: latitude,
      longitude: longitude,
      originType: LocationOriginType.customMapPin,
      distanceToNearestProvinceKm: distanceKm,
      referenceProvinceName: referenceProvince,
    );
  }

  static const defaultLocation = AppLocationEntity(
    id: 'city_hanoi',
    displayName: 'Hà Nội',
    provinceOrRegion: 'Thủ đô Hà Nội',
    latitude: 21.0285,
    longitude: 105.8542,
    originType: LocationOriginType.popularCity,
  );

  static List<AppLocationEntity> get popularLocations =>
      PopularLocation.values.map((loc) => loc.toEntity()).toList();

  AppLocationEntity copyWith({
    String? id,
    String? displayName,
    String? provinceOrRegion,
    double? latitude,
    double? longitude,
    LocationOriginType? originType,
    double? distanceToNearestProvinceKm,
    String? referenceProvinceName,
  }) {
    return AppLocationEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      provinceOrRegion: provinceOrRegion ?? this.provinceOrRegion,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      originType: originType ?? this.originType,
      distanceToNearestProvinceKm:
          distanceToNearestProvinceKm ?? this.distanceToNearestProvinceKm,
      referenceProvinceName:
          referenceProvinceName ?? this.referenceProvinceName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    provinceOrRegion,
    latitude,
    longitude,
    originType,
    distanceToNearestProvinceKm,
    referenceProvinceName,
  ];
}
