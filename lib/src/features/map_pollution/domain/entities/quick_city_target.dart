/// Đại diện cho các điểm định vị nhanh (tỉnh/thành phố hoặc toàn quốc)
/// trên bản đồ ô nhiễm không khí EnviVN.
enum QuickCityTarget {
  allVietnam(
    label: 'Toàn quốc',
    queryName: 'Toàn quốc',
    latitude: 16.0544,
    longitude: 108.2022,
    zoom: 5.8,
    isAllCountry: true,
  ),
  hanoi(
    label: 'Hà Nội',
    queryName: 'Hà Nội',
    latitude: 21.0285,
    longitude: 105.8542,
    zoom: 11.5,
  ),
  daNang(
    label: 'Đà Nẵng',
    queryName: 'Đà Nẵng',
    latitude: 16.0544,
    longitude: 108.2022,
    zoom: 11.5,
  ),
  hoChiMinh(
    label: 'TP. Hồ Chí Minh',
    queryName: 'Hồ Chí Minh',
    latitude: 10.7769,
    longitude: 106.7009,
    zoom: 11.5,
  ),
  haiPhong(
    label: 'Hải Phòng',
    queryName: 'Hải Phòng',
    latitude: 20.8449,
    longitude: 106.6881,
    zoom: 11.5,
  ),
  canTho(
    label: 'Cần Thơ',
    queryName: 'Cần Thơ',
    latitude: 10.0452,
    longitude: 105.7469,
    zoom: 11.5,
  ),
  hue(
    label: 'Huế',
    queryName: 'Huế',
    latitude: 16.4637,
    longitude: 107.5909,
    zoom: 11.5,
  ),
  nhaTrang(
    label: 'Nha Trang',
    queryName: 'Nha Trang',
    latitude: 12.2388,
    longitude: 109.1967,
    zoom: 11.5,
  ),
  daLat(
    label: 'Đà Lạt',
    queryName: 'Đà Lạt',
    latitude: 11.9404,
    longitude: 108.4583,
    zoom: 11.5,
  ),
  quangNinh(
    label: 'Quảng Ninh',
    queryName: 'Quảng Ninh',
    latitude: 20.9505,
    longitude: 107.0734,
    zoom: 11.5,
  ),
  vungTau(
    label: 'Vũng Tàu',
    queryName: 'Vũng Tàu',
    latitude: 10.3460,
    longitude: 107.0843,
    zoom: 11.5,
  );

  final String label;
  final String queryName;
  final double latitude;
  final double longitude;
  final double zoom;
  final bool isAllCountry;

  const QuickCityTarget({
    required this.label,
    required this.queryName,
    required this.latitude,
    required this.longitude,
    this.zoom = 11.5,
    this.isAllCountry = false,
  });

  /// Kiểm tra xem địa điểm này có đang được chọn/hiển thị hay không
  bool isSelected(String? currentSelectedName) {
    if (currentSelectedName == null || currentSelectedName.isEmpty) return false;
    final cur = currentSelectedName.toLowerCase();
    if (isAllCountry) {
      return cur == 'toàn quốc' || cur == 'toanquoc';
    }
    final q = queryName.toLowerCase();
    if (this == hoChiMinh) {
      return cur.contains('hồ chí minh') ||
          cur.contains('hcm') ||
          cur.contains('quận 1') ||
          cur.contains('sài gòn');
    }
    return cur.contains(q) || q.contains(cur);
  }

  /// Kiểm tra xem địa điểm này có trùng với vị trí đã được ghim (Home / Vị trí hiện tại) hay không
  bool matchesPinnedLocation(String? pinnedLocationName) {
    if (pinnedLocationName == null || pinnedLocationName.isEmpty) return false;
    if (isAllCountry) return false;
    final lower = pinnedLocationName.toLowerCase();
    final q = queryName.toLowerCase();
    final l = label.toLowerCase();
    return isSelected(lower) || lower.contains(q) || lower.contains(l);
  }
}
