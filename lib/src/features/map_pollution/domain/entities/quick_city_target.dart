import 'package:envivn/src/common/utils/geo_distance_helper.dart';

/// Đại diện cho các điểm định vị nhanh (tỉnh/thành phố hoặc toàn quốc)
/// trên bản đồ ô nhiễm không khí EnviVN.
/// Đóng vai trò là Single Source of Truth cho các thành phố được gợi ý.
enum QuickCityTarget {
  allVietnam(
    label: 'Toàn quốc',
    queryName: 'Toàn quốc',
    latitude: 16.0544,
    longitude: 108.2022,
    zoom: 5.8,
    isAllCountry: true,
    aliases: ['toàn quốc', 'toanquoc', 'vietnam', 'việt nam'],
  ),
  hanoi(
    label: 'Hà Nội',
    queryName: 'Hà Nội',
    latitude: 21.0285,
    longitude: 105.8542,
    zoom: 11.5,
    aliases: ['hà nội', 'hanoi', 'hoàn kiếm', 'hoan kiem', 'thủ đô'],
  ),
  daNang(
    label: 'Đà Nẵng',
    queryName: 'Đà Nẵng',
    latitude: 16.0544,
    longitude: 108.2022,
    zoom: 11.5,
    aliases: ['đà nẵng', 'da nang', 'hải châu', 'hai chau', 'sơn trà'],
  ),
  hoChiMinh(
    label: 'TP. Hồ Chí Minh',
    queryName: 'Hồ Chí Minh',
    latitude: 10.7769,
    longitude: 106.7009,
    zoom: 11.5,
    aliases: [
      'hồ chí minh',
      'ho chi minh',
      'hcm',
      'sài gòn',
      'sai gon',
      'quận 1',
      'tp.hcm',
      'tphcm',
    ],
  ),
  haiPhong(
    label: 'Hải Phòng',
    queryName: 'Hải Phòng',
    latitude: 20.8449,
    longitude: 106.6881,
    zoom: 11.5,
    aliases: ['hải phòng', 'hai phong', 'hồng bàng', 'đất cảng'],
  ),
  canTho(
    label: 'Cần Thơ',
    queryName: 'Cần Thơ',
    latitude: 10.0452,
    longitude: 105.7469,
    zoom: 11.5,
    aliases: ['cần thơ', 'can tho', 'ninh kiều', 'tây đô'],
  ),
  hue(
    label: 'Huế',
    queryName: 'Huế',
    latitude: 16.4637,
    longitude: 107.5909,
    zoom: 11.5,
    aliases: ['huế', 'hue', 'thừa thiên huế', 'thua thien hue', 'cố đô'],
  ),
  nhaTrang(
    label: 'Nha Trang',
    queryName: 'Nha Trang',
    latitude: 12.2388,
    longitude: 109.1967,
    zoom: 11.5,
    aliases: ['nha trang', 'khánh hòa', 'khanh hoa'],
  ),
  daLat(
    label: 'Đà Lạt',
    queryName: 'Đà Lạt',
    latitude: 11.9404,
    longitude: 108.4583,
    zoom: 11.5,
    aliases: ['đà lạt', 'da lat', 'lâm đồng', 'lam dong', 'xứ ngàn hoa'],
  ),
  quangNinh(
    label: 'Quảng Ninh',
    queryName: 'Quảng Ninh',
    latitude: 20.9505,
    longitude: 107.0734,
    zoom: 11.5,
    aliases: ['quảng ninh', 'quang ninh', 'hạ long', 'ha long'],
  ),
  vungTau(
    label: 'Vũng Tàu',
    queryName: 'Vũng Tàu',
    latitude: 10.3460,
    longitude: 107.0843,
    zoom: 11.5,
    aliases: ['vũng tàu', 'vung tau', 'bà rịa', 'bà rịa - vũng tàu', 'ba ria'],
  ),
  hoangSa(
    label: 'Hoàng Sa',
    queryName: 'Quần đảo Hoàng Sa',
    latitude: 16.5333,
    longitude: 112.0333,
    zoom: 10.0,
    aliases: [
      'hoàng sa',
      'hoang sa',
      'quần đảo hoàng sa',
      'quan dao hoang sa',
      'huyện đảo hoàng sa',
    ],
  ),
  truongSa(
    label: 'Trường Sa',
    queryName: 'Quần đảo Trường Sa',
    latitude: 9.8833,
    longitude: 114.2500,
    zoom: 9.5,
    aliases: [
      'trường sa',
      'truong sa',
      'quần đảo trường sa',
      'quan dao truong sa',
      'huyện đảo trường sa',
      'đảo trường sa lớn',
    ],
  );

