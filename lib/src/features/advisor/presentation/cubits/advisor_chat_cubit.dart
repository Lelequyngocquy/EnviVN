import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_location_entity.dart';
import '../../../../core/domain/entities/model_download_state.dart';
import '../../../../core/infrastructure/datasources/local/local_storage.dart';
import '../../../../core/infrastructure/services/context_prompt_builder.dart';
import '../../../../core/infrastructure/services/edge_ai_inference_service.dart';
import '../../../../core/infrastructure/services/model_download_service.dart';
import '../../../air_quality/domain/entities/air_quality_entity.dart';
import '../../../details/domain/entities/details_entity.dart';
import 'advisor_chat_state.dart';

class AdvisorChatCubit extends Cubit<AdvisorChatState> {
  final ModelDownloadService downloadService;
  final EdgeAiInferenceService inferenceService;
  final LocalStorage localStorage;

  StreamSubscription<ModelDownloadState>? _downloadSub;
  StreamSubscription<String>? _streamSub;
  String? _lastSystemPrompt;

  AdvisorChatCubit({
    required this.downloadService,
    required this.inferenceService,
    required this.localStorage,
  }) : super(AdvisorChatState(downloadState: downloadService.currentState)) {
    _downloadSub = downloadService.stateStream.listen((dState) {
      emit(state.copyWith(downloadState: dState));
    });
  }

  void toggleAi(bool enabled) {
    emit(state.copyWith(isAiEnabled: enabled));
  }

  Future<void> initChat({
    required AppLocationEntity location,
    required DetailsEntity weather,
    required AirQualityEntity airQuality,
  }) async {
    await downloadService.init();

    final isReady = await downloadService.isModelReady();
    if (!isReady) return;

    final hasEnoughRam = await inferenceService.hasEnoughRam();
    if (!hasEnoughRam) {
      emit(
        state.copyWith(
          errorMessage:
              'Thiết bị còn ít hơn 1.4 GB RAM trống. Vui lòng đóng bớt ứng dụng nền hoặc sử dụng chế độ Cố vấn Tiêu chuẩn.',
          isAiEnabled: false,
        ),
      );
      return;
    }

    final systemPrompt = ContextPromptBuilder.buildSystemPrompt(
      location: location,
      weather: weather,
      airQuality: airQuality,
    );
    _lastSystemPrompt = systemPrompt;

    try {
      await inferenceService.startChatSession(systemPrompt: systemPrompt);

      if (state.messages.isEmpty) {
        final greeting = ChatMessageItem(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          text:
              'Xin chào! Tôi là Trợ lý AI Gemma on-device của EnviVN. Tôi đã nạp toàn bộ dữ liệu môi trường và thời tiết tại ${location.displayName}. Bạn cần tôi tư vấn điều gì?',
          isUser: false,
          timestamp: DateTime.now(),
        );
        emit(state.copyWith(messages: [greeting]));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lỗi khởi chạy phiên AI: $e'));
    }
  }

  Future<void> startDownload() async {
    await downloadService.startDownload();
  }

  Future<void> pauseDownload() async {
    await downloadService.pauseDownload();
  }

  Future<void> resumeDownload() async {
    await downloadService.resumeDownload();
  }

  Future<void> cancelDownload() async {
    await downloadService.cancelDownload();
  }

  Future<void> deleteModel() async {
    await downloadService.deleteModel();
    emit(state.copyWith(messages: []));
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isStreaming) return;

    final userMsg = ChatMessageItem(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final botMsgId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
    final botMsg = ChatMessageItem(
      id: botMsgId,
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    final updatedMessages = List<ChatMessageItem>.from(state.messages)
      ..add(userMsg)
      ..add(botMsg);

    emit(
      state.copyWith(
        messages: updatedMessages,
        isStreaming: true,
        clearError: true,
      ),
    );

    final buffer = StringBuffer();
    final completer = Completer<void>();

    try {
      _streamSub?.cancel();
      _streamSub = inferenceService
          .sendMessageStream(trimmed)
          .listen(
            (chunk) {
              buffer.write(chunk);
              final currentList = List<ChatMessageItem>.from(state.messages);
              final index = currentList.indexWhere((m) => m.id == botMsgId);
              if (index != -1) {
                currentList[index] = currentList[index].copyWith(
                  text: buffer.toString(),
                );
                emit(state.copyWith(messages: currentList));
              }
            },
            onDone: () {
              final currentList = List<ChatMessageItem>.from(state.messages);
              final index = currentList.indexWhere((m) => m.id == botMsgId);
              if (index != -1) {
                currentList[index] = currentList[index].copyWith(
                  text: buffer.toString(),
                  isStreaming: false,
                );
                emit(state.copyWith(messages: currentList, isStreaming: false));
              }
              completer.complete();
            },
            onError: (e) {
              final fallbackReply =
                  ContextPromptBuilder.generateSimulatedResponse(
                    query: trimmed,
                    systemPrompt: _lastSystemPrompt ?? '',
                  );
              final currentList = List<ChatMessageItem>.from(state.messages);
              final index = currentList.indexWhere((m) => m.id == botMsgId);
              if (index != -1) {
                currentList[index] = currentList[index].copyWith(
                  text: buffer.isNotEmpty ? buffer.toString() : fallbackReply,
                  isStreaming: false,
                );
                emit(state.copyWith(messages: currentList, isStreaming: false));
              }
              completer.complete();
            },
            cancelOnError: true,
          );

      await completer.future;
    } catch (e) {
      final fallbackReply = ContextPromptBuilder.generateSimulatedResponse(
        query: trimmed,
        systemPrompt: _lastSystemPrompt ?? '',
      );
      final currentList = List<ChatMessageItem>.from(state.messages);
      final index = currentList.indexWhere((m) => m.id == botMsgId);
      if (index != -1) {
        currentList[index] = currentList[index].copyWith(
          text: fallbackReply,
          isStreaming: false,
        );
        emit(state.copyWith(messages: currentList, isStreaming: false));
      }
    }
  }

  void clearChat({
    required AppLocationEntity location,
    required DetailsEntity weather,
    required AirQualityEntity airQuality,
  }) {
    emit(state.copyWith(messages: []));
    initChat(location: location, weather: weather, airQuality: airQuality);
  }

  @override
  Future<void> close() {
    _downloadSub?.cancel();
    _streamSub?.cancel();
    return super.close();
  }
}
