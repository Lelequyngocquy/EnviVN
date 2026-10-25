import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envivn/src/core/domain/entities/model_download_state.dart';
import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/model_download_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorage localStorage;
  late Directory testDir;
  late ModelDownloadService downloadService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorage(prefs: prefs);

    testDir = Directory.systemTemp.createTempSync('model_download_test_');

    downloadService = ModelDownloadService(
      localStorage: localStorage,
      customDirectoryProvider: () async => testDir,
    );
  });

  tearDown(() {
    downloadService.dispose();
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true);
    }
  });

  group('ModelDownloadState Tests', () {
    test('formatters format bytes, speeds and progress correctly', () {
      const state = ModelDownloadState(
        status: ModelDownloadStatus.downloading,
        downloadedBytes: 500 * 1024 * 1024,
        totalBytes: 1000 * 1024 * 1024,
        progress: 0.5,
        speedBytesPerSec: 15 * 1024 * 1024,
      );

      expect(state.formattedProgress, equals('50.0%'));
      expect(state.formattedDownloadedSize, equals('500.0 MB'));
      expect(state.formattedTotalSize, equals('1000.0 MB'));
      expect(state.formattedSpeed, equals('15.0 MB/s'));
      expect(state.isDownloading, isTrue);
      expect(state.isReady, isFalse);
    });

    test('formatters handle gigabytes correctly', () {
      const state = ModelDownloadState(
        status: ModelDownloadStatus.ready,
        downloadedBytes: 1536 * 1024 * 1024,
        totalBytes: 1536 * 1024 * 1024,
        progress: 1.0,
        speedBytesPerSec: 800 * 1024,
      );

      expect(state.formattedProgress, equals('100.0%'));
      expect(state.formattedDownloadedSize, equals('1.50 GB'));
      expect(state.formattedTotalSize, equals('1.50 GB'));
      expect(state.formattedSpeed, equals('800.0 KB/s'));
      expect(state.isReady, isTrue);
    });
  });

  group('ModelDownloadService Lifecycle Tests', () {
    test('init sets status to notDownloaded when no files exist', () async {
      await downloadService.init();

      expect(
        downloadService.currentState.status,
        equals(ModelDownloadStatus.notDownloaded),
      );
      expect(localStorage.isAiModelDownloaded(), isFalse);
    });

    test('init sets status to ready when model file exists', () async {
      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(2048, 1));

      await downloadService.init();

      expect(
        downloadService.currentState.status,
        equals(ModelDownloadStatus.ready),
      );
      expect(downloadService.currentState.progress, equals(1.0));
      expect(downloadService.currentState.downloadedBytes, equals(2048));
      expect(localStorage.isAiModelDownloaded(), isTrue);
    });

    test(
      'init sets status to paused when partial temp download file exists',
      () async {
        final tempFile = await downloadService.getTempDownloadFile();
        tempFile.writeAsBytesSync(List.filled(4096, 2));

        await downloadService.init();

        expect(
          downloadService.currentState.status,
          equals(ModelDownloadStatus.paused),
        );
        expect(downloadService.currentState.downloadedBytes, equals(4096));
        expect(downloadService.currentState.isPaused, isTrue);
      },
    );

    test(
      'startDownload consumes stream, saves model info and transitions to ready',
      () async {
        final streamController = StreamController<List<int>>();
        final mockData = List.generate(10, (i) => List.filled(1024, i));

        final downloadFuture = downloadService.startDownload(
          mockStream: streamController.stream,
          mockContentLength: 10240,
        );

        for (final chunk in mockData) {
          streamController.add(chunk);
        }
        await streamController.close();
        await downloadFuture;

        expect(
          downloadService.currentState.status,
          equals(ModelDownloadStatus.ready),
        );
        expect(downloadService.currentState.progress, equals(1.0));
        expect(downloadService.currentState.downloadedBytes, equals(10240));

        final modelFile = await downloadService.getModelFile();
        expect(modelFile.existsSync(), isTrue);
        expect(modelFile.lengthSync(), equals(10240));

        expect(localStorage.isAiModelDownloaded(), isTrue);
        expect(localStorage.getAiModelPath(), equals(modelFile.path));
        expect(localStorage.getAiModelSize(), equals(10240));
      },
    );

    test(
      'pauseDownload cancels ongoing stream and updates status to paused',
      () async {
        final streamController = StreamController<List<int>>();
        final downloadFuture = downloadService.startDownload(
          mockStream: streamController.stream,
          mockContentLength: 50000,
        );

        streamController.add(List.filled(5000, 1));
        await Future.delayed(const Duration(milliseconds: 50));

        await downloadService.pauseDownload();
        await streamController.close();
        await downloadFuture;

        expect(
          downloadService.currentState.status,
          equals(ModelDownloadStatus.paused),
        );
        expect(downloadService.currentState.downloadedBytes, equals(5000));

        final tempFile = await downloadService.getTempDownloadFile();
        expect(tempFile.existsSync(), isTrue);
      },
    );

    test('cancelDownload deletes partial temp file and resets state', () async {
      final tempFile = await downloadService.getTempDownloadFile();
      tempFile.writeAsBytesSync(List.filled(1000, 3));

      await downloadService.cancelDownload();

      expect(
        downloadService.currentState.status,
        equals(ModelDownloadStatus.notDownloaded),
      );
      expect(tempFile.existsSync(), isFalse);
    });

    test(
      'deleteModel removes model file, temp file and clears LocalStorage',
      () async {
        final modelFile = await downloadService.getModelFile();
        modelFile.writeAsBytesSync(List.filled(1024, 7));
        await localStorage.saveAiModelInfo(
          path: modelFile.path,
          sizeBytes: 1024,
        );

        final tempFile = await downloadService.getTempDownloadFile();
        tempFile.writeAsBytesSync(List.filled(512, 8));

        await downloadService.deleteModel();

        expect(
          downloadService.currentState.status,
          equals(ModelDownloadStatus.notDownloaded),
        );
        expect(modelFile.existsSync(), isFalse);
        expect(tempFile.existsSync(), isFalse);
        expect(localStorage.isAiModelDownloaded(), isFalse);
        expect(localStorage.getAiModelPath(), isNull);
      },
    );

    test('isModelReady returns true only when model exists on disk', () async {
      expect(await downloadService.isModelReady(), isFalse);

      final modelFile = await downloadService.getModelFile();
      modelFile.writeAsBytesSync(List.filled(100, 1));
      await downloadService.init();

      expect(await downloadService.isModelReady(), isTrue);
    });

    test(
      'calculateFileSha256 and verifyFileChecksum validate file hash correctly',
      () async {
        final testFile = File('${testDir.path}/test_hash.bin');
        final data = [1, 2, 3, 4, 5];
        testFile.writeAsBytesSync(data);

        final sha = await downloadService.calculateFileSha256(testFile);
        expect(sha, isNotEmpty);

        final isValid = await downloadService.verifyFileChecksum(
          file: testFile,
          expectedSha256: sha,
        );
        expect(isValid, isTrue);

        final isInvalid = await downloadService.verifyFileChecksum(
          file: testFile,
          expectedSha256: 'deadbeef12345678',
        );
        expect(isInvalid, isFalse);
      },
    );

    test(
      'startDownload with valid expectedSha256 finishes and transitions to ready',
      () async {
        final streamController = StreamController<List<int>>();
        final mockData = List.filled(1024, 9);
        final tempCalc = File('${testDir.path}/temp_calc.bin');
        tempCalc.writeAsBytesSync(mockData);
        final validHash = await downloadService.calculateFileSha256(tempCalc);
        tempCalc.deleteSync();

        final downloadFuture = downloadService.startDownload(
          mockStream: streamController.stream,
          mockContentLength: 1024,
          expectedSha256: validHash,
        );

        streamController.add(mockData);
        await streamController.close();
        await downloadFuture;

        expect(
          downloadService.currentState.status,
          equals(ModelDownloadStatus.ready),
        );
        expect(downloadService.currentState.progress, equals(1.0));
        final modelFile = await downloadService.getModelFile();
        expect(modelFile.existsSync(), isTrue);
      },
    );

    test(
      'startDownload with mismatched expectedSha256 fails with error status',
      () async {
        final streamController = StreamController<List<int>>();
        final mockData = List.filled(1024, 7);

        final downloadFuture = downloadService.startDownload(
          mockStream: streamController.stream,
          mockContentLength: 1024,
          expectedSha256: 'incorrect_sha256_hash_here',
        );

        streamController.add(mockData);
        await streamController.close();
        await downloadFuture;

        expect(
          downloadService.currentState.status,
          equals(ModelDownloadStatus.error),
        );
        expect(downloadService.currentState.errorMessage, contains('SHA256'));
        final modelFile = await downloadService.getModelFile();
        expect(modelFile.existsSync(), isFalse);
      },
    );

    test(
      'throttling ensures emissions are throttled for high frequency chunks',
      () async {
        final streamController = StreamController<List<int>>();
        final emittedStates = <ModelDownloadState>[];
        final sub = downloadService.stateStream.listen(emittedStates.add);

        const totalChunks = 100;
        const chunkSize = 500;
        final downloadFuture = downloadService.startDownload(
          mockStream: streamController.stream,
          mockContentLength: 1000 * 1000,
        );

        for (int i = 0; i < totalChunks; i++) {
          streamController.add(List.filled(chunkSize, 1));
        }
        await streamController.close();
        await downloadFuture;
        await sub.cancel();

        expect(
          downloadService.currentState.status,
          equals(ModelDownloadStatus.ready),
        );
        final downloadingStates = emittedStates
            .where((s) => s.status == ModelDownloadStatus.downloading)
            .length;
        expect(downloadingStates, lessThan(30));
      },
    );
  });
}
