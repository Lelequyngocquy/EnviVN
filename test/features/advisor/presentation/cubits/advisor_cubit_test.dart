import 'package:flutter_test/flutter_test.dart';
import 'package:envivn/src/features/advisor/domain/entities/quick_prompt_type.dart';
import 'package:envivn/src/features/advisor/domain/entities/advisor_decision.dart';
import 'package:envivn/src/features/advisor/presentation/cubits/advisor_cubit.dart';
import 'package:envivn/src/features/advisor/presentation/cubits/advisor_state.dart';

void main() {
  late AdvisorCubit cubit;

  setUp(() {
    cubit = AdvisorCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('AdvisorCubit Tests', () {
    test('initial state has initial status and no decision', () {
      expect(cubit.state.status, equals(AdvisorStatus.initial));
      expect(cubit.state.decision, isNull);
      expect(cubit.state.selectedPrompt, isNull);
    });

    test('selectPrompt evaluates decision accurately and emits success', () {
      cubit.selectPrompt(
        QuickPromptType.running,
        aqi: 45,
        pm25: 12.0,
        temperature: 26.0,
        uvIndex: 4.0,
      );

      expect(cubit.state.status, equals(AdvisorStatus.success));
      expect(cubit.state.selectedPrompt, equals(QuickPromptType.running));
      expect(cubit.state.decision, isNotNull);
      expect(cubit.state.decision!.headline, isNotEmpty);
      expect(cubit.state.decision, equals(AdvisorDecision.runningIdeal));
    });

    test('selectPrompt for rain condition flags adverse weather', () {
      cubit.selectPrompt(
        QuickPromptType.running,
        aqi: 35,
        pm25: 10.0,
        temperature: 24.0,
        isRaining: true,
        precipitation: 15.0,
      );

      expect(cubit.state.status, equals(AdvisorStatus.success));
      expect(cubit.state.decision, equals(AdvisorDecision.runningRainWarning));
    });

    test('reset resets state back to initial', () {
      cubit.selectPrompt(
        QuickPromptType.ventilation,
        aqi: 50,
        pm25: 15.0,
        temperature: 28.0,
      );
      expect(cubit.state.status, equals(AdvisorStatus.success));

      cubit.reset();
      expect(cubit.state.status, equals(AdvisorStatus.initial));
      expect(cubit.state.decision, isNull);
    });
  });
}
