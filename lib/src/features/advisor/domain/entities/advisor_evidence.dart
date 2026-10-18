import 'package:equatable/equatable.dart';

import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'quick_prompt_type.dart';

/// Đại diện cho một mục dẫn chứng dữ liệu cụ thể dùng để tính toán quyết định tư vấn.
/// Tuân thủ yêu cầu hiển thị tường minh các chỉ số thực tế so sánh với ngưỡng chuẩn (WHO/QCVN).
class AdvisorEvidence extends Equatable {
  final String metricName;
  final String formattedValue;
  final String standardBenchmark;
  final String detailComparison;
  final bool isExceeded;
  final bool isDanger;

  const AdvisorEvidence({
    required this.metricName,
    required this.formattedValue,
    required this.standardBenchmark,
    required this.detailComparison,
    this.isExceeded = false,
    this.isDanger = false,
  });

  /// Chuỗi tóm tắt dẫn chứng theo mẫu:
  /// (PM2.5: 14.3 µg/m³ cao hơn mức cho phép là 15.0 µg/m³ theo chuẩn WHO)
  String get summaryText =>
      '$metricName: $formattedValue ($detailComparison • Chuẩn: $standardBenchmark)';

  /// Đánh giá và sinh danh sách dẫn chứng khoa học dựa trên dữ liệu môi trường thực tế.
  static List<AdvisorEvidence> evaluate({
    required QuickPromptType prompt,
    required int aqi,
    required double pm25,
    required double temperature,
    double? uvIndex,
    bool hasRespiratoryCondition = false,
    bool isRaining = false,
    int rainProbability = 0,
    double precipitation = 0.0,
    int? weatherCode,
  }) {
    final list = <AdvisorEvidence>[];

    // 1. Dẫn chứng Bụi mịn PM2.5 (Chuẩn WHO 24h: 15.0 µg/m³, QCVN: 25.0 µg/m³)
    final pm25Str = '${pm25.toStringAsFixed(1)} µg/m³';
    const pm25Benchmark = '≤ 15.0 µg/m³ (WHO)';

    if (pm25 > 55.0) {
      final ratio = (pm25 / 15.0).toStringAsFixed(1);
      list.add(
        AdvisorEvidence(
          metricName: 'Bụi mịn PM2.5',
          formattedValue: pm25Str,
          standardBenchmark: pm25Benchmark,
          detailComparison:
              'Vượt $ratio lần mức an toàn WHO, thuộc ngưỡng nguy hại cho phế nang',
          isExceeded: true,
          isDanger: true,
        ),
      );
    } else if (pm25 > 25.0) {
      list.add(
        AdvisorEvidence(
          metricName: 'Bụi mịn PM2.5',
          formattedValue: pm25Str,
          standardBenchmark: pm25Benchmark,
          detailComparison:
              'Cao hơn mức cho phép WHO (15.0 µg/m³) và QCVN (25.0 µg/m³)',
          isExceeded: true,
          isDanger: false,
        ),
      );
    } else if (pm25 > 15.0) {
      list.add(
        AdvisorEvidence(
          metricName: 'Bụi mịn PM2.5',
          formattedValue: pm25Str,
          standardBenchmark: pm25Benchmark,
          detailComparison:
              'Hơi vượt mức an toàn lý tưởng WHO (ngưỡng 15.0 µg/m³)',
          isExceeded: true,
          isDanger: false,
        ),
      );
    } else {
      list.add(
        AdvisorEvidence(
          metricName: 'Bụi mịn PM2.5',
          formattedValue: pm25Str,
          standardBenchmark: pm25Benchmark,
          detailComparison: 'Đạt chuẩn không khí sạch lý tưởng theo khuyến nghị WHO',
          isExceeded: false,
          isDanger: false,
        ),
      );
    }

    // 2. Dẫn chứng Chỉ số Chất lượng Không khí (US AQI: Chuẩn an toàn ≤ 50)
    final aqiStr = '$aqi US AQI';
    const aqiBenchmark = '≤ 50 (Mức Tốt)';

    if (aqi > 150) {
      list.add(
        AdvisorEvidence(
          metricName: 'Chỉ số AQI',
          formattedValue: aqiStr,
          standardBenchmark: aqiBenchmark,
          detailComparison:
              'Vượt ngưỡng ô nhiễm xấu (> 150), cảnh báo rủi ro hô hấp cao',
          isExceeded: true,
          isDanger: true,
        ),
      );
    } else if (aqi > 100) {
      list.add(
        AdvisorEvidence(
          metricName: 'Chỉ số AQI',
          formattedValue: aqiStr,
          standardBenchmark: aqiBenchmark,
          detailComparison:
              'Cao hơn mức an toàn thông thường, nhạy cảm với người hô hấp yếu',
          isExceeded: true,
          isDanger: false,
        ),
      );
    } else if (aqi > 50) {
      list.add(
        AdvisorEvidence(
          metricName: 'Chỉ số AQI',
          formattedValue: aqiStr,
          standardBenchmark: aqiBenchmark,
          detailComparison:
              'Mức trung bình (51-100), cao hơn mức lý tưởng (≤ 50)',
          isExceeded: true,
          isDanger: false,
        ),
      );
    } else {
      list.add(
        AdvisorEvidence(
          metricName: 'Chỉ số AQI',
          formattedValue: aqiStr,
          standardBenchmark: aqiBenchmark,
          detailComparison:
              'Mức Xanh (0-50), không khí an toàn và trong lành',
          isExceeded: false,
          isDanger: false,
        ),
      );
    }

    // 3. Dẫn chứng Nhiệt độ môi trường (ngưỡng chịu đựng vận động thể thao an toàn < 34.0°C)
    final isSportOrChild = prompt == QuickPromptType.running ||
        prompt == QuickPromptType.childrenOutdoor;
    if (isSportOrChild || temperature > 34.0) {
      final tempStr = '${temperature.toStringAsFixed(1)}°C';
      const tempBenchmark = '< 34.0°C (An toàn thể lực)';

      if (temperature > 37.0) {
        list.add(
          AdvisorEvidence(
            metricName: 'Nhiệt độ môi trường',
            formattedValue: tempStr,
            standardBenchmark: tempBenchmark,
            detailComparison:
                'Nắng nóng gay gắt (> 37°C), rủi ro sốc nhiệt và kiệt sức',
            isExceeded: true,
            isDanger: true,
          ),
        );
      } else if (temperature > 34.0) {
        list.add(
          AdvisorEvidence(
            metricName: 'Nhiệt độ môi trường',
            formattedValue: tempStr,
            standardBenchmark: tempBenchmark,
            detailComparison:
                'Cao hơn mức vận động thoải mái (34.0°C), dễ mất nước',
            isExceeded: true,
            isDanger: false,
          ),
        );
      } else {
        list.add(
          AdvisorEvidence(
            metricName: 'Nhiệt độ môi trường',
            formattedValue: tempStr,
            standardBenchmark: tempBenchmark,
            detailComparison: 'Nhiệt độ mát mẻ thuận lợi cho hoạt động thể chất',
            isExceeded: false,
            isDanger: false,
          ),
        );
      }
    }

    // 4. Dẫn chứng Bức xạ cực tím UV (Ngưỡng an toàn cho da < 6.0)
    if (uvIndex != null && (uvIndex >= 6.0 || isSportOrChild)) {
      final uvStr = 'UV ${uvIndex.toStringAsFixed(1)}';
      const uvBenchmark = '< 6.0 (An toàn da)';

      if (uvIndex >= 8.0) {
        list.add(
          AdvisorEvidence(
            metricName: 'Bức xạ tia cực tím',
            formattedValue: uvStr,
            standardBenchmark: uvBenchmark,
            detailComparison:
                'Vượt ngưỡng bức xạ rất cao (≥ 8.0), nguy cơ bỏng da sau 15-20 phút',
            isExceeded: true,
            isDanger: true,
          ),
        );
      } else if (uvIndex >= 6.0) {
        list.add(
          AdvisorEvidence(
            metricName: 'Bức xạ tia cực tím',
            formattedValue: uvStr,
            standardBenchmark: uvBenchmark,
            detailComparison:
                'Cao hơn mức an toàn (ngưỡng 6.0), cần che chắn và kem chống nắng',
            isExceeded: true,
            isDanger: false,
          ),
        );
      } else {
        list.add(
          AdvisorEvidence(
            metricName: 'Bức xạ tia cực tím',
            formattedValue: uvStr,
            standardBenchmark: uvBenchmark,
            detailComparison: 'Bức xạ UV ở ngưỡng an toàn, ít rủi ro tổn thương da',
            isExceeded: false,
            isDanger: false,
          ),
        );
      }
    }

    // 5. Dẫn chứng Tình trạng bệnh nền hô hấp (nếu có)
    if (hasRespiratoryCondition) {
      list.add(
        const AdvisorEvidence(
          metricName: 'Cơ địa hô hấp',
          formattedValue: 'Có bệnh nền (hen/xoang)',
          standardBenchmark: 'Khuyên tập phòng lọc khí khi AQI > 75',
          detailComparison:
              'Phế quản nhạy cảm hơn, ngưỡng chịu đựng bụi thấp hơn người thường',
          isExceeded: true,
          isDanger: false,
        ),
      );
    }

    // 6. Dẫn chứng Hiện trạng thời tiết & Mưa: CHỈ ÁP DỤNG CHO CÁC CASE RA ĐƯỜNG (running, commute, childrenOutdoor).
    // Riêng case mở cửa thông gió (ventilation) hoàn toàn không tính đến thời tiết mưa.
    final isOutdoorCase = prompt != QuickPromptType.ventilation;
    if (isOutdoorCase) {
      final weatherInfo = WeatherCodeHelper.getInfo(weatherCode);
      final actuallyRaining =
          isRaining || precipitation > 0.1 || weatherInfo.isRain;

      if (actuallyRaining) {
        final rainStr = precipitation > 0.0
            ? '${weatherInfo.description} (${precipitation.toStringAsFixed(1)} mm)'
            : weatherInfo.description;
        list.add(
          AdvisorEvidence(
            metricName: 'Thời tiết & Mưa',
            formattedValue: rainStr,
            standardBenchmark: 'Tạnh ráo / Không mưa',
            detailComparison: prompt == QuickPromptType.running
                ? 'Đang có mưa, mặt đường trơn trượt nguy hiểm, không nên chạy bộ ngoài trời'
                : (prompt == QuickPromptType.commute
                    ? 'Trời đang có mưa, bắt buộc mang theo áo mưa và giảm tốc độ lái xe'
                    : 'Đang có mưa ẩm ngoài trời, hạn chế để trẻ em và người già ra ngoài'),
            isExceeded: true,
            isDanger: weatherInfo.isThunder || precipitation >= 10.0,
          ),
        );
      } else if (rainProbability >= 40) {
        list.add(
          AdvisorEvidence(
            metricName: 'Xác suất có mưa',
            formattedValue: '$rainProbability%',
            standardBenchmark: '< 30% (Khả năng mưa thấp)',
            detailComparison: prompt == QuickPromptType.commute
                ? 'Khả năng có mưa cao ($rainProbability%), cần chuẩn bị sẵn áo mưa trong cốp/balo'
                : 'Xác suất mưa $rainProbability%, nên ưu tiên lộ trình gần nơi có chỗ trú',
            isExceeded: true,
            isDanger: false,
          ),
        );
      } else {
        list.add(
          const AdvisorEvidence(
            metricName: 'Thời tiết mặt đường',
            formattedValue: 'Tạnh ráo, không mưa',
            standardBenchmark: 'Tạnh ráo',
            detailComparison:
                'Mặt đường khô ráo, thuận lợi cho việc đi lại và thể thao ngoài trời',
            isExceeded: false,
            isDanger: false,
          ),
        );
      }
    }

    return list;
  }

  @override
  List<Object?> get props => [
        metricName,
        formattedValue,
        standardBenchmark,
        detailComparison,
        isExceeded,
        isDanger,
      ];
}
