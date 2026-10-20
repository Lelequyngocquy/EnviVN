import 'package:envivn/src/common/utils/geo_distance_helper.dart';

/// Metadata tọa độ trung tâm các tỉnh thành và vùng lãnh thổ Việt Nam.
/// Dùng để đối chiếu và định vị địa danh khi phân tích dữ liệu tọa độ vệ tinh.
enum VietnamProvince {
  haNoi('Hà Nội', 21.0285, 105.8542),
  haiPhong('Hải Phòng', 20.8449, 106.6881),
  quangNinh('Quảng Ninh', 20.9505, 107.0734),
  langSon('Lạng Sơn', 21.8533, 106.7619),
  laoCai('Lào Cai', 22.4856, 103.9707),
  sonLa('Sơn La', 21.3283, 103.9144),
  thanhHoa('Thanh Hóa', 19.8067, 105.7852),
  ngheAn('Nghệ An', 18.6796, 105.6813),
  haTinh('Hà Tĩnh', 18.3559, 105.9059),
  quangBinh('Quảng Bình', 17.4739, 106.6000),
  quangTri('Quảng Trị', 16.8167, 107.1000),
  thuaThienHue('Thừa Thiên Huế', 16.4637, 107.5909),
  daNang('Đà Nẵng', 16.0544, 108.2022),
  quangNam('Quảng Nam', 15.5667, 108.4833),
  quangNgai('Quảng Ngãi', 15.1205, 108.7923),
  binhDinh('Bình Định', 13.7830, 109.2197),
  phuYen('Phú Yên', 13.0882, 109.3149),
  khanhHoa('Khánh Hòa', 12.2388, 109.1967),
  ninhThuan('Ninh Thuận', 11.5643, 108.9882),
  binhThuan('Bình Thuận', 10.9805, 108.2615),
  konTum('Kon Tum', 14.3545, 108.0076),
  giaLai('Gia Lai', 13.9833, 108.0000),
  dakLak('Đắk Lắk', 12.6667, 108.0500),
  dakNong('Đắk Nông', 12.0000, 107.6833),
  lamDong('Lâm Đồng', 11.9404, 108.4583),
  binhPhuoc('Bình Phước', 11.7500, 106.9000),
  tayNinh('Tây Ninh', 11.3100, 106.0983),
  binhDuong('Bình Dương', 11.1667, 106.6500),
  dongNai('Đồng Nai', 11.1000, 107.2000),
  baRiaVungTau('Bà Rịa - Vũng Tàu', 10.3460, 107.0843),
  hoChiMinh('TP. Hồ Chí Minh', 10.7769, 106.7009),
  longAn('Long An', 10.5333, 106.4000),
  tienGiang('Tiền Giang', 10.3667, 106.3667),
  benTre('Bến Tre', 10.2333, 106.3833),
  traVinh('Trà Vinh', 9.9333, 106.3500),
  vinhLong('Vĩnh Long', 10.2500, 105.9667),
  dongThap('Đồng Tháp', 10.4500, 105.6333),
  anGiang('An Giang', 10.3833, 105.4167),
  kienGiang('Kiên Giang', 10.0167, 105.0833),
  canTho('Cần Thơ', 10.0452, 105.7469),
  hauGiang('Hậu Giang', 9.7833, 105.4667),
  socTrang('Sóc Trăng', 9.6000, 105.9667),
  bacLieu('Bạc Liêu', 9.2833, 105.7167),
  caMau('Cà Mau', 9.1769, 105.1500);

  final String provinceName;
  final double latitude;
  final double longitude;

  const VietnamProvince(this.provinceName, this.latitude, this.longitude);

  /// Bounding box toàn lãnh thổ Việt Nam [West, South, East, North]
  static const String vietnamBoundingBox = '102.1,8.3,114.5,23.4';

  /// Tìm tỉnh thành gần nhất so với tọa độ cho trước (km)
  static ({VietnamProvince province, double distanceKm}) findClosest(
    double lat,
    double lon,
  ) {
    VietnamProvince closest = VietnamProvince.haNoi;
    double minD = double.infinity;

    for (final p in VietnamProvince.values) {
      final d = GeoDistanceHelper.distanceInKm(lat, lon, p.latitude, p.longitude);
      if (d < minD) {
        minD = d;
        closest = p;
      }
    }

    return (province: closest, distanceKm: minD);
  }
}
