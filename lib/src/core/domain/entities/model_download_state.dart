import 'package:equatable/equatable.dart';

enum ModelDownloadStatus {
  notDownloaded,
  checkingDisk,
  downloading,
  paused,
  verifying,
  ready,
  error,
}

class ModelDownloadState extends Equatable {
  final ModelDownloadStatus status;
  final int downloadedBytes;
  final int totalBytes;
  final double progress;
  final double speedBytesPerSec;
  final String? modelPath;
  final String? errorMessage;
  final int? availableDiskSpaceBytes;

  const ModelDownloadState({
    this.status = ModelDownloadStatus.notDownloaded,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.progress = 0.0,
    this.speedBytesPerSec = 0.0,
    this.modelPath,
    this.errorMessage,
    this.availableDiskSpaceBytes,
  });

  bool get isReady => status == ModelDownloadStatus.ready;
  bool get isDownloading => status == ModelDownloadStatus.downloading;
  bool get isPaused => status == ModelDownloadStatus.paused;
  bool get isError => status == ModelDownloadStatus.error;
  bool get hasError => isError;

  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  String get formattedDownloadedSize {
    final mb = downloadedBytes / (1024 * 1024);
    if (mb < 1024) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  String get formattedTotalSize {
    final mb = totalBytes / (1024 * 1024);
    if (mb < 1024) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  String get formattedSpeed {
    final kb = speedBytesPerSec / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB/s';
    }
    return '${(kb / 1024).toStringAsFixed(1)} MB/s';
  }

  ModelDownloadState copyWith({
    ModelDownloadStatus? status,
    int? downloadedBytes,
    int? totalBytes,
    double? progress,
    double? speedBytesPerSec,
    String? modelPath,
    String? errorMessage,
    int? availableDiskSpaceBytes,
    bool clearError = false,
  }) {
    return ModelDownloadState(
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      modelPath: modelPath ?? this.modelPath,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      availableDiskSpaceBytes:
          availableDiskSpaceBytes ?? this.availableDiskSpaceBytes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    downloadedBytes,
    totalBytes,
    progress,
    speedBytesPerSec,
    modelPath,
    errorMessage,
    availableDiskSpaceBytes,
  ];
}
