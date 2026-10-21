import 'dart:convert';

import '../../../../common/utils/geo_distance_helper.dart';
import '../../domain/entities/vietnam_province.dart';

/// Mô hình dữ liệu Điểm nhiệt độ cao / Cháy sinh khối từ vệ tinh NASA FIRMS (NOAA-20/21 VIIRS).
/// Đảm nhiệm toàn bộ việc serialize JSON và bóc tách dữ liệu CSV từ tầng hạ tầng (Infrastructure).
class ThermalHotspotModel {
  final String id;
  final String locationName;
  final String province;
  final double latitude;
  final double longitude;
  final double brightnessKelvin; // Nhiệt độ bức xạ vệ tinh (Kelvin)
  final String fireType; // Loại hình cháy / phát xạ nhiệt
  final double confidence; // Độ tin cậy cảm biến vệ tinh (%)
  final bool isActiveFire; // TRUE: Tín hiệu phát xạ nhiệt thời gian thực; FALSE: Vùng biến động nhiệt chu kỳ
  final String proneSeason; // Khoảng thời gian / mùa thường có biến động nhiệt cao
  final String? detectedTime; // Thời điểm vệ tinh quét phát hiện
  final String description; // Mô tả thực địa

  const ThermalHotspotModel({
    required this.id,
    required this.locationName,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.brightnessKelvin,
    required this.fireType,
    required this.confidence,
    required this.isActiveFire,
    required this.proneSeason,
    this.detectedTime,
    required this.description,
  });

  /// Chuyển đổi nhiệt Kelvin sang độ C
  double get brightnessCelsius => brightnessKelvin - 273.15;

  Map<String, dynamic> toJson() => {
        'id': id,
        'locationName': locationName,
        'province': province,
        'latitude': latitude,
        'longitude': longitude,
        'brightnessKelvin': brightnessKelvin,
        'fireType': fireType,
        'confidence': confidence,
        'isActiveFire': isActiveFire,
        'proneSeason': proneSeason,
        'detectedTime': detectedTime,
        'description': description,
      };

