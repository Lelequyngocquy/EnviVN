import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';

enum ActivitySafetyLevel {
  safe,
  caution,
  avoid,
}

/// Thông tin dự báo chi tiết cho một khung giờ hoạt động ngoài trời.
class ActivitySlotInfo {
  final String timeRange; // e.g. '05:30 - 07:30'
  final String activity;  // e.g. 'Chạy bộ • Sáng nay'
  final String status;    // e.g. 'Rất lý tưởng', 'Không khí xấu (AQI 160)'
  final bool isOk;

  const ActivitySlotInfo({
    required this.timeRange,
    required this.activity,
    required this.status,
    required this.isOk,
  });
}

class ActivityAdviceData {
  final ActivitySafetyLevel level;
  final String statusLabel;
  final Color statusColor;
  final String adviceText;
  final List<ActivitySlotInfo> slots;
  final String morningStatus;
  final bool isMorningOk;
  final String eveningStatus;
  final bool isEveningOk;

  const ActivityAdviceData({
    required this.level,
    required this.statusLabel,
    required this.statusColor,
    required this.adviceText,
    required this.slots,
    required this.morningStatus,
    required this.isMorningOk,
    required this.eveningStatus,
    required this.isEveningOk,
  });
}

class _SlotCandidate {
  final DateTime targetTime;
  final String timeRange;
  final String activity;

  const _SlotCandidate({
    required this.targetTime,
    required this.timeRange,
    required this.activity,
  });
}

class ActivityAdviceHelper {
  ActivityAdviceHelper._();

  /// Đánh giá an toàn hoạt động thể thao ngoài trời theo Phương án B:
  /// - Thẻ chính: Đánh giá cho THỜI ĐIỂM HIỆN TẠI (AQI, UV, Xác suất mưa hiện tại)
  /// - Khung giờ gợi ý: Trích xuất chính xác theo dự báo giờ (hourly) của thời điểm tới
  static ActivityAdviceData evaluate({
    required int aqi,
    required double uv,
    required int rainProb,
    DateTime? currentTime,
    List<HourlyDetailsPoint> hourlyWeather = const [],
    List<HourlyAqiPoint> hourlyAqi = const [],
    bool isRaining = false,
    double precipitation = 0.0,
  }) {
    // 1. Phân loại theo Multi-factor Matrix thời điểm hiện tại
    final bool actuallyRaining = isRaining || precipitation > 0.1;
    final bool isSafe = !actuallyRaining && aqi <= 100 && uv <= 7 && rainProb <= 40;
    final bool isAvoid = actuallyRaining || aqi > 150 || uv > 9 || rainProb > 70;

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

    // 2. Lời khuyên tổng hợp cho THỜI ĐIỂM HIỆN TẠI
    final String adviceText;
    if (level == ActivitySafetyLevel.avoid) {
      if (actuallyRaining) {
        adviceText =
            'Trời đang có mưa (${precipitation > 0 ? '${precipitation.toStringAsFixed(1)} mm' : 'mưa rào'}). Đường trơn trượt nguy hiểm, không nên chạy bộ ngoài trời. Hãy chuẩn bị áo mưa khi đi lại.';
      } else if (aqi > 150) {
        adviceText =
            'Chất lượng không khí hiện tại ở mức Xấu (AQI $aqi). Không nên chạy bộ hoặc tập luyện gắng sức ngoài trời để bảo vệ đường hô hấp.';
      } else if (rainProb > 70) {
        adviceText =
            'Khu vực hiện có khả năng mưa rất cao ($rainProb%). Đường trơn trượt nguy hiểm, nên chuyển sang chạy máy hoặc tập trong nhà.';
      } else {
        adviceText =
            'Chỉ số tia cực tím hiện tại đạt ngưỡng cực đoan (UV ${uv.toStringAsFixed(1)}). Nguy cơ sốc nhiệt và tổn thương da cao, không nên tập ngoài trời.';
      }
    } else if (level == ActivitySafetyLevel.caution) {
      if (aqi > 100) {
        adviceText =
            'Không khí lúc này ở mức Kém (AQI $aqi). Nhóm người nhạy cảm nên giảm cự ly hoặc chuyển sang đi bộ nhẹ, đeo khẩu trang PM2.5.';
      } else if (uv > 7) {
        adviceText =
            'Tia UV hiện tại ở mức cao (UV ${uv.toStringAsFixed(1)}). Nên chọn cung đường râm mát, đội mũ nón và thoa kem chống nắng đầy đủ.';
      } else {
        adviceText =
            'Hiện tại có khả năng xuất hiện mưa rải rác ($rainProb%). Nên chú ý mặt đường ướt và mang theo áo mưa nhẹ dự phòng.';
      }
    } else {
      adviceText =
          'Thời tiết và không khí hiện tại rất lý tưởng cho chạy bộ, đạp xe và các hoạt động thể thao ngoài trời.';
    }

    // 3. Dự báo thông minh theo khung giờ sắp tới trong 24h
    final now = currentTime ?? DateTime.now();
    final slots = resolveTimeSlots(
      currentTime: now,
      hourlyWeather: hourlyWeather,
      hourlyAqi: hourlyAqi,
      fallbackAqi: aqi,
      fallbackRainProb: rainProb,
    );

    final morningStatus = slots.isNotEmpty ? slots[0].status : 'Thích hợp';
    final isMorningOk = slots.isNotEmpty ? slots[0].isOk : true;
    final eveningStatus = slots.length > 1 ? slots[1].status : 'Thích hợp';
    final isEveningOk = slots.length > 1 ? slots[1].isOk : true;

    return ActivityAdviceData(
      level: level,
      statusLabel: statusLabel,
      statusColor: statusColor,
      adviceText: adviceText,
      slots: slots,
      morningStatus: morningStatus,
      isMorningOk: isMorningOk,
      eveningStatus: eveningStatus,
      isEveningOk: isEveningOk,
    );
  }

