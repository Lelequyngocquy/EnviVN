import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/model_download_state.dart';
import '../configs/env_config.dart';
import '../datasources/local/local_storage.dart';

class ModelDownloadService {
  final LocalStorage localStorage;
  final http.Client client;
  final Future<Directory> Function()? customDirectoryProvider;

  static const MethodChannel _diskChannel = MethodChannel(
    'vn.envi.app/disk_space',
  );
  static const int requiredFreeDiskSpaceBytes = 1500 * 1024 * 1024;

  final StreamController<ModelDownloadState> _stateController =
      StreamController<ModelDownloadState>.broadcast();
  ModelDownloadState _currentState = const ModelDownloadState();

  StreamSubscription<List<int>>? _downloadSubscription;
  IOSink? _fileSink;
  Completer<void>? _streamCompleter;
  bool _isPaused = false;
  int _lastBytesSnapshot = 0;
  DateTime _lastSpeedCalcTime = DateTime.now();

  ModelDownloadService({
    required this.localStorage,
    http.Client? client,
    this.customDirectoryProvider,
  }) : client = client ?? http.Client();

  Stream<ModelDownloadState> get stateStream => _stateController.stream;
  ModelDownloadState get currentState => _currentState;

  void _emitState(ModelDownloadState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<Directory> getModelDirectory() async {
    if (customDirectoryProvider != null) {
      final dir = await customDirectoryProvider!();
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/models/gemma_2_2b');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> getModelFile() async {
    final dir = await getModelDirectory();
    return File('${dir.path}/${EnvConfig.gemmaModelFileName}');
  }

  Future<File> getTempDownloadFile() async {
    final dir = await getModelDirectory();
    return File('${dir.path}/${EnvConfig.gemmaModelFileName}.download');
  }

  Future<int> getAvailableDiskSpaceBytes() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bytes = await _diskChannel
            .invokeMethod<int>('getAvailableDiskSpaceBytes')
            .timeout(
              const Duration(milliseconds: 500),
              onTimeout: () => 10 * 1024 * 1024 * 1024,
            );
        if (bytes != null && bytes > 0) return bytes;
      }
      return 10 * 1024 * 1024 * 1024;
    } catch (_) {
      return 10 * 1024 * 1024 * 1024;
    }
  }

  Future<bool> hasEnoughDiskSpace({
    int requiredBytes = requiredFreeDiskSpaceBytes,
  }) async {
    final available = await getAvailableDiskSpaceBytes();
    return available >= requiredBytes;
  }

  Future<String> calculateFileSha256(File file) async {
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }

  Future<bool> verifyFileChecksum({
    required File file,
    String? expectedSha256,
  }) async {
    if (expectedSha256 == null || expectedSha256.isEmpty) {
      return true;
    }
    final hash = await calculateFileSha256(file);
    return hash.toLowerCase() == expectedSha256.toLowerCase();
  }

  Future<void> init() async {
    try {
      final modelFile = await getModelFile();
      final tempFile = await getTempDownloadFile();

      if (modelFile.existsSync() && modelFile.lengthSync() > 0) {
        final size = modelFile.lengthSync();
        await localStorage.saveAiModelInfo(
          path: modelFile.path,
          sizeBytes: size,
        );
        _emitState(
          ModelDownloadState(
            status: ModelDownloadStatus.ready,
            modelPath: modelFile.path,
            downloadedBytes: size,
            totalBytes: size,
            progress: 1.0,
          ),
        );
        return;
      }

      if (tempFile.existsSync() && tempFile.lengthSync() > 0) {
        final existing = tempFile.lengthSync();
        final expected =
            localStorage.getAiModelSize() ??
            EnvConfig.gemmaModelExpectedSizeBytes;
        final progress = expected > 0
            ? (existing / expected).clamp(0.0, 1.0)
            : 0.0;
        _emitState(
          ModelDownloadState(
            status: ModelDownloadStatus.paused,
            modelPath: null,
            downloadedBytes: existing,
            totalBytes: expected,
            progress: progress,
          ),
        );
        return;
      }

      await localStorage.clearAiModelInfo();
      _emitState(
        const ModelDownloadState(status: ModelDownloadStatus.notDownloaded),
      );
    } catch (e) {
      _emitState(
        ModelDownloadState(
          status: ModelDownloadStatus.error,
          errorMessage: 'Lỗi khởi tạo dịch vụ tải: $e',
        ),
      );
    }
  }

  Future<void> startDownload({
    String? customUrl,
    Stream<List<int>>? mockStream,
    int? mockContentLength,
    String? expectedSha256,
  }) async {
    if (_currentState.isDownloading) return;

    _emitState(
      _currentState.copyWith(
        status: ModelDownloadStatus.checkingDisk,
        clearError: true,
      ),
    );

    final availableDisk = await getAvailableDiskSpaceBytes();
    if (availableDisk < requiredFreeDiskSpaceBytes) {
      _emitState(
        _currentState.copyWith(
          status: ModelDownloadStatus.error,
          errorMessage:
              'Bộ nhớ trống không đủ (còn ${(availableDisk / (1024 * 1024)).toStringAsFixed(0)} MB, cần tối thiểu 1.5 GB)',
          availableDiskSpaceBytes: availableDisk,
        ),
      );
      return;
    }

    final targetFile = await getModelFile();
    final tempFile = await getTempDownloadFile();

    if (targetFile.existsSync() && targetFile.lengthSync() > 0) {
      final size = targetFile.lengthSync();
      _emitState(
        ModelDownloadState(
          status: ModelDownloadStatus.ready,
          modelPath: targetFile.path,
          downloadedBytes: size,
          totalBytes: size,
          progress: 1.0,
        ),
      );
      return;
    }

    final int existingBytes = tempFile.existsSync() ? tempFile.lengthSync() : 0;

    _isPaused = false;
    _lastBytesSnapshot = existingBytes;
    _lastSpeedCalcTime = DateTime.now();

    if (mockStream != null) {
      await _consumeStream(
        stream: mockStream,
        totalBytes: mockContentLength ?? (existingBytes + 1024 * 1024),
        existingBytes: existingBytes,
        tempFile: tempFile,
        targetFile: targetFile,
        isAppend: existingBytes > 0,
        expectedSha256: expectedSha256,
      );
      return;
    }

    final downloadUrl = customUrl ?? EnvConfig.gemmaModelDownloadUrl;

    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      if (existingBytes > 0) {
        request.headers['Range'] = 'bytes=$existingBytes-';
      }
      final hfToken = EnvConfig.huggingFaceToken;
      if (hfToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $hfToken';
      }

      final response = await client.send(request);

      if (response.statusCode != 200 && response.statusCode != 206) {
        final errorMsg = response.statusCode == 401
            ? 'Yêu cầu quyền truy cập (HTTP 401). Mô hình yêu cầu token xác thực HuggingFace.'
            : 'Máy chủ phản hồi lỗi: HTTP ${response.statusCode}';
        _emitState(
          _currentState.copyWith(
            status: ModelDownloadStatus.error,
            errorMessage: errorMsg,
          ),
        );
        return;
      }

      final bool isPartial = response.statusCode == 206;
      final int totalBytes = isPartial
          ? (existingBytes + (response.contentLength ?? 0))
          : (response.contentLength ?? EnvConfig.gemmaModelExpectedSizeBytes);

      await _consumeStream(
        stream: response.stream,
        totalBytes: totalBytes,
        existingBytes: isPartial ? existingBytes : 0,
        tempFile: tempFile,
        targetFile: targetFile,
        isAppend: isPartial && existingBytes > 0,
        expectedSha256: expectedSha256,
      );
    } catch (e) {
      if (_isPaused) return;
      _emitState(
        _currentState.copyWith(
          status: ModelDownloadStatus.error,
          errorMessage: 'Lỗi tải mô hình: $e',
        ),
      );
    }
  }

  Future<void> _consumeStream({
    required Stream<List<int>> stream,
    required int totalBytes,
    required int existingBytes,
    required File tempFile,
    required File targetFile,
    required bool isAppend,
    String? expectedSha256,
  }) async {
    _fileSink = tempFile.openWrite(
      mode: isAppend ? FileMode.append : FileMode.write,
    );

    int currentDownloaded = existingBytes;
    DateTime lastEmitTime = DateTime.now();
    double lastEmittedProgress = 0.0;

    _streamCompleter = Completer<void>();

    _downloadSubscription = stream.listen(
      (chunk) {
        if (_isPaused) return;
        _fileSink?.add(chunk);
        currentDownloaded += chunk.length;

        final now = DateTime.now();
        final elapsed = now.difference(_lastSpeedCalcTime).inMilliseconds;

        double currentSpeed = _currentState.speedBytesPerSec;
        if (elapsed >= 400) {
          final diff = currentDownloaded - _lastBytesSnapshot;
          currentSpeed = (diff / (elapsed / 1000.0)).clamp(
            0.0,
            double.infinity,
          );
          _lastBytesSnapshot = currentDownloaded;
          _lastSpeedCalcTime = now;
        }

        final progress = totalBytes > 0
            ? (currentDownloaded / totalBytes).clamp(0.0, 1.0)
            : 0.0;

        final timeSinceLastEmit = now.difference(lastEmitTime).inMilliseconds;
        final progressDiff = (progress - lastEmittedProgress).abs();

        if (timeSinceLastEmit >= 150 ||
            progressDiff >= 0.005 ||
            progress >= 1.0 ||
            currentDownloaded == chunk.length) {
          lastEmitTime = now;
          lastEmittedProgress = progress;

          _emitState(
            _currentState.copyWith(
              status: ModelDownloadStatus.downloading,
              downloadedBytes: currentDownloaded,
              totalBytes: totalBytes,
              progress: progress,
              speedBytesPerSec: currentSpeed,
              clearError: true,
            ),
          );
        }
      },
      onDone: () async {
        await _fileSink?.flush();
        await _fileSink?.close();
        _fileSink = null;

        if (_isPaused) {
          if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
            _streamCompleter!.complete();
          }
          return;
        }

        _emitState(
          _currentState.copyWith(
            status: ModelDownloadStatus.verifying,
            progress: 1.0,
            downloadedBytes: currentDownloaded,
            totalBytes: totalBytes,
            speedBytesPerSec: 0.0,
          ),
        );

        try {
          if (expectedSha256 != null && expectedSha256.isNotEmpty) {
            final isValid = await verifyFileChecksum(
              file: tempFile,
              expectedSha256: expectedSha256,
            );
            if (!isValid) {
              _emitState(
                _currentState.copyWith(
                  status: ModelDownloadStatus.error,
                  errorMessage:
                      'Xác thực tệp mô hình thất bại: Mã băm SHA256 không khớp',
                ),
              );
              return;
            }
          }

          if (targetFile.existsSync()) {
            await targetFile.delete();
          }
          await tempFile.rename(targetFile.path);

          final finalSize = targetFile.lengthSync();
          await localStorage.saveAiModelInfo(
            path: targetFile.path,
            sizeBytes: finalSize,
          );

          _emitState(
            ModelDownloadState(
              status: ModelDownloadStatus.ready,
              modelPath: targetFile.path,
              downloadedBytes: finalSize,
              totalBytes: finalSize,
              progress: 1.0,
              speedBytesPerSec: 0.0,
            ),
          );
        } catch (e) {
          _emitState(
            _currentState.copyWith(
              status: ModelDownloadStatus.error,
              errorMessage: 'Lỗi xác thực và lưu tệp mô hình: $e',
            ),
          );
        } finally {
          if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
            _streamCompleter!.complete();
          }
        }
      },
      onError: (e) async {
        await _fileSink?.flush();
        await _fileSink?.close();
        _fileSink = null;

        if (!_isPaused) {
          _emitState(
            _currentState.copyWith(
              status: ModelDownloadStatus.error,
              errorMessage: 'Lỗi trong quá trình truyền dữ liệu: $e',
            ),
          );
        }
        if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
          _streamCompleter!.complete();
        }
      },
      cancelOnError: true,
    );

    return _streamCompleter!.future;
  }

  Future<void> pauseDownload() async {
    if (!_currentState.isDownloading) return;
    _isPaused = true;
    await _downloadSubscription?.cancel();
    _downloadSubscription = null;
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;
    if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
      _streamCompleter!.complete();
    }

    final tempFile = await getTempDownloadFile();
    final existingBytes = tempFile.existsSync()
        ? tempFile.lengthSync()
        : _currentState.downloadedBytes;

    _emitState(
      _currentState.copyWith(
        status: ModelDownloadStatus.paused,
        downloadedBytes: existingBytes,
        speedBytesPerSec: 0.0,
      ),
    );
  }

  Future<void> resumeDownload() async {
    if (_currentState.status == ModelDownloadStatus.paused) {
      await startDownload();
    }
  }

  Future<void> cancelDownload() async {
    _isPaused = true;
    await _downloadSubscription?.cancel();
    _downloadSubscription = null;
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;
    if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
      _streamCompleter!.complete();
    }

    final tempFile = await getTempDownloadFile();
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    _emitState(
      const ModelDownloadState(status: ModelDownloadStatus.notDownloaded),
    );
  }

  Future<void> deleteModel() async {
    _isPaused = true;
    await _downloadSubscription?.cancel();
    _downloadSubscription = null;
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;
    if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
      _streamCompleter!.complete();
    }

    final targetFile = await getModelFile();
    final tempFile = await getTempDownloadFile();

    if (targetFile.existsSync()) {
      await targetFile.delete();
    }
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    await localStorage.clearAiModelInfo();
    _emitState(
      const ModelDownloadState(status: ModelDownloadStatus.notDownloaded),
    );
  }

  Future<bool> isModelReady() async {
    if (_currentState.isReady) {
      final file = await getModelFile();
      return file.existsSync() && file.lengthSync() > 0;
    }
    return false;
  }

  void dispose() {
    _downloadSubscription?.cancel();
    _fileSink?.close();
    if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
      _streamCompleter!.complete();
    }
    _stateController.close();
  }
}
