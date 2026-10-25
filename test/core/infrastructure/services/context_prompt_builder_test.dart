import 'package:flutter_test/flutter_test.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/core/infrastructure/services/context_prompt_builder.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';

void main() {
  group('ContextPromptBuilder Tests', () {
    test('getAqiCategory categorizes AQI levels accurately', () {
      expect(
        ContextPromptBuilder.getAqiCategory(25),
        equals('Tốt (Trong lành)'),
      );
      expect(
        ContextPromptBuilder.getAqiCategory(75),
        equals('Trung bình (Chấp nhận được)'),
      );
      expect(
        ContextPromptBuilder.getAqiCategory(120),
        equals('Kém (Nhạy cảm cần chú ý)'),
      );
      expect(
        ContextPromptBuilder.getAqiCategory(180),
        equals('Xấu (Không lành mạnh)'),
      );
      expect(
        ContextPromptBuilder.getAqiCategory(250),
        equals('Rất xấu (Rất nguy hại)'),
      );
      expect(
        ContextPromptBuilder.getAqiCategory(350),
        equals('Nguy hại (Khẩn cấp)'),
      );
    });

    test('getFloodRisk evaluates precipitation accurately', () {
      expect(
        ContextPromptBuilder.getFloodRisk(2.0),
        equals('Thấp (Không đáng kể)'),
      );
      expect(
        ContextPromptBuilder.getFloodRisk(10.0),
        equals('Trung bình (Có khả năng đọng nước cục bộ)'),
      );
      expect(
        ContextPromptBuilder.getFloodRisk(25.0),
        equals('Cao (Nguy cơ ngập cục bộ vùng trũng)'),
      );
      expect(
        ContextPromptBuilder.getFloodRisk(60.0),
        equals('Rất cao (Nguy cơ ngập sâu diện rộng)'),
      );
    });

    test('buildSystemPrompt builds correct template with all data items', () {
      final location = AppLocationEntity.customPin(
        latitude: 10.7769,
        longitude: 106.7009,
        referenceProvince: 'TP. Hồ Chí Minh',
        distanceKm: 3.5,
      );

      const weather = DetailsEntity(
        currentTemp: 32.5,
        apparentTemp: 37.0,
        relativeHumidity: 78,
        precipitation: 15.0,
        windSpeed: 12.4,
        uvIndex: 8.5,
      );

      const airQuality = AirQualityEntity(usAqi: 135, pm25: 49.5, pm10: 72.0);

      final fixedTime = DateTime(2026, 10, 25, 14, 30);
      final prompt = ContextPromptBuilder.buildSystemPrompt(
        location: location,
        weather: weather,
        airQuality: airQuality,
        currentTime: fixedTime,
      );

      expect(prompt, contains('[HỆ THỐNG CỐ VẤN MÔI TRƯỜNG ENVIVN]'));
      expect(
        prompt,
        contains(
          'Vị trí: Điểm ghim (~3.5 km từ TP. Hồ Chí Minh) (10.7769, 106.7009)',
        ),
      );
      expect(prompt, contains('Thời gian: 25/10/2026 14:30'));
      expect(
        prompt,
        contains(
          'Thời tiết: 32.5°C (Cảm giác như 37.0°C), Độ ẩm 78%, Gió 12.4km/h, UV 8.5',
        ),
      );
      expect(
        prompt,
        contains(
          'Chất lượng không khí: AQI 135 (Kém (Nhạy cảm cần chú ý)), PM2.5: 49.5 µg/m³, PM10: 72.0 µg/m³',
        ),
      );
      expect(
        prompt,
        contains(
          'Cảnh báo đặc biệt: Mưa 15.0mm, Nguy cơ ngập: Trung bình (Có khả năng đọng nước cục bộ)',
        ),
      );
      expect(prompt, contains('[YÊU CẦU]'));
      expect(
        prompt,
        contains(
          'Đóng vai trò chuyên gia môi trường & sức khỏe. Trả lời ngắn gọn, thực tế, ân cần bằng tiếng Việt tự nhiên.',
        ),
      );
    });

    test('defaultSuggestedQuestions has items and is non-empty', () {
      expect(
        ContextPromptBuilder.defaultSuggestedQuestions.length,
        greaterThanOrEqualTo(3),
      );
      expect(
        ContextPromptBuilder.defaultSuggestedQuestions.any(
          (q) => q.contains('chạy bộ'),
        ),
        isTrue,
      );
      expect(
        ContextPromptBuilder.defaultSuggestedQuestions.any(
          (q) => q.contains('ngập'),
        ),
        isTrue,
      );
    });

    test('generateSimulatedResponse generates appropriate responses', () {
      const mockPrompt = '''[HỆ THỐNG CỐ VẤN MÔI TRƯỜNG ENVIVN]
- Vị trí: Hà Nội (21.0285, 105.8542)
- Thời tiết: 28.0°C, Độ ẩm 65%, Gió 10.0km/h, UV 5.0
- Chất lượng không khí: AQI 180 (Xấu (Không lành mạnh)), PM2.5: 65.0 µg/m³
- Cảnh báo đặc biệt: Mưa 0.0mm, Nguy cơ ngập: Thấp''';

      final runningReply = ContextPromptBuilder.generateSimulatedResponse(
        query: 'Tôi có nên chạy bộ không?',
        systemPrompt: mockPrompt,
      );
      expect(runningReply, contains('tránh tập thể dục ngoài trời'));

      final childReply = ContextPromptBuilder.generateSimulatedResponse(
        query: 'Bụi này trẻ nhỏ ra ngoài được không?',
        systemPrompt: mockPrompt,
      );
      expect(childReply, contains('khẩu trang'));

      final floodReply = ContextPromptBuilder.generateSimulatedResponse(
        query: 'Đường xá có ngập không?',
        systemPrompt: mockPrompt,
      );
      expect(floodReply, contains('thấp'));
    });
  });
}
