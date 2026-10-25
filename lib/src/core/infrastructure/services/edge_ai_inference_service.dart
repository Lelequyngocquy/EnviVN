import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'context_prompt_builder.dart';
import 'model_download_service.dart';

abstract class IGemmaBridge {
  Future<bool> isModelInstalled();
  Future<void> setModelPath(String path);
  Future<void> createModel({required bool isInstructionTuned, int maxTokens});
  Future<void> createChatSession({String? systemPrompt});
  Stream<String> generateResponseAsync(String message);
  Future<String> generateResponse(String message);
  Future<void> close();
}

class FlutterGemmaBridge implements IGemmaBridge {
  InferenceModel? _model;
  InferenceChat? _chat;

  @override
  Future<bool> isModelInstalled() async {
    try {
      return await FlutterGemmaPlugin.instance.modelManager.isModelInstalled;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setModelPath(String path) async {
    await FlutterGemmaPlugin.instance.modelManager.setModelPath(path);
  }

  @override
  Future<void> createModel({
    required bool isInstructionTuned,
    int maxTokens = 2048,
  }) async {
    await _model?.close();
    _model = await FlutterGemmaPlugin.instance.createModel(
      isInstructionTuned: isInstructionTuned,
      maxTokens: maxTokens,
    );
  }

  @override
  Future<void> createChatSession({String? systemPrompt}) async {
    if (_model == null) {
      throw StateError('Model must be created before starting a chat session');
    }
    _chat = await _model!.createChat(temperature: 0.7);
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      await _chat!.addQueryChunk(Message(text: systemPrompt, isUser: false));
    }
  }

  @override
  Stream<String> generateResponseAsync(String message) async* {
    if (_chat == null) {
      throw StateError('Chat session is not active');
    }
    await _chat!.addQueryChunk(Message(text: message, isUser: true));
    yield* _chat!.generateChatResponseAsync();
  }

  @override
  Future<String> generateResponse(String message) async {
    if (_chat == null) {
      throw StateError('Chat session is not active');
    }
    await _chat!.addQueryChunk(Message(text: message, isUser: true));
    return await _chat!.generateChatResponse();
  }

  @override
  Future<void> close() async {
    await _chat?.session.close();
    _chat = null;
    await _model?.close();
    _model = null;
  }
}

class SimulatedGemmaBridge implements IGemmaBridge {
  String? _currentSystemPrompt;
  bool _isInstalled = false;
  bool _isModelCreated = false;
  bool _isChatActive = false;

  @override
  Future<bool> isModelInstalled() async => _isInstalled;

  @override
  Future<void> setModelPath(String path) async {
    _isInstalled = true;
  }

  @override
  Future<void> createModel({
    required bool isInstructionTuned,
    int maxTokens = 2048,
  }) async {
    _isModelCreated = true;
  }

  @override
  Future<void> createChatSession({String? systemPrompt}) async {
    if (!_isModelCreated) {
      throw StateError('Model must be created before starting a chat session');
    }
    _currentSystemPrompt = systemPrompt;
    _isChatActive = true;
  }

  @override
  Stream<String> generateResponseAsync(String message) async* {
    if (!_isChatActive) {
      throw StateError('Chat session is not active');
    }
    final full = ContextPromptBuilder.generateSimulatedResponse(
      query: message,
      systemPrompt: _currentSystemPrompt ?? '',
    );
    final words = full.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      yield i == 0 ? words[i] : ' ${words[i]}';
    }
  }

  @override
  Future<String> generateResponse(String message) async {
    if (!_isChatActive) {
      throw StateError('Chat session is not active');
    }
    return ContextPromptBuilder.generateSimulatedResponse(
      query: message,
      systemPrompt: _currentSystemPrompt ?? '',
    );
  }

  @override
  Future<void> close() async {
    _isChatActive = false;
    _isModelCreated = false;
  }
}

