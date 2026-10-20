import 'dart:math' as math;

/// Tiện ích tính toán khoảng cách và chuẩn hóa tọa độ địa lý.
/// Đóng vai trò Single Source of Truth cho công thức Haversine trên toàn dự án EnviVN.
class GeoDistanceHelper {
  GeoDistanceHelper._();

  /// Tính khoảng cách giữa hai tọa độ địa lý theo công thức Haversine (km).
  static double distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Chuẩn hóa hiển thị khoảng cách thân thiện cho người dùng:
  /// - Dưới 10km: lấy 1 chữ số thập phân (ví dụ ~3.4km, ~0.5km)
  /// - Từ 10km trở lên: làm tròn số nguyên (ví dụ ~25km, ~140km)
  static String formatDistance(double km) {
    if (!km.isFinite || km < 0) return '';
    if (km < 10.0) {
      final val = km < 0.1 ? 0.1 : km;
      return '~${val.toStringAsFixed(1)}km';
    }
    return '~${km.round()}km';
  }

  /// Chuẩn hóa chuỗi tên địa phương để phục vụ tìm kiếm/so sánh:
  /// Chuyển chữ thường, bỏ tiền tố "tp.", "thành phố", "tỉnh", "trạm"...
  static String normalizeLocationName(String input) {
    return input
        .toLowerCase()
        .replaceAll('tp.', '')
        .replaceAll('thành phố', '')
        .replaceAll('tỉnh', '')
        .replaceAll('trạm', '')
        .trim();
  }

  /// Alias tiện lợi
  static String normalizeName(String input) => normalizeLocationName(input);
  static String normalize(String input) => normalizeLocationName(input);
}