  factory ThermalHotspotModel.fromJson(Map<String, dynamic> json) {
    return ThermalHotspotModel(
      id: json['id'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      province: json['province'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      brightnessKelvin: (json['brightnessKelvin'] as num?)?.toDouble() ?? 300.0,
      fireType: json['fireType'] as String? ?? 'Điểm nhiệt vệ tinh',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 80.0,
      isActiveFire: json['isActiveFire'] as bool? ?? true,
      proneSeason: json['proneSeason'] as String? ?? '',
      detectedTime: json['detectedTime'] as String?,
      description: json['description'] as String? ?? '',
    );
  }

  /// Parse dữ liệu thô CSV từ Area API của NASA FIRMS (VIIRS NOAA-20/21)
  static List<ThermalHotspotModel> fromCsv(String csvText) {
    final lines = const LineSplitter().convert(csvText);
    if (lines.length <= 1) return [];

    final List<ThermalHotspotModel> list = [];

    // Header chuẩn: latitude,longitude,bright_ti4,scan,track,acq_date,acq_time,satellite,instrument,confidence,version,bright_ti5,frp,daynight
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (parts.length < 13) continue;

      final lat = double.tryParse(parts[0]);
      final lon = double.tryParse(parts[1]);
      final brightTi4 = double.tryParse(parts[2]); // Kelvin
      final acqDate = parts[5];
      final acqTime = parts[6];
      final confStr = parts[9].toLowerCase().trim();
      final frp = double.tryParse(parts[12]) ?? 0.0; // Fire Radiative Power (MW)

      if (lat == null || lon == null || brightTi4 == null) continue;

      // Độ tin cậy (%)
      double confidence = 80.0;
      if (confStr == 'h') {
        confidence = 95.0;
      } else if (confStr == 'n') {
        confidence = 80.0;
      } else if (confStr == 'l') {
        confidence = 50.0;
      } else {
        confidence = double.tryParse(confStr) ?? 80.0;
      }

      // Xác định tỉnh thành Việt Nam gần nhất
      final closest = VietnamProvince.findClosest(lat, lon);
      final provinceName = closest.province.provinceName;
      final distKm = closest.distanceKm;

      final locationName = distKm < 15.0
          ? 'Khu vực $provinceName'
          : 'Cách $provinceName ${GeoDistanceHelper.formatDistance(distKm)}';

      // Định dạng ngày giờ quét vệ tinh theo múi giờ Việt Nam (UTC+7)
      final detectedTimeStr = _formatAcqDateTime(acqDate, acqTime);

      final fireType = _determineFireType(provinceName, frp);
      final desc = frp >= 20.0
          ? 'Tín hiệu phát xạ nhiệt tăng cao (${frp.toStringAsFixed(1)} MW) • Phát hiện bởi vệ tinh NOAA-20 (VIIRS 375m)'
          : 'Ghi nhận tín hiệu nhiệt bề mặt (${frp.toStringAsFixed(1)} MW) • Phát hiện bởi vệ tinh NOAA-20 (VIIRS 375m)';

      list.add(
        ThermalHotspotModel(
          id: 'nasa_viirs_${acqDate}_${acqTime}_${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}',
          locationName: locationName,
          province: provinceName,
          latitude: lat,
          longitude: lon,
          brightnessKelvin: brightTi4,
          fireType: fireType,
          confidence: confidence,
          isActiveFire: true,
          proneSeason: 'Dữ liệu vệ tinh thời gian thực (NOAA-20 VIIRS)',
          detectedTime: detectedTimeStr,
          description: desc,
        ),
      );
    }

    // Ưu tiên hiển thị các điểm có nhiệt độ bức xạ cao nhất
    list.sort((a, b) => b.brightnessKelvin.compareTo(a.brightnessKelvin));

    // Giới hạn 75 điểm tiêu biểu để tối ưu hiệu năng bản đồ
    if (list.length > 75) {
      return list.sublist(0, 75);
    }

    return list;
  }

  static String _formatAcqDateTime(String acqDate, String acqTime) {
    try {
      final dateParts = acqDate.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final paddedTime = acqTime.padLeft(4, '0');
      final hour = int.parse(paddedTime.substring(0, 2));
      final minute = int.parse(paddedTime.substring(2, 4));

      final utc = DateTime.utc(year, month, day, hour, minute);
      final vnTime = utc.add(const Duration(hours: 7)); // UTC+7

      final dStr = vnTime.day.toString().padLeft(2, '0');
      final mStr = vnTime.month.toString().padLeft(2, '0');
      final hStr = vnTime.hour.toString().padLeft(2, '0');
      final minStr = vnTime.minute.toString().padLeft(2, '0');

      return '$dStr/$mStr lúc $hStr:$minStr (Vệ tinh NOAA-20 quét)';
    } catch (_) {
      return '$acqDate $acqTime (UTC)';
    }
  }

  static String _determineFireType(String province, double frp) {
    final norm = province.toLowerCase();
    final isDelta = norm.contains('đồng tháp') ||
        norm.contains('an giang') ||
        norm.contains('cần thơ') ||
        norm.contains('kiên giang') ||
        norm.contains('long an') ||
        norm.contains('hà nội') ||
        norm.contains('hưng yên');

    if (isDelta) {
      return frp >= 20.0
          ? 'Điểm phát xạ nhiệt ở vùng đồng bằng (công suất cao)'
          : 'Điểm nhiệt bề mặt ở vùng đồng bằng';
    }

    final isHighland = norm.contains('gia lai') ||
        norm.contains('kon tum') ||
        norm.contains('đắk lắk') ||
        norm.contains('lâm đồng') ||
        norm.contains('sơn la') ||
        norm.contains('bình phước');

    if (isHighland) {
      return frp >= 20.0
          ? 'Điểm phát xạ nhiệt ở vùng cao (công suất cao)'
          : 'Điểm nhiệt bề mặt ở vùng cao';
    }

    return frp >= 20.0
        ? 'Điểm phát xạ nhiệt bề mặt quy mô lớn'
        : 'Điểm nhiệt bề mặt ghi nhận từ vệ tinh';
  }

  /// Danh mục điểm phát xạ nhiệt hoạt động và các vùng ghi nhận dao động nhiệt theo chu kỳ tại Việt Nam
  static const List<ThermalHotspotModel> sampleHotspots = [
    // -------------------------------------------------------------------------
    // 1. CÁC ĐIỂM CÓ TÍN HIỆU PHÁT XẠ NHIỆT VỆ TINH PHÁT HIỆN GẦN ĐÂY
    // -------------------------------------------------------------------------
    ThermalHotspotModel(
      id: 'fire_gl_01',
      locationName: 'Khu vực đồi núi Ia Grai',
      province: 'Gia Lai',
      latitude: 14.0250,
      longitude: 107.8200,
      brightnessKelvin: 348.6, // ~75.5°C nhiệt bức xạ
      fireType: 'Điểm phát xạ nhiệt ở vùng cao',
      confidence: 94,
      isActiveFire: true,
      detectedTime: 'Vệ tinh VIIRS phát hiện lúc 08:30 sáng nay',
      proneSeason: 'Thời kỳ khô hạn ở vùng cao (Tháng 12 - Tháng 4)',
      description: 'Vệ tinh ghi nhận tín hiệu phát xạ nhiệt tăng cao ở khu vực độ cao, cần theo dõi thêm từ thực địa.',
    ),
    ThermalHotspotModel(
      id: 'fire_dt_01',
      locationName: 'Khu vực đồng bằng Tam Nông',
      province: 'Đồng Tháp',
      latitude: 10.6800,
      longitude: 105.5200,
      brightnessKelvin: 338.5, // ~65.4°C nhiệt bức xạ
      fireType: 'Điểm phát xạ nhiệt ở vùng đồng bằng',
      confidence: 88,
      isActiveFire: true,
      detectedTime: 'Vệ tinh Terra/MODIS quét cách đây 1.5 giờ',
      proneSeason: 'Thời điểm thu hoạch mùa vụ (Tháng 3 - Tháng 4 & Tháng 8 - Tháng 9)',
      description: 'Vệ tinh ghi nhận nguồn nhiệt bề mặt cục bộ tại khu vực đồng bằng canh tác nông nghiệp.',
    ),

    // -------------------------------------------------------------------------
    // 2. VÙNG GHI NHẬN BIẾN ĐỘNG NHIỆT ĐỊNH KỲ / MÙA VỤ (Hiện tại bình thường)
    // -------------------------------------------------------------------------
    ThermalHotspotModel(
      id: 'fire_hn_01',
      locationName: 'Khu vực ven đô Sóc Sơn',
      province: 'Hà Nội',
      latitude: 21.2650,
      longitude: 105.8500,
      brightnessKelvin: 304.5,
      fireType: 'Vùng có biến động nhiệt bề mặt theo mùa',
      confidence: 85,
      isActiveFire: false,
      proneSeason: 'Giai đoạn sau thu hoạch mùa vụ (Tháng 5 - Tháng 6 & Tháng 10 - Tháng 11)',
      description: 'Khu vực đồng bằng thường ghi nhận biến động phát xạ nhiệt bề mặt theo chu kỳ mùa vụ.',
    ),
    ThermalHotspotModel(
      id: 'fire_hn_02',
      locationName: 'Khu vực ven đô Mê Linh',
      province: 'Hà Nội',
      latitude: 21.1750,
      longitude: 105.7150,
      brightnessKelvin: 303.8,
      fireType: 'Vùng có biến động nhiệt bề mặt theo mùa',
      confidence: 82,
      isActiveFire: false,
      proneSeason: 'Tháng 5 - Tháng 6 & Tháng 10 - Tháng 11',
      description: 'Khu vực đồng bằng nông nghiệp ghi nhận dao động nhiệt độ bề mặt định kỳ.',
    ),
    ThermalHotspotModel(
      id: 'fire_hy_01',
      locationName: 'Khu vực bãi bồi Văn Giang',
      province: 'Hưng Yên',
      latitude: 20.9250,
      longitude: 105.9550,
      brightnessKelvin: 303.2,
      fireType: 'Vùng có dao động nhiệt cục bộ',
      confidence: 78,
      isActiveFire: false,
      proneSeason: 'Tháng 11 - Tháng 1 & Tháng 5 - Tháng 6',
      description: 'Khu vực bãi bồi phù sa ven sông có ghi nhận dao động nhiệt bề mặt trong năm.',
    ),
    ThermalHotspotModel(
      id: 'fire_kg_01',
      locationName: 'Vùng trũng sinh thái U Minh Thượng',
      province: 'Kiên Giang',
      latitude: 9.8050,
      longitude: 105.0850,
      brightnessKelvin: 306.0,
      fireType: 'Vùng có chỉ số nhiệt nền cần theo dõi',
      confidence: 91,
      isActiveFire: false,
      proneSeason: 'Thời kỳ khô hạn kéo dài (Tháng 2 - Tháng 5)',
      description: 'Khu vực địa hình đất than bùn có độ ẩm nền thấp, cần theo dõi biến động nhiệt trong mùa khô.',
    ),
    ThermalHotspotModel(
      id: 'fire_ct_01',
      locationName: 'Khu vực đồng bằng Cờ Đỏ',
      province: 'Cần Thơ',
      latitude: 10.1200,
      longitude: 105.4500,
      brightnessKelvin: 304.0,
      fireType: 'Vùng có dao động nhiệt theo chu kỳ canh tác',
      confidence: 80,
      isActiveFire: false,
      proneSeason: 'Các đợt sau thu hoạch nông nghiệp (Tháng 3, Tháng 7, Tháng 11)',
      description: 'Khu vực đồng bằng canh tác tập trung có dao động nhiệt độ bề mặt theo chu kỳ sản xuất.',
    ),
  ];
}

/// Alias thuận tiện để tương thích ngược nếu cần
typedef ThermalHotspot = ThermalHotspotModel;