class EdgeAiInferenceService {
  final ModelDownloadService downloadService;
  final IGemmaBridge _bridge;
  final Future<int> Function()? customRamProvider;

  static const MethodChannel _memoryChannel = MethodChannel(
    'vn.envi.app/disk_space',
  );
  static const int requiredFreeRamBytes = 1400 * 1024 * 1024;

  bool _isModelLoaded = false;
  bool _isChatActive = false;
  String? _currentSystemPrompt;

  EdgeAiInferenceService({
    required this.downloadService,
    IGemmaBridge? bridge,
    this.customRamProvider,
  }) : _bridge =
           bridge ??
           ((defaultTargetPlatform == TargetPlatform.android ||
                       defaultTargetPlatform == TargetPlatform.iOS) &&
                   !kIsWeb
               ? FlutterGemmaBridge()
               : SimulatedGemmaBridge());

  bool get isModelLoaded => _isModelLoaded;
  bool get isChatActive => _isChatActive;
  String? get currentSystemPrompt => _currentSystemPrompt;

  Future<int> getAvailableRamBytes() async {
    if (customRamProvider != null) {
      return await customRamProvider!();
    }
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bytes = await _memoryChannel
            .invokeMethod<int>('getAvailableRamBytes')
            .timeout(
              const Duration(milliseconds: 500),
              onTimeout: () => 3 * 1024 * 1024 * 1024,
            );
        if (bytes != null && bytes > 0) return bytes;
      }
      return 3 * 1024 * 1024 * 1024;
    } catch (_) {
      return 3 * 1024 * 1024 * 1024;
    }
  }

  Future<bool> hasEnoughRam({int requiredBytes = requiredFreeRamBytes}) async {
    final available = await getAvailableRamBytes();
    return available >= requiredBytes;
  }

  Future<bool> initModel({String? customPath}) async {
    try {
      final hasRam = await hasEnoughRam();
      if (!hasRam) {
        _isModelLoaded = false;
        return false;
      }

      String? path = customPath;
      if (path == null) {
        final modelFile = await downloadService.getModelFile();
        if (modelFile.existsSync() && modelFile.lengthSync() > 0) {
          path = modelFile.path;
        }
      }

      if (path == null || !File(path).existsSync()) {
        return false;
      }

      await _bridge.setModelPath(path);
      await _bridge.createModel(isInstructionTuned: true, maxTokens: 2048);
      _isModelLoaded = true;
      return true;
    } catch (_) {
      _isModelLoaded = false;
      return false;
    }
  }

  Future<void> startChatSession({required String systemPrompt}) async {
    final hasRam = await hasEnoughRam();
    if (!hasRam) {
      throw StateError(
        'Thiết bị không đủ RAM trống để khởi chạy mô hình AI (cần tối thiểu 1.4 GB).',
      );
    }
    if (!_isModelLoaded) {
      final initialized = await initModel();
      if (!initialized) {
        throw StateError('Model is not installed or downloaded yet.');
      }
    }
    _currentSystemPrompt = systemPrompt;
    await _bridge.createChatSession(systemPrompt: systemPrompt);
    _isChatActive = true;
  }

  Stream<String> sendMessageStream(String userMessage) async* {
    if (!_isChatActive) {
      throw StateError('Please call startChatSession before sending messages.');
    }
    yield* _bridge.generateResponseAsync(userMessage);
  }

  Future<String> sendMessage(String userMessage) async {
    if (!_isChatActive) {
      throw StateError('Please call startChatSession before sending messages.');
    }
    return await _bridge.generateResponse(userMessage);
  }

  Future<void> resetChatSession({String? newSystemPrompt}) async {
    final prompt = newSystemPrompt ?? _currentSystemPrompt;
    await _bridge.createChatSession(systemPrompt: prompt);
    _currentSystemPrompt = prompt;
    _isChatActive = true;
  }

  Future<void> dispose() async {
    _isChatActive = false;
    _isModelLoaded = false;
    await _bridge.close();
  }
}
