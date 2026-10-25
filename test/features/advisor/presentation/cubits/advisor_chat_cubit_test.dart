import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/core/domain/entities/model_download_state.dart';
import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/edge_ai_inference_service.dart';
import 'package:envivn/src/core/infrastructure/services/model_download_service.dart';
import 'package:envivn/src/features/advisor/presentation/cubits/advisor_chat_cubit.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late LocalStorage localStorage;
  late ModelDownloadService downloadService;
  late EdgeAiInferenceService inferenceService;
  late SimulatedGemmaBridge bridge;
  late AdvisorChatCubit chatCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorage(prefs: prefs);

    tempDir = Directory.systemTemp.createTempSync('advisor_chat_test_');

    downloadService = ModelDownloadService(
      localStorage: localStorage,
      customDirectoryProvider: () async => tempDir,
    );

    bridge = SimulatedGemmaBridge();

    inferenceService = EdgeAiInferenceService(
      downloadService: downloadService,
      bridge: bridge,
    );

    chatCubit = AdvisorChatCubit(
      downloadService: downloadService,
      inferenceService: inferenceService,
      localStorage: localStorage,
    );
  });

  tearDown(() async {
    await chatCubit.close();
    await inferenceService.dispose();
    downloadService.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AdvisorChatCubit Tests', () {
    test('initial state has isAiEnabled false and default questions', () {
      expect(chatCubit.state.isAiEnabled, isFalse);
      expect(chatCubit.state.messages, isEmpty);
      expect(chatCubit.state.suggestedQuestions, isNotEmpty);
    });

    test('toggleAi toggles AI enabled status', () {
      chatCubit.toggleAi(true);
      expect(chatCubit.state.isAiEnabled, isTrue);

      chatCubit.toggleAi(false);
      expect(chatCubit.state.isAiEnabled, isFalse);
    });

    test('initChat populates welcome message when model is ready', () async {
      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(1024, 1));
      await downloadService.init();

      final location = AppLocationEntity.city(
        name: 'Hà Nội',
        province: 'Hà Nội',
        latitude: 21.0285,
        longitude: 105.8542,
      );

      const weather = DetailsEntity(currentTemp: 28.0, relativeHumidity: 65);

      const airQuality = AirQualityEntity(usAqi: 75, pm25: 25.0);

      await chatCubit.initChat(
        location: location,
        weather: weather,
        airQuality: airQuality,
      );

      expect(chatCubit.state.messages.length, equals(1));
      expect(chatCubit.state.messages.first.isUser, isFalse);
      expect(chatCubit.state.messages.first.text, contains('Hà Nội'));
    });

    test(
      'sendMessage appends user message and receives streamed bot response',
      () async {
        final modelFile = await downloadService.getModelFile();
        modelFile.writeAsBytesSync(List.filled(1024, 1));
        await downloadService.init();

        final location = AppLocationEntity.city(
          name: 'Đà Nẵng',
          province: 'Đà Nẵng',
          latitude: 16.0544,
          longitude: 108.2022,
        );

        await chatCubit.initChat(
          location: location,
          weather: const DetailsEntity(currentTemp: 26.0),
          airQuality: const AirQualityEntity(usAqi: 40),
        );

        await chatCubit.sendMessage('Có nên chạy bộ không?');

        expect(chatCubit.state.messages.length, equals(3));
        expect(chatCubit.state.messages[1].isUser, isTrue);
        expect(
          chatCubit.state.messages[1].text,
          equals('Có nên chạy bộ không?'),
        );

        final botMessage = chatCubit.state.messages[2];
        expect(botMessage.isUser, isFalse);
        expect(botMessage.isStreaming, isFalse);
        expect(botMessage.text, contains('chạy bộ'));
      },
    );

    test('clearChat resets messages and re-initializes chat session', () async {
      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(1024, 1));
      await downloadService.init();

      final location = AppLocationEntity.city(
        name: 'TP. Hồ Chí Minh',
        province: 'TP. Hồ Chí Minh',
        latitude: 10.7769,
        longitude: 106.7009,
      );

      await chatCubit.initChat(
        location: location,
        weather: const DetailsEntity(),
        airQuality: const AirQualityEntity(),
      );

      await chatCubit.sendMessage('Xin chào');
      expect(chatCubit.state.messages.length, greaterThanOrEqualTo(2));

      chatCubit.clearChat(
        location: location,
        weather: const DetailsEntity(),
        airQuality: const AirQualityEntity(),
      );

      await pumpEventQueue();

      expect(chatCubit.state.messages.length, equals(1));
    });

    test('download lifecycle delegation updates downloadState', () async {
      expect(
        chatCubit.state.downloadState.status,
        equals(ModelDownloadStatus.notDownloaded),
      );

      final tempFile = await downloadService.getTempDownloadFile();
      tempFile.writeAsBytesSync(List.filled(2048, 5));
      await downloadService.init();

      await pumpEventQueue();

      expect(
        chatCubit.state.downloadState.status,
        equals(ModelDownloadStatus.paused),
      );
    });

    test(
      'initChat switches isAiEnabled to false and emits warning if RAM < 1.4 GB',
      () async {
        final lowRamInference = EdgeAiInferenceService(
          downloadService: downloadService,
          bridge: bridge,
          customRamProvider: () async => 800 * 1024 * 1024,
        );

        final cubit = AdvisorChatCubit(
          downloadService: downloadService,
          inferenceService: lowRamInference,
          localStorage: localStorage,
        );

        final modelFile = await downloadService.getModelFile();
        modelFile.writeAsBytesSync(List.filled(1024, 1));
        await downloadService.init();

        cubit.toggleAi(true);
        expect(cubit.state.isAiEnabled, isTrue);

        await cubit.initChat(
          location: AppLocationEntity.city(
            name: 'Hà Nội',
            province: 'Hà Nội',
            latitude: 21.0,
            longitude: 105.0,
          ),
          weather: const DetailsEntity(),
          airQuality: const AirQualityEntity(),
        );

        expect(cubit.state.isAiEnabled, isFalse);
        expect(cubit.state.errorMessage, contains('1.4 GB RAM'));

        await cubit.close();
        await lowRamInference.dispose();
      },
    );
  });
}
