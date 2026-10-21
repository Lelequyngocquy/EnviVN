import 'package:flutter/material.dart';

import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'advisor_decision.dart';

enum QuickPromptType {
  running(label: 'Chạy bộ ngoài trời', icon: Icons.directions_run_rounded),
  ventilation(label: 'Mở cửa thông gió', icon: Icons.air_rounded),
  childrenOutdoor(
    label: 'Trẻ em & Người già',
    icon: Icons.family_restroom_rounded,
  ),
  commute(label: 'Đi lại & Đi làm', icon: Icons.two_wheeler_rounded);

  final String label;
  final IconData icon;

  const QuickPromptType({required this.label, required this.icon});

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
        if (actuallyRaining || weatherInfo.isThunder) {
          return AdvisorDecision.runningRainWarning;
        }

        if (hasRespiratoryCondition && (aqi > 75 || pm25 > 25.0)) {
          return AdvisorDecision.runningSensitiveWarning;
        }

        if (aqi > 150 || pm25 > 55.0) {
          return AdvisorDecision.runningSevereAirDanger;
        }

        if (temperature > 34.0 || (uvIndex != null && uvIndex >= 7.5)) {
          return AdvisorDecision.runningHeatOrUvRisk;
        }

        if (isHighRainChance) {
          return AdvisorDecision.runningRainWarning;
        }

        if (aqi > 50 || pm25 > 15.0) {
          return AdvisorDecision.runningCautious;
        }

        return AdvisorDecision.runningIdeal;

      case QuickPromptType.ventilation:
        if (aqi > 100 || pm25 > 35.0) {
          return AdvisorDecision.ventilationKeepClosed;
        }

        if (aqi > 50 || pm25 > 15.0) {
          return AdvisorDecision.ventilationBriefOnly;
        }

        return AdvisorDecision.ventilationOptimal;

      case QuickPromptType.childrenOutdoor:
        if (actuallyRaining || weatherInfo.isThunder) {
          return AdvisorDecision.childrenRainWarning;
        }

        if (aqi > 150 || pm25 > 55.0 || (hasRespiratoryCondition && aqi > 75)) {
          return AdvisorDecision.childrenStayIndoorDanger;
        }

        if (aqi > 50 ||
            pm25 > 15.0 ||
            (uvIndex != null && uvIndex >= 6.0) ||
            isHighRainChance) {
          return AdvisorDecision.childrenNeedCaution;
        }

        return AdvisorDecision.childrenSafeToGo;

      case QuickPromptType.commute:
        if (actuallyRaining || isHighRainChance) {
          if (aqi > 100 || pm25 > 35.0) {
            return AdvisorDecision.commuteRainAndPollutionWarning;
          }
          return AdvisorDecision.commuteRainWarning;
        }

        if (aqi > 100 || pm25 > 35.0) {
          return AdvisorDecision.commuteRequireN95Protective;
        }

        if (aqi > 50 || pm25 > 15.0) {
          return AdvisorDecision.commuteRequireRegularMask;
        }

        return AdvisorDecision.commuteSafeConditions;
    }
  }
}
