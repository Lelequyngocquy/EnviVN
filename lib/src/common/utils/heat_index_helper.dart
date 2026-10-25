import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:envivn/src/common/constants/colors.dart';

enum HeatRiskLevel {
  safe(
    label: 'An toàn',
    description: 'Nhiệt độ dễ chịu, không có nguy cơ sốc nhiệt.',
    color: UIColors.aqiGood,
    icon: Icons.sentiment_satisfied_rounded,
  ),
  caution(
    label: 'Cần thận trọng',
    description: 'Có thể mệt mỏi nếu tiếp xúc lâu hoặc vận động mạnh.',
    color: UIColors.aqiModerate,
    icon: Icons.info_outline_rounded,
  ),
  danger(
    label: 'Nguy cơ cao',
    description: 'Nguy cơ say nắng, chuột rút và kiệt sức vì nhiệt.',
    color: UIColors.aqiUnhealthySensitive,
    icon: Icons.warning_amber_rounded,
  ),
  extreme(
    label: 'Cực kỳ nguy hiểm',
    description: 'Nguy cơ đột quỵ nhiệt rất cao nếu ở lâu ngoài trời.',
    color: UIColors.markerRedDark,
    icon: Icons.local_fire_department_rounded,
  );

  final String label;
  final String description;
  final Color color;
  final IconData icon;

  const HeatRiskLevel({
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class HeatIndexHelper {
  HeatIndexHelper._();

  /// Tính chỉ số nhiệt cảm nhận (Heat Index) theo công thức NOAA / Steadman
  /// [tempC]: Nhiệt độ môi trường (°C)
  /// [humidity]: Độ ẩm tương đối (%)
  static double calculateHeatIndex(double tempC, int humidity) {
    if (tempC < 26.7) {
      // Dưới ngưỡng áp dụng Heat Index, chỉ số nhiệt xấp xỉ nhiệt độ thực tế
      return tempC;
    }

    final t = tempC * 9 / 5 + 32; // Chuyển sang Fahrenheit
    final rh = humidity.toDouble();

    // Công thức đa thức Rothfusz của NOAA
    double hi =
        -42.379 +
        2.04901523 * t +
        10.14333127 * rh -
        0.22475541 * t * rh -
        0.00683783 * t * t -
        0.05481717 * rh * rh +
        0.00122874 * t * t * rh +
        0.00085282 * t * rh * rh -
        0.00000199 * t * t * rh * rh;

    // Hiệu chỉnh nếu độ ẩm thấp
    if (rh < 13 && t >= 80 && t <= 112) {
      final adj = ((13 - rh) / 4) * math.sqrt((17 - (t - 95).abs()) / 17);
      hi -= adj;
    }
    // Hiệu chỉnh nếu độ ẩm cao
    else if (rh > 85 && t >= 80 && t <= 87) {
      final adj = ((rh - 85) / 10) * ((87 - t) / 5);
      hi += adj;
    }

    // Đổi lại sang độ Celsius
    return (hi - 32) * 5 / 9;
  }

  /// Đánh giá cấp độ rủi ro sốc nhiệt
  static HeatRiskLevel getRiskLevel(double heatIndexC) {
    if (heatIndexC < 30.0) return HeatRiskLevel.safe;
    if (heatIndexC < 38.0) return HeatRiskLevel.caution;
    if (heatIndexC < 46.0) return HeatRiskLevel.danger;
    return HeatRiskLevel.extreme;
  }

  /// Tính thời gian phơi nắng tối đa an toàn (phút) trước khi da tổn thương theo chỉ số UV
  static String getSunburnTimeAdvice(double uvIndex) {
    if (uvIndex < 3.0) return 'Trên 60 phút';
    if (uvIndex < 6.0) return 'Khoảng 45 phút';
    if (uvIndex < 8.0) return 'Khoảng 30 phút';
    if (uvIndex < 11.0) return 'Khoảng 15 - 20 phút';
    return 'Dưới 10 phút (Tránh ra nắng)';
  }
}
