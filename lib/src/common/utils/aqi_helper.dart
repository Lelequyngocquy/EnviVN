import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum AQICategory {
  good,
  moderate,
  unhealthySensitive,
  unhealthy,
  veryUnhealthy,
  hazardous,
}

class AQIInfo {
  final AQICategory category;
  final String label;
  final String description;
  final Color color;
  final String healthAdvice;
  final String outdoorAdvice;
  final bool wearMask;

  const AQIInfo({
    required this.category,
    required this.label,
    required this.description,
    required this.color,
    required this.healthAdvice,
    required this.outdoorAdvice,
    required this.wearMask,
  });
}

class AQIHelper {
  AQIHelper._();

  static AQIInfo getAQIInfo(int? aqiValue) {
    final aqi = aqiValue ?? 0;
    if (aqi <= 50) {
      return const AQIInfo(
        category: AQICategory.good,
        label: 'Tốt',
        description: 'Chất lượng không khí lý tưởng, không gây nguy hại sức khỏe.',
        color: UIColors.aqiGood,
        healthAdvice: 'Không khí trong lành, mở cửa sổ để đón gió tự nhiên.',
        outdoorAdvice: 'Rất thích hợp cho chạy bộ, đạp xe và các hoạt động thể thao ngoài trời.',
        wearMask: false,
      );
    } else if (aqi <= 100) {
      return const AQIInfo(
        category: AQICategory.moderate,
        label: 'Trung bình',
        description: 'Chấp nhận được. Nhóm người cực kỳ nhạy cảm nên chú ý.',
        color: UIColors.aqiModerate,
        healthAdvice: 'Chất lượng không khí ở mức chấp nhận được.',
        outdoorAdvice: 'Có thể tham gia hoạt động ngoài trời bình thường.',
        wearMask: false,
      );
    } else if (aqi <= 150) {
      return const AQIInfo(
        category: AQICategory.unhealthySensitive,
        label: 'Kém (Nhạy cảm)',
        description: 'Người già, trẻ em và người bệnh hô hấp có thể bị ảnh hưởng.',
        color: UIColors.aqiUnhealthySensitive,
        healthAdvice: 'Nhóm người nhạy cảm nên hạn chế ở ngoài trời lâu.',
        outdoorAdvice: 'Nên giảm cường độ tập thể dục ngoài trời, chuyển vào phòng tập.',
        wearMask: true,
      );
    } else if (aqi <= 200) {
      return const AQIInfo(
        category: AQICategory.unhealthy,
        label: 'Xấu',
        description: 'Bắt đầu ảnh hưởng xấu đến sức khỏe của tất cả mọi người.',
        color: UIColors.aqiUnhealthy,
        healthAdvice: 'Tránh các hoạt động gắng sức ngoài trời.',
        outdoorAdvice: 'Không nên chạy bộ hoặc tập luyện ngoài trời vào khung giờ này.',
        wearMask: true,
      );
    } else if (aqi <= 300) {
      return const AQIInfo(
        category: AQICategory.veryUnhealthy,
        label: 'Rất xấu',
        description: 'Cảnh báo nguy hại sức khỏe nghiêm trọng cho cộng đồng.',
        color: UIColors.aqiVeryUnhealthy,
        healthAdvice: 'Mọi người nên ở trong nhà, đóng kín cửa sổ và bật máy lọc khí.',
        outdoorAdvice: 'Tuyệt đối hạn chế tối đa ra ngoài trời.',
        wearMask: true,
      );
    } else {
      return const AQIInfo(
        category: AQICategory.hazardous,
        label: 'Nguy hại',
        description: 'Mức độ khẩn cấp. Ảnh hưởng nghiêm trọng đến tính mạng.',
        color: UIColors.aqiHazardous,
        healthAdvice: 'Ở yên trong nhà, kích hoạt máy lọc không khí mức cao nhất.',
        outdoorAdvice: 'Cấm các hoạt động ngoài trời!',
        wearMask: true,
      );
    }
  }
}