  final String label;
  final String queryName;
  final double latitude;
  final double longitude;
  final double zoom;
  final bool isAllCountry;
  final List<String> aliases;

  const QuickCityTarget({
    required this.label,
    required this.queryName,
    required this.latitude,
    required this.longitude,
    this.zoom = 11.5,
    this.isAllCountry = false,
    this.aliases = const [],
  });

  /// Chuẩn hóa chuỗi tìm kiếm thông qua Single Source of Truth
  static String _normalize(String input) => GeoDistanceHelper.normalize(input);

  /// Kiểm tra xem một chuỗi truy vấn hoặc tên địa danh có khớp với thành phố này hay không
  bool matchesQuery(String input) {
    if (input.isEmpty) return false;
    final norm = _normalize(input);
    if (norm.isEmpty) return false;

    if (isAllCountry) {
      return norm == 'toàn quốc' ||
          norm == 'toanquoc' ||
          norm == 'vietnam' ||
          norm == 'việt nam';
    }

    final q = _normalize(queryName);
    final l = _normalize(label);

    if (norm == q ||
        norm == l ||
        norm.contains(q) ||
        q.contains(norm) ||
        norm.contains(l)) {
      return true;
    }

    for (final alias in aliases) {
      final a = _normalize(alias);
      if (norm == a || norm.contains(a) || a.contains(norm)) {
        return true;
      }
    }
    return false;
  }

  /// Kiểm tra xem một trạm quan trắc trên bản đồ có thuộc về thành phố này hay không
  /// dựa trên tọa độ thực tế (bán kính đô thị <= 35km) hoặc tên trạm / tỉnh thành
  bool matchesStation({
    required String name,
    required String province,
    required double lat,
    required double lon,
  }) {
    if (isAllCountry) return false;

    final normName = GeoDistanceHelper.normalizeName(name);
    final isHs = normName.contains('hoàng sa') || normName.contains('hoang sa');
    final isTs = normName.contains('trường sa') || normName.contains('truong sa');

    // Quần đảo Hoàng Sa và Trường Sa là các thực thể độc lập trên bản đồ EnviVN
    // Tránh bị gom nhầm vào TP. Đà Nẵng hoặc Tỉnh Khánh Hòa về mặt địa lý/hành chính
    if (isHs) return this == QuickCityTarget.hoangSa;
    if (isTs) return this == QuickCityTarget.truongSa;

    // Hoàng Sa và Trường Sa trên biển không nhận các trạm đất liền
    if (this == QuickCityTarget.hoangSa || this == QuickCityTarget.truongSa) {
      return GeoDistanceHelper.distanceInKm(latitude, longitude, lat, lon) <= 150.0;
    }

    // 1. Kiểm tra khoảng cách địa lý thực tế (nằm trong phạm vi đô thị <= 35km)
    if (GeoDistanceHelper.distanceInKm(latitude, longitude, lat, lon) <= 35.0) {
      return true;
    }

    // 2. Kiểm tra theo tên tỉnh hoặc tên trạm
    if (matchesQuery(province) || matchesQuery(name)) {
      return true;
    }

    return false;
  }

  /// Kiểm tra xem địa điểm này có đang được chọn/hiển thị hay không
  bool isSelected(String? currentSelectedName) {
    if (currentSelectedName == null || currentSelectedName.isEmpty) {
      return false;
    }
    return matchesQuery(currentSelectedName);
  }

  /// Kiểm tra xem địa điểm này có trùng với vị trí đã được ghim (Home / Vị trí hiện tại) hay không
  bool matchesPinnedLocation(String? pinnedLocationName) {
    if (pinnedLocationName == null || pinnedLocationName.isEmpty) return false;
    if (isAllCountry) return false;
    return matchesQuery(pinnedLocationName);
  }

  /// Tìm QuickCityTarget phù hợp với chuỗi truy vấn (Single Source of Truth)
  static QuickCityTarget? findByQuery(String query) {
    for (final target in QuickCityTarget.values) {
      if (!target.isAllCountry && target.matchesQuery(query)) {
        return target;
      }
    }
    return null;
  }

  /// Tìm QuickCityTarget phù hợp với thông tin trạm quan trắc (Single Source of Truth)
  static QuickCityTarget? findForStation({
    required String name,
    required String province,
    required double lat,
    required double lon,
  }) {
    for (final target in QuickCityTarget.values) {
      if (!target.isAllCountry &&
          target.matchesStation(
            name: name,
            province: province,
            lat: lat,
            lon: lon,
          )) {
        return target;
      }
    }
    return null;
  }
}
