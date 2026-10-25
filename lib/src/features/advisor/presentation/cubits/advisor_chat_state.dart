import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/model_download_state.dart';
import '../../../../core/infrastructure/services/context_prompt_builder.dart';

class ChatMessageItem extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  const ChatMessageItem({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessageItem copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return ChatMessageItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [id, text, isUser, timestamp, isStreaming];
}

class AdvisorChatState extends Equatable {
  final bool isAiEnabled;
  final ModelDownloadState downloadState;
  final List<ChatMessageItem> messages;
  final bool isStreaming;
  final String? errorMessage;
  final List<String> suggestedQuestions;

  const AdvisorChatState({
    this.isAiEnabled = false,
    this.downloadState = const ModelDownloadState(),
    this.messages = const [],
    this.isStreaming = false,
    this.errorMessage,
    this.suggestedQuestions = ContextPromptBuilder.defaultSuggestedQuestions,
  });

  AdvisorChatState copyWith({
    bool? isAiEnabled,
    ModelDownloadState? downloadState,
    List<ChatMessageItem>? messages,
    bool? isStreaming,
    String? errorMessage,
    bool clearError = false,
    List<String>? suggestedQuestions,
  }) {
    return AdvisorChatState(
      isAiEnabled: isAiEnabled ?? this.isAiEnabled,
      downloadState: downloadState ?? this.downloadState,
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
    );
  }

  @override
  List<Object?> get props => [
    isAiEnabled,
    downloadState,
    messages,
    isStreaming,
    errorMessage,
    suggestedQuestions,
  ];
}