  /// Trích xuất và đánh giá 2 khung giờ tập luyện phù hợp tiếp theo dựa trên thời gian hiện tại:
  /// - Trước 07:30: Sáng nay & Chiều nay
  /// - Từ 07:30 đến 18:30: Chiều nay & Sáng mai
  /// - Từ 18:30 đến 21:00: Tối nay & Sáng mai
  /// - Sau 21:00: Sáng mai & Chiều mai
  static List<ActivitySlotInfo> resolveTimeSlots({
    required DateTime currentTime,
    required List<HourlyDetailsPoint> hourlyWeather,
    required List<HourlyAqiPoint> hourlyAqi,
    int fallbackAqi = 50,
    int fallbackRainProb = 0,
  }) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final tomorrow = today.add(const Duration(days: 1));

    final candidateSlots = <_SlotCandidate>[];

    if (currentMinutes < 7 * 60 + 30) {
      // Trước 07:30 sáng: Gợi ý Sáng nay & Chiều nay
      candidateSlots.add(_SlotCandidate(
        targetTime: today.add(const Duration(hours: 6)),
        timeRange: '05:30 - 07:30',
        activity: 'Chạy bộ • Sáng nay',
      ));
      candidateSlots.add(_SlotCandidate(
        targetTime: today.add(const Duration(hours: 17)),
        timeRange: '17:00 - 18:30',
        activity: 'Tập luyện • Chiều nay',
      ));
    } else if (currentMinutes < 18 * 60 + 30) {
      // Từ 07:30 đến 18:30: Sáng nay đã qua -> Gợi ý Chiều nay & Sáng mai
      candidateSlots.add(_SlotCandidate(
        targetTime: today.add(const Duration(hours: 17)),
        timeRange: '17:00 - 18:30',
        activity: 'Tập luyện • Chiều nay',
      ));
      candidateSlots.add(_SlotCandidate(
        targetTime: tomorrow.add(const Duration(hours: 6)),
        timeRange: '05:30 - 07:30',
        activity: 'Chạy bộ • Sáng mai',
      ));
    } else if (currentMinutes < 21 * 60) {
      // Từ 18:30 đến 21:00: Chiều nay đã qua -> Gợi ý Tối nay & Sáng mai
      candidateSlots.add(_SlotCandidate(
        targetTime: today.add(const Duration(hours: 20)),
        timeRange: '19:00 - 21:00',
        activity: 'Đi bộ • Tối nay',
      ));
      candidateSlots.add(_SlotCandidate(
        targetTime: tomorrow.add(const Duration(hours: 6)),
        timeRange: '05:30 - 07:30',
        activity: 'Chạy bộ • Sáng mai',
      ));
    } else {
      // Sau 21:00 đêm: Gợi ý Sáng mai & Chiều mai
      candidateSlots.add(_SlotCandidate(
        targetTime: tomorrow.add(const Duration(hours: 6)),
        timeRange: '05:30 - 07:30',
        activity: 'Chạy bộ • Sáng mai',
      ));
      candidateSlots.add(_SlotCandidate(
        targetTime: tomorrow.add(const Duration(hours: 17)),
        timeRange: '17:00 - 18:30',
        activity: 'Tập luyện • Chiều mai',
      ));
    }

