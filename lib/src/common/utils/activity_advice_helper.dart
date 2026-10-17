import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

enum ActivitySafetyLevel {
  safe,
  caution,
  avoid,
}

class ActivityAdviceData {
  final ActivitySafetyLevel level;
  final String statusLabel;
  final Color statusColor;
  final String adviceText;
  final String morningStatus;
  final bool isMorningOk;
  final String eveningStatus;
  final bool isEveningOk;

  const ActivityAdviceData({
    required this.level,
    required this.statusLabel,
    required this.statusColor,
    required this.adviceText,
    required this.morningStatus,
    required this.isMorningOk,
    required this.eveningStatus,
    required this.isEveningOk,
  });
}

class ActivityAdviceHelper {
  ActivityAdviceHelper._();

  /// Đánh giá an toàn hoạt động thể thao ngoài trời dựa trên ma trận đa yếu tố:
  /// - Chất lượng không khí (AQI)
  /// - Chỉ số tia cực tím (UV Index)
  /// - Xác suất mưa (Precipitation Probability)
  static ActivityAdviceData evaluate({
    required int aqi,
    required double uv,
    required int rainProb,
  }) {
    // 1. Phân loại theo Multi-factor Matrix
    final bool isSafe = aqi <= 100 && uv <= 7 && rainProb <= 40;
    final bool isAvoid = aqi > 150 || uv > 9 || rainProb > 70;

    final ActivitySafetyLevel level = isSafe
        ? ActivitySafetyLevel.safe
        : (isAvoid ? ActivitySafetyLevel.avoid : ActivitySafetyLevel.caution);

    final String statusLabel;
    final Color statusColor;

    switch (level) {
      case ActivitySafetyLevel.safe:
        statusLabel = 'An toàn';
        statusColor = UIColors.aqiGood;
        break;
      case ActivitySafetyLevel.caution:
        statusLabel = 'Cần chú ý';
        statusColor = UIColors.aqiModerate;
        break;
      case ActivitySafetyLevel.avoid:
        statusLabel = 'Không nên';
        statusColor = UIColors.aqiUnhealthy;
        break;
    }

    // 2. Lời khuyên tổng hợp (hài hòa đa yếu tố)
    final String adviceText;
    if (level == ActivitySafetyLevel.avoid) {
      if (aqi > 150) {
        adviceText =
            'Chất lượng không khí ở mức Xấu (AQI $aqi). Không nên chạy bộ hoặc tập luyện gắng sức ngoài trời để bảo vệ đường hô hấp.';
      } else if (rainProb > 70) {
        adviceText =
            'Khả năng mưa dông rất cao ($rainProb%). Đường trơn trượt nguy hiểm, nên chuyển sang chạy máy hoặc tập trong nhà.';
      } else {
        adviceText =
            'Chỉ số tia cực tím đạt ngưỡng cực đoan (UV ${uv.toStringAsFixed(1)}). Nguy cơ sốc nhiệt và tổn thương da cao, không nên tập ngoài trời.';
      }
    } else if (level == ActivitySafetyLevel.caution) {
      if (aqi > 100) {
        adviceText =
            'Không khí ở mức Kém (AQI $aqi). Nhóm người nhạy cảm nên giảm cự ly hoặc chuyển sang đi bộ nhẹ, đeo khẩu trang PM2.5.';
      } else if (uv > 7) {
        adviceText =
            'Tia UV ở mức cao (UV ${uv.toStringAsFixed(1)}). Nên chọn cung đường râm mát, đội mũ nón và thoa kem chống nắng đầy đủ.';
      } else {
        adviceText =
            'Có khả năng xuất hiện mưa rải rác ($rainProb%). Nên chú ý mặt đường ướt và mang theo áo mưa nhẹ dự phòng.';
      }
    } else {
      adviceText =
          'Thời tiết và không khí rất lý tưởng cho chạy bộ, đạp xe và các hoạt động thể thao ngoài trời.';
    }

    // 3. Đánh giá gợi ý khung giờ
    final bool isMorningOk = aqi <= 100 && rainProb <= 50;
    final String morningStatus = isMorningOk
        ? 'Rất tốt'
        : (aqi > 150 ? 'Không khuyến khích' : 'Nên đeo khẩu trang');

    final bool isEveningOk = aqi <= 120 && rainProb <= 50 && uv <= 5;
    final String eveningStatus = isEveningOk
        ? 'Thích hợp'
        : (aqi > 150 ? 'Nên tập trong nhà' : 'Hạn chế gắng sức');

    return ActivityAdviceData(
      level: level,
      statusLabel: statusLabel,
      statusColor: statusColor,
      adviceText: adviceText,
      morningStatus: morningStatus,
      isMorningOk: isMorningOk,
      eveningStatus: eveningStatus,
      isEveningOk: isEveningOk,
    );
  }
}
