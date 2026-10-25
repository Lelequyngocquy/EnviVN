import 'package:intl/intl.dart';

import '../../domain/entities/app_location_entity.dart';
import '../../../features/air_quality/domain/entities/air_quality_entity.dart';
import '../../../features/details/domain/entities/details_entity.dart';

class ContextPromptBuilder {
  static const List<String> defaultSuggestedQuestions = [
    'Thời tiết và chất lượng không khí này có thích hợp chạy bộ ngoài trời không?',
    'Chỉ số bụi mịn hiện tại có ảnh hưởng gì đến trẻ nhỏ và người già không?',
    'Với lượng mưa hiện tại, khu vực này có nguy cơ ngập úng không?',
    'Tôi cần chuẩn bị trang phục và biện pháp bảo vệ gì khi ra ngoài bây giờ?',
  ];

  static String getAqiCategory(int aqi) {
    if (aqi <= 50) return 'Tốt (Trong lành)';
    if (aqi <= 100) return 'Trung bình (Chấp nhận được)';
    if (aqi <= 150) return 'Kém (Nhạy cảm cần chú ý)';
    if (aqi <= 200) return 'Xấu (Không lành mạnh)';
    if (aqi <= 300) return 'Rất xấu (Rất nguy hại)';
    return 'Nguy hại (Khẩn cấp)';
  }

  static String getFloodRisk(double precipitation) {
    if (precipitation >= 50.0) {
      return 'Rất cao (Nguy cơ ngập sâu diện rộng)';
    }
    if (precipitation >= 20.0) {
      return 'Cao (Nguy cơ ngập cục bộ vùng trũng)';
    }
    if (precipitation >= 5.0) {
      return 'Trung bình (Có khả năng đọng nước cục bộ)';
    }
    return 'Thấp (Không đáng kể)';
  }

  static String buildSystemPrompt({
    required AppLocationEntity location,
    required DetailsEntity weather,
    required AirQualityEntity airQuality,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final timeStr = DateFormat('dd/MM/yyyy HH:mm').format(now);
    final aqi = airQuality.usAqi > 0
        ? airQuality.usAqi
        : (airQuality.europeanAqi > 0 ? airQuality.europeanAqi : 50);
    final aqiCat = getAqiCategory(aqi);
    final floodRisk = getFloodRisk(weather.precipitation);

    final latStr = location.latitude.toStringAsFixed(4);
    final lonStr = location.longitude.toStringAsFixed(4);

    return '''[HỆ THỐNG CỐ VẤN MÔI TRƯỜNG ENVIVN]
- Vị trí: ${location.displayName} ($latStr, $lonStr)
- Thời gian: $timeStr
- Thời tiết: ${weather.currentTemp.toStringAsFixed(1)}°C (Cảm giác như ${weather.apparentTemp.toStringAsFixed(1)}°C), Độ ẩm ${weather.relativeHumidity}%, Gió ${weather.windSpeed.toStringAsFixed(1)}km/h, UV ${weather.uvIndex.toStringAsFixed(1)}
- Chất lượng không khí: AQI $aqi ($aqiCat), PM2.5: ${airQuality.pm25.toStringAsFixed(1)} µg/m³, PM10: ${airQuality.pm10.toStringAsFixed(1)} µg/m³
- Cảnh báo đặc biệt: Mưa ${weather.precipitation.toStringAsFixed(1)}mm, Nguy cơ ngập: $floodRisk
[YÊU CẦU]
Đóng vai trò chuyên gia môi trường & sức khỏe. Trả lời ngắn gọn, thực tế, ân cần bằng tiếng Việt tự nhiên.''';
  }

  static String generateSimulatedResponse({
    required String query,
    required String systemPrompt,
  }) {
    final lower = query.toLowerCase();
    final lines = systemPrompt.split('\n');

    String weatherSummary = 'thời tiết mát mẻ';
    String aqiSummary = 'AQI ở mức bình thường';

    for (final line in lines) {
      if (line.contains('Thời tiết:')) {
        weatherSummary = line.replaceFirst('- Thời tiết:', '').trim();
      } else if (line.contains('Chất lượng không khí:')) {
        aqiSummary = line.replaceFirst('- Chất lượng không khí:', '').trim();
      }
    }

    if (lower.contains('chạy bộ') || lower.contains('thể thao')) {
      if (aqiSummary.contains('Xấu') ||
          aqiSummary.contains('Rất xấu') ||
          aqiSummary.contains('Nguy hại')) {
        return 'Hiện tại $aqiSummary. Bạn nên tránh tập thể dục ngoài trời để bảo vệ đường hô hấp, thay vào đó hãy tập luyện trong nhà có máy lọc không khí.';
      }
      if (weatherSummary.contains('Mưa') ||
          weatherSummary.contains('UV 8') ||
          weatherSummary.contains('UV 9')) {
        return 'Điều kiện hiện tại ($weatherSummary). Bạn nên cân nhắc hoãn chạy ngoài trời hoặc chuẩn bị áo mưa, đồ bảo hộ che chắn tia cực tím cẩn thận.';
      }
      return 'Điều kiện môi trường khá lý tưởng với $weatherSummary và $aqiSummary. Bạn hoàn toàn có thể chạy bộ, hãy nhớ bổ sung đủ nước nhé!';
    }

    if (lower.contains('trẻ') ||
        lower.contains('già') ||
        lower.contains('bụi')) {
      if (aqiSummary.contains('Kém') ||
          aqiSummary.contains('Xấu') ||
          aqiSummary.contains('Rất xấu')) {
        return 'Chỉ số không khí ghi nhận $aqiSummary. Trẻ nhỏ và người cao tuổi có hệ hô hấp nhạy cảm nên hạn chế ra đường lúc này và đeo khẩu trang chuyên dụng N95 nếu bắt buộc phải ra ngoài.';
      }
      return 'Hiện tại $aqiSummary. Không khí ở ngưỡng an toàn cho trẻ nhỏ và người lớn tuổi sinh hoạt, vui chơi.';
    }

    if (lower.contains('ngập') || lower.contains('mưa')) {
      if (weatherSummary.contains('Mưa') ||
          systemPrompt.contains('Nguy cơ ngập: Cao') ||
          systemPrompt.contains('Nguy cơ ngập: Rất cao')) {
        return 'Khu vực đang có lượng mưa đáng kể, nguy cơ đọng nước và ngập cục bộ tại các đoạn đường trũng. Bạn hãy chủ động chọn lộ trình cao ráo và di chuyển cẩn trọng.';
      }
      return 'Hiện tại dữ liệu ghi nhận lượng mưa không đáng kể, nguy cơ ngập úng ở mức thấp, giao thông thông suốt.';
    }

    return 'Dựa trên dữ liệu cảm biến: $weatherSummary, $aqiSummary. Bạn nên chú ý bổ sung nước đều đặn và theo dõi sự thay đổi thời tiết qua ứng dụng EnviVN.';
  }
}
