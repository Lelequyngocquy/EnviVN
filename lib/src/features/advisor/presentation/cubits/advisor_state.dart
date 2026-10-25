import 'package:equatable/equatable.dart';

import '../../domain/entities/advisor_decision.dart';
import '../../domain/entities/quick_prompt_type.dart';

enum AdvisorStatus { initial, loading, success }

class AdvisorState extends Equatable {
  final AdvisorStatus status;
  final List<QuickPromptType> availablePrompts;
  final QuickPromptType? selectedPrompt;
  final AdvisorDecision? decision;

  const AdvisorState({
    this.status = AdvisorStatus.initial,
    this.availablePrompts = QuickPromptType.values,
    this.selectedPrompt,
    this.decision,
  });

  AdvisorState copyWith({
    AdvisorStatus? status,
    List<QuickPromptType>? availablePrompts,
    QuickPromptType? selectedPrompt,
    AdvisorDecision? decision,
    bool clearDecision = false,
  }) {
    return AdvisorState(
      status: status ?? this.status,
      availablePrompts: availablePrompts ?? this.availablePrompts,
      selectedPrompt: selectedPrompt ?? this.selectedPrompt,
      decision: clearDecision ? null : (decision ?? this.decision),
    );
  }

  @override
  List<Object?> get props => [
    status,
    availablePrompts,
    selectedPrompt,
    decision,
  ];
}
