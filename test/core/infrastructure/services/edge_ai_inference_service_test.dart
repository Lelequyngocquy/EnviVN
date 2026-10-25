import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/edge_ai_inference_service.dart';
import 'package:envivn/src/core/infrastructure/services/model_download_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late LocalStorage localStorage;
  late ModelDownloadService downloadService;
  late EdgeAiInferenceService inferenceService;
  late SimulatedGemmaBridge bridge;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorage(prefs: prefs);

    tempDir = Directory.systemTemp.createTempSync('edge_ai_test_');

    downloadService = ModelDownloadService(
      localStorage: localStorage,
      customDirectoryProvider: () async => tempDir,
    );

    bridge = SimulatedGemmaBridge();

    inferenceService = EdgeAiInferenceService(
      downloadService: downloadService,
      bridge: bridge,
    );
  });

  tearDown(() async {
    await inferenceService.dispose();
    downloadService.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('EdgeAiInferenceService Tests', () {
    test('initModel returns false when model file does not exist', () async {
      final success = await inferenceService.initModel();

      expect(success, isFalse);
      expect(inferenceService.isModelLoaded, isFalse);
    });

    test('initModel succeeds and loads model when file exists', () async {
      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(1024, 1));

      final success = await inferenceService.initModel();

      expect(success, isTrue);
      expect(inferenceService.isModelLoaded, isTrue);
      expect(await bridge.isModelInstalled(), isTrue);
    });

    test(
      'startChatSession and sendMessage return appropriate response',
      () async {
        final modelFile = await downloadService.getModelFile();
        modelFile.writeAsBytesSync(List.filled(1024, 1));

        const systemPrompt = '''[HỆ THỐNG CỐ VẤN MÔI TRƯỜNG ENVIVN]
- Vị trí: Đà Nẵng (16.0544, 108.2022)
- Thời tiết: 27.0°C, Độ ẩm 70%, Gió 15.0km/h, UV 4.0
- Chất lượng không khí: AQI 45 (Tốt (Trong lành)), PM2.5: 12.0 µg/m³
- Cảnh báo đặc biệt: Mưa 0.0mm, Nguy cơ ngập: Thấp''';

        await inferenceService.startChatSession(systemPrompt: systemPrompt);

        expect(inferenceService.isChatActive, isTrue);
        expect(inferenceService.currentSystemPrompt, equals(systemPrompt));

        final response = await inferenceService.sendMessage(
          'Tôi có nên chạy bộ không?',
        );

        expect(response, isNotEmpty);
        expect(response, contains('lý tưởng'));
      },
    );

    test('sendMessageStream yields chunks asynchronously', () async {
      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(1024, 1));

      const systemPrompt = '''[HỆ THỐNG CỐ VẤN MÔI TRƯỜNG ENVIVN]
- Vị trí: TP. Hồ Chí Minh (10.7769, 106.7009)
- Thời tiết: 33.0°C, Độ ẩm 80%, Gió 8.0km/h, UV 9.0
- Chất lượng không khí: AQI 60 (Trung bình (Chấp nhận được)), PM2.5: 22.0 µg/m³
- Cảnh báo đặc biệt: Mưa 0.0mm, Nguy cơ ngập: Thấp''';

      await inferenceService.startChatSession(systemPrompt: systemPrompt);

      final chunks = <String>[];
      await for (final token in inferenceService.sendMessageStream(
        'Trẻ nhỏ ra ngoài được không?',
      )) {
        chunks.add(token);
      }

      expect(chunks.length, greaterThan(1));
      final fullText = chunks.join();
      expect(fullText, contains('an toàn cho trẻ nhỏ'));
    });

    test(
      'resetChatSession updates system prompt and maintains active chat',
      () async {
        final modelFile = await downloadService.getModelFile();
        modelFile.writeAsBytesSync(List.filled(1024, 1));

        await inferenceService.startChatSession(systemPrompt: 'prompt1');
        expect(inferenceService.currentSystemPrompt, equals('prompt1'));

        await inferenceService.resetChatSession(newSystemPrompt: 'prompt2');
        expect(inferenceService.currentSystemPrompt, equals('prompt2'));
        expect(inferenceService.isChatActive, isTrue);
      },
    );

    test(
      'sendMessage throws StateError when chat session is not started',
      () async {
        expect(() => inferenceService.sendMessage('test'), throwsStateError);
      },
    );

    test('dispose cleans up chat and model states', () async {
      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(1024, 1));

      await inferenceService.startChatSession(systemPrompt: 'prompt');
      await inferenceService.dispose();

      expect(inferenceService.isChatActive, isFalse);
      expect(inferenceService.isModelLoaded, isFalse);
    });

    test(
      'hasEnoughRam evaluates RAM thresholds correctly with custom provider',
      () async {
        final highRamService = EdgeAiInferenceService(
          downloadService: downloadService,
          bridge: bridge,
          customRamProvider: () async => 2000 * 1024 * 1024,
        );
        expect(await highRamService.hasEnoughRam(), isTrue);

        final lowRamService = EdgeAiInferenceService(
          downloadService: downloadService,
          bridge: bridge,
          customRamProvider: () async => 1000 * 1024 * 1024,
        );
        expect(await lowRamService.hasEnoughRam(), isFalse);
      },
    );

    test('initModel fails when RAM is less than required 1.4 GB', () async {
      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(1024, 1));

      final lowRamService = EdgeAiInferenceService(
        downloadService: downloadService,
        bridge: bridge,
        customRamProvider: () async => 800 * 1024 * 1024,
      );

      final success = await lowRamService.initModel();
      expect(success, isFalse);
      expect(lowRamService.isModelLoaded, isFalse);
    });

    test(
      'startChatSession throws StateError when available RAM is below 1.4 GB',
      () async {
        final modelFile = await downloadService.getModelFile();
        modelFile.writeAsBytesSync(List.filled(1024, 1));

        final lowRamService = EdgeAiInferenceService(
          downloadService: downloadService,
          bridge: bridge,
          customRamProvider: () async => 800 * 1024 * 1024,
        );

        expect(
          () => lowRamService.startChatSession(systemPrompt: 'test'),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('RAM'),
            ),
          ),
        );
      },
    );
  });
}
