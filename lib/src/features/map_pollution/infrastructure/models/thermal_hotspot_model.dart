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
  final bool isActiveFire; // TRUE: Đám cháy đang hoạt động; FALSE: Điểm nóng theo mùa vụ
  final String proneSeason; // Khoảng thời gian / mùa thường xảy ra cháy
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
          ? 'Bức xạ nhiệt mạnh (${frp.toStringAsFixed(1)} MW) • Phát hiện bởi vệ tinh NOAA-20 (VIIRS 375m)'
          : 'Bức xạ nhiệt (${frp.toStringAsFixed(1)} MW) • Phát hiện bởi vệ tinh NOAA-20 (VIIRS 375m)';

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
          ? 'Đốt đồng / Rơm rạ quy mô lớn'
          : 'Đốt phế phẩm nông nghiệp / Rơm rạ';
    }

    final isHighland = norm.contains('gia lai') ||
        norm.contains('kon tum') ||
        norm.contains('đắk lắk') ||
        norm.contains('lâm đồng') ||
        norm.contains('sơn la') ||
        norm.contains('bình phước');

    if (isHighland) {
      return frp >= 20.0
          ? 'Cháy rừng thực bì / Nương rẫy mạnh'
          : 'Cháy thực bì đồi núi / Nương rẫy';
    }

    return frp >= 20.0
        ? 'Điểm phát xạ nhiệt bề mặt lớn'
        : 'Điểm nhiệt bề mặt vệ tinh';
  }

  /// Danh mục điểm cháy hoạt động và các vùng trọng điểm thường xảy ra cháy tại Việt Nam
  static const List<ThermalHotspotModel> sampleHotspots = [
    // -------------------------------------------------------------------------
    // 1. CÁC ĐIỂM ĐANG CÓ ĐÁM CHÁY HOẠT ĐỘNG THỰC TẾ (Vệ tinh phát hiện gần đây)
    // -------------------------------------------------------------------------
    ThermalHotspotModel(
      id: 'fire_gl_01',
      locationName: 'Rừng khộp Ia Grai',
      province: 'Gia Lai',
      latitude: 14.0250,
      longitude: 107.8200,
      brightnessKelvin: 348.6, // ~75.5°C nhiệt bức xạ
      fireType: 'Cháy rừng thực bì mùa khô',
      confidence: 94,
      isActiveFire: true,
      detectedTime: 'Vệ tinh VIIRS phát hiện lúc 08:30 sáng nay',
      proneSeason: 'Cao điểm mùa khô Tây Nguyên (Tháng 12 - Tháng 4)',
      description: 'Đang có đám cháy bốc khói tại thung lũng rừng khộp rụng lá, gió quẩn cấp 4-5',
    ),
    ThermalHotspotModel(
      id: 'fire_dt_01',
      locationName: 'Cánh đồng Tam Nông',
      province: 'Đồng Tháp',
      latitude: 10.6800,
      longitude: 105.5200,
      brightnessKelvin: 338.5, // ~65.4°C nhiệt bức xạ
      fireType: 'Đốt đồng sau thu hoạch vụ lúa',
      confidence: 88,
      isActiveFire: true,
      detectedTime: 'Vệ tinh Terra/MODIS quét cách đây 1.5 giờ',
      proneSeason: 'Mùa thu hoạch lúa (Tháng 3 - Tháng 4 & Tháng 8 - Tháng 9)',
      description: 'Nông dân đang đồng loạt đốt gốc rạ trên diện tích lớn, khói lan tỏa theo hướng gió',
    ),

    // -------------------------------------------------------------------------
    // 2. NƠI THƯỜNG HAY XẢY RA CHÁY / ĐIỂM NÓNG THEO MÙA VỤ (Hiện tại an toàn)
    // -------------------------------------------------------------------------
    ThermalHotspotModel(
      id: 'fire_hn_01',
      locationName: 'Cánh đồng Sóc Sơn',
      province: 'Hà Nội',
      latitude: 21.2650,
      longitude: 105.8500,
      brightnessKelvin: 304.5,
      fireType: 'Điểm nóng đốt rơm rạ ngoại thành',
      confidence: 85,
      isActiveFire: false,
      proneSeason: 'Sau vụ gặt lúa Xuân (Tháng 5 - Tháng 6) & vụ Mùa (Tháng 10 - Tháng 11)',
      description: 'Vùng canh tác lúa lớn, thường có thói quen đốt rơm rạ sau mùa gặt lúc chiều muộn',
    ),
    ThermalHotspotModel(
      id: 'fire_hn_02',
      locationName: 'Cánh đồng Mê Linh',
      province: 'Hà Nội',
      latitude: 21.1750,
      longitude: 105.7150,
      brightnessKelvin: 303.8,
      fireType: 'Vùng thường đốt phế phẩm nông nghiệp',
      confidence: 82,
      isActiveFire: false,
      proneSeason: 'Tháng 5 - Tháng 6 & Tháng 10 - Tháng 11',
      description: 'Vùng hoa màu và lúa trũng, khói đốt rơm rạ thường gây mù quang hóa vào nội thành',
    ),
    ThermalHotspotModel(
      id: 'fire_hy_01',
      locationName: 'Vùng bãi bồi Văn Giang',
      province: 'Hưng Yên',
      latitude: 20.9250,
      longitude: 105.9550,
      brightnessKelvin: 303.2,
      fireType: 'Vùng thường đốt cành khô & dọn vườn',
      confidence: 78,
      isActiveFire: false,
      proneSeason: 'Tháng 11 - Tháng 1 (Dọn vườn cây cảnh tết) & Tháng 5 - 6',
      description: 'Vùng bãi sông Hồng trồng quất, bưởi cảnh; thường gom đốt phế phẩm sau cắt tỉa',
    ),
    ThermalHotspotModel(
      id: 'fire_kg_01',
      locationName: 'Rừng tràm U Minh Thượng',
      province: 'Kiên Giang',
      latitude: 9.8050,
      longitude: 105.0850,
      brightnessKelvin: 306.0,
      fireType: 'Vùng nguy cơ cháy rừng than bùn cấp cao',
      confidence: 91,
      isActiveFire: false,
      proneSeason: 'Mùa khô hạn kéo dài (Tháng 2 - Tháng 5)',
      description: 'Địa hình lớp than bùn dày, nguy cơ cháy âm ỉ dưới lòng đất khi mực nước ngầm tụt sâu',
    ),
    ThermalHotspotModel(
      id: 'fire_ct_01',
      locationName: 'Cánh đồng Cờ Đỏ',
      province: 'Cần Thơ',
      latitude: 10.1200,
      longitude: 105.4500,
      brightnessKelvin: 304.0,
      fireType: 'Vùng thâm canh lúa thường đốt gốc rạ',
      confidence: 80,
      isActiveFire: false,
      proneSeason: 'Các đợt thu hoạch lúa rộ (Tháng 3, Tháng 7, Tháng 11)',
      description: 'Vùng trồng lúa xuất khẩu quy mô lớn, nông dân thường đốt đồng để chuẩn bị đất gieo sạ mới',
    ),
  ];
}

/// Alias thuận tiện để tương thích ngược nếu cần
typedef ThermalHotspot = ThermalHotspotModel;
