import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/quick_prompt_type.dart';
import 'advisor_state.dart';

class AdvisorCubit extends Cubit<AdvisorState> {
  AdvisorCubit() : super(const AdvisorState());

  
  void selectPrompt(
    QuickPromptType prompt, {
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
    emit(state.copyWith(
      status: AdvisorStatus.loading,
      selectedPrompt: prompt,
    ));

    
    final decision = prompt.evaluate(
      aqi: aqi,
      pm25: pm25,
      temperature: temperature,
      uvIndex: uvIndex,
      hasRespiratoryCondition: hasRespiratoryCondition,
      isRaining: isRaining,
      rainProbability: rainProbability,
      precipitation: precipitation,
      weatherCode: weatherCode,
    );

    emit(state.copyWith(
      status: AdvisorStatus.success,
      decision: decision,
    ));
  }

  void reset() {
    emit(const AdvisorState());
  }
}
