import 'package:flutter/material.dart';

import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'advisor_decision.dart';

/// Danh mục các câu hỏi tư vấn môi trường nhanh.
/// Mỗi case tự đóng gói metadata và phương thức [evaluate] rẽ nhánh nghiệp vụ ở Domain.
enum QuickPromptType {
  running(
    label: 'Chạy bộ ngoài trời',
    icon: Icons.directions_run_rounded,
  ),
  ventilation(
    label: 'Mở cửa thông gió',
    icon: Icons.air_rounded,
  ),
  childrenOutdoor(
    label: 'Trẻ em & Người già',
    icon: Icons.family_restroom_rounded,
  ),
  commute(
    label: 'Đi lại & Đi làm',
    icon: Icons.two_wheeler_rounded,
  );

  final String label;
  final IconData icon;

  const QuickPromptType({
    required this.label,
    required this.icon,
  });

  /// Đánh giá điều kiện thực tế (0ms, 100% Deterministic) và trả về kịch bản tư vấn phù hợp.
  AdvisorDecision evaluate({
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
    final weatherInfo = WeatherCodeHelper.getInfo(weatherCode);
    final actuallyRaining =
        isRaining || precipitation > 0.1 || weatherInfo.isRain;
    final isHighRainChance = rainProbability >= 60;

    switch (this) {
      case QuickPromptType.running:
        // 1. Trời đang mưa hoặc dông bão -> Nguy cơ té ngã, cảm lạnh, sét đánh
        if (actuallyRaining || weatherInfo.isThunder) {
          return AdvisorDecision.runningRainWarning;
        }
        // 2. Nhóm bệnh hô hấp / nhạy cảm
        if (hasRespiratoryCondition && (aqi > 75 || pm25 > 25.0)) {
          return AdvisorDecision.runningSensitiveWarning;
        }
        // 3. Không khí ô nhiễm nguy hại
        if (aqi > 150 || pm25 > 55.0) {
          return AdvisorDecision.runningSevereAirDanger;
        }
        // 4. Sốc nhiệt hoặc bức xạ UV cao
        if (temperature > 34.0 || (uvIndex != null && uvIndex >= 7.5)) {
          return AdvisorDecision.runningHeatOrUvRisk;
        }
        // 5. Nguy cơ mưa cao sắp tới
        if (isHighRainChance) {
          return AdvisorDecision.runningRainWarning;
        }
        // 6. Không khí trung bình
        if (aqi > 50 || pm25 > 15.0) {
          return AdvisorDecision.runningCautious;
        }
        // 7. Điều kiện lý tưởng
        return AdvisorDecision.runningIdeal;

      case QuickPromptType.ventilation:
        // Đóng/mở cửa thông gió hoàn toàn dựa trên mức độ trong lành của không khí
        // 1. Không khí bên ngoài ô nhiễm cao -> Đóng chặt cửa
        if (aqi > 100 || pm25 > 35.0) {
          return AdvisorDecision.ventilationKeepClosed;
        }
        // 2. Không khí trung bình -> Mở hé thoáng 10-15m
        if (aqi > 50 || pm25 > 15.0) {
          return AdvisorDecision.ventilationBriefOnly;
        }
        // 3. Không khí sạch -> Mở toang đón gió
        return AdvisorDecision.ventilationOptimal;

      case QuickPromptType.childrenOutdoor:
        // 1. Trời mưa ẩm -> Giữ trẻ nhỏ và người già trong nhà
        if (actuallyRaining || weatherInfo.isThunder) {
          return AdvisorDecision.childrenRainWarning;
        }
        // 2. Ô nhiễm cao hoặc có bệnh nền -> Giữ trong nhà
        if (aqi > 150 || pm25 > 55.0 || (hasRespiratoryCondition && aqi > 75)) {
          return AdvisorDecision.childrenStayIndoorDanger;
        }
        // 3. Cần thận trọng nếu bụi trung bình hoặc UV cao hoặc khả năng mưa
        if (aqi > 50 ||
            pm25 > 15.0 ||
            (uvIndex != null && uvIndex >= 6.0) ||
            isHighRainChance) {
          return AdvisorDecision.childrenNeedCaution;
        }
        // 4. An toàn ra ngoài
        return AdvisorDecision.childrenSafeToGo;

      case QuickPromptType.commute:
        // 1. Đang mưa hoặc khả năng mưa cao -> Chuẩn bị áo mưa & cẩn trọng di chuyển
        if (actuallyRaining || isHighRainChance) {
          if (aqi > 100 || pm25 > 35.0) {
            return AdvisorDecision.commuteRainAndPollutionWarning;
          }
          return AdvisorDecision.commuteRainWarning;
        }
        // 2. Ô nhiễm cao -> Khẩu trang N95/KF94 bắt buộc
        if (aqi > 100 || pm25 > 35.0) {
          return AdvisorDecision.commuteRequireN95Protective;
        }
        // 3. Bụi đường trung bình -> Khẩu trang y tế
        if (aqi > 50 || pm25 > 15.0) {
          return AdvisorDecision.commuteRequireRegularMask;
        }
        // 4. Không khí tốt
        return AdvisorDecision.commuteSafeConditions;
    }
  }
}
