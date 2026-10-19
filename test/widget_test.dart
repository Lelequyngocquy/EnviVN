import 'package:flutter_test/flutter_test.dart';

import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/features/advisor/domain/entities/advisor_decision.dart';
import 'package:envivn/src/features/advisor/domain/entities/quick_prompt_type.dart';

void main() {
  test('EnviVN Smoke Test', () {
    expect(AQIHelper.getAQIInfo(25).category, AQICategory.good);
    expect(QuickPromptType.values.length, 4);
    expect(
      QuickPromptType.running.evaluate(
        aqi: 20,
        pm25: 5.0,
        temperature: 25.0,
        isRaining: true,
      ),
      AdvisorDecision.runningRainWarning,
    );
    expect(
      QuickPromptType.ventilation.evaluate(
        aqi: 20,
        pm25: 5.0,
        temperature: 25.0,
        isRaining: true,
      ),
      AdvisorDecision.ventilationOptimal,
    );
  });
}
