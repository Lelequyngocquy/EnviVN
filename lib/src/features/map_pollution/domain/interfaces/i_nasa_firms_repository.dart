import '../../../../core/domain/entities/base.dart';
import '../../infrastructure/models/thermal_hotspot_model.dart';

abstract class INasaFirmsRepository {
  /// Lấy danh sách điểm phát xạ nhiệt / cháy sinh khối tại Việt Nam từ vệ tinh NASA FIRMS (NOAA-20 / NOAA-21).
  ///
  /// Cơ chế:
  /// - Kiểm tra cache cục bộ (TTL = 15 phút).
  /// - Nếu còn hạn: trả về cache (0ms, 0 tốn quota).
  /// - Nếu hết hạn: fetch API từ NASA FIRMS.
  /// - Nếu gặp lỗi mạng hoặc HTTP 429 (hết 5000 lượt/10p): tự động trả về cache cũ (stale cache).
  Future<BaseResult<List<ThermalHotspotModel>>> getVietnamActiveFires({
    bool forceRefresh = false,
  });

  /// Thời điểm cập nhật dữ liệu thành công gần nhất
  DateTime? getLastUpdateTime();

  /// Trạng thái đang hiển thị dữ liệu từ cache cũ (stale cache)
  bool get isServingCachedData;
}