    return candidateSlots.map((candidate) {
      final weatherPoint = _findHourlyWeather(hourlyWeather, candidate.targetTime);
      final aqiPoint = _findHourlyAqi(hourlyAqi, candidate.targetTime);

      final slotAqi = (aqiPoint != null && aqiPoint.aqi > 0)
          ? aqiPoint.aqi
          : fallbackAqi;
      final slotRainProb =
          weatherPoint?.precipitationProbability ?? fallbackRainProb;
      final slotTemp = weatherPoint?.temperature;

      final bool isAqiBad = slotAqi > 150;
      final bool isAqiCaution = slotAqi > 100 && slotAqi <= 150;
      final bool isRainHeavy = slotRainProb >= 65;
      final bool isRainCaution = slotRainProb >= 40 && slotRainProb < 65;
      final bool isTooHot = slotTemp != null && slotTemp >= 38.0;

      final bool isOk = !isAqiBad && !isRainHeavy && !isAqiCaution && !isTooHot;

      final String status;
      if (isAqiBad) {
        status = 'Không khí xấu (AQI $slotAqi)';
      } else if (isRainHeavy) {
        status = 'Nguy cơ mưa $slotRainProb%';
      } else if (isAqiCaution) {
        status = 'Nên đeo khẩu trang';
      } else if (isTooHot) {
        status = 'Nắng nóng ${slotTemp.round()}°C';
      } else if (isRainCaution) {
        status = 'Khả năng mưa $slotRainProb%';
      } else if (slotAqi <= 50 && slotRainProb <= 20) {
        status = 'Rất lý tưởng';
      } else {
        status = 'Thích hợp';
      }

      return ActivitySlotInfo(
        timeRange: candidate.timeRange,
        activity: candidate.activity,
        status: status,
        isOk: isOk,
      );
    }).toList();
  }

  static HourlyDetailsPoint? _findHourlyWeather(
    List<HourlyDetailsPoint> list,
    DateTime target,
  ) {
    if (list.isEmpty) return null;
    for (final p in list) {
      if (p.time.year == target.year &&
          p.time.month == target.month &&
          p.time.day == target.day &&
          p.time.hour == target.hour) {
        return p;
      }
    }
    HourlyDetailsPoint closest = list.first;
    int minDiff = (closest.time.difference(target)).inMinutes.abs();
    for (final p in list) {
      final diff = (p.time.difference(target)).inMinutes.abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = p;
      }
    }
    return closest;
  }

  static HourlyAqiPoint? _findHourlyAqi(
    List<HourlyAqiPoint> list,
    DateTime target,
  ) {
    if (list.isEmpty) return null;
    for (final p in list) {
      if (p.time.year == target.year &&
          p.time.month == target.month &&
          p.time.day == target.day &&
          p.time.hour == target.hour) {
        return p;
      }
    }
    HourlyAqiPoint closest = list.first;
    int minDiff = (closest.time.difference(target)).inMinutes.abs();
    for (final p in list) {
      final diff = (p.time.difference(target)).inMinutes.abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = p;
      }
    }
    return closest;
  }
}
