class CityEntity {
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  final bool isGps;

  const CityEntity({
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
    this.isGps = false,
  });

  static const defaultCity = CityEntity(
    name: 'Hà Nội',
    province: 'Thủ đô Hà Nội',
    latitude: 21.0285,
    longitude: 105.8542,
  );

  static const List<CityEntity> popularCities = [
    CityEntity(name: 'Hà Nội', province: 'Thủ đô Hà Nội', latitude: 21.0285, longitude: 105.8542),
    CityEntity(name: 'TP. Hồ Chí Minh', province: 'TP. Hồ Chí Minh', latitude: 10.7769, longitude: 106.7009),
    CityEntity(name: 'Đà Nẵng', province: 'Đà Nẵng', latitude: 16.0544, longitude: 108.2022),
    CityEntity(name: 'Hải Phòng', province: 'Hải Phòng', latitude: 20.8449, longitude: 106.6881),
    CityEntity(name: 'Cần Thơ', province: 'Cần Thơ', latitude: 10.0452, longitude: 105.7469),
    CityEntity(name: 'Huế', province: 'Thừa Thiên Huế', latitude: 16.4637, longitude: 107.5909),
    CityEntity(name: 'Nha Trang', province: 'Khánh Hòa', latitude: 12.2388, longitude: 109.1967),
    CityEntity(name: 'Đà Lạt', province: 'Lâm Đồng', latitude: 11.9404, longitude: 108.4583),
    CityEntity(name: 'Hạ Long', province: 'Quảng Ninh', latitude: 20.9505, longitude: 107.0734),
    CityEntity(name: 'Vũng Tàu', province: 'Bà Rịa - Vũng Tàu', latitude: 10.3460, longitude: 107.0843),
    CityEntity(name: 'Quy Nhơn', province: 'Bình Định', latitude: 13.7820, longitude: 109.2197),
    CityEntity(name: 'Buôn Ma Thuột', province: 'Đắk Lắk', latitude: 12.6675, longitude: 108.0383),
    CityEntity(name: 'Quần đảo Hoàng Sa', province: 'TP. Đà Nẵng', latitude: 16.5333, longitude: 112.0333),
    CityEntity(name: 'Quần đảo Trường Sa', province: 'Tỉnh Khánh Hòa', latitude: 9.8833, longitude: 114.2500),
  ];
}
