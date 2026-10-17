import 'dart:convert';
import 'package:flutter/foundation.dart';

class BaseResult<T> {
  bool success;
  String? code;
  String? message;
  dynamic messageParams;
  T? data;

  BaseResult({
    this.success = true,
    this.code,
    this.message,
    this.messageParams,
    this.data,
  }) {
    if (kDebugMode) {
      log();
    }
  }

  bool get isSuccess => success;
  bool get isError => !success;

  /// Log tự động khi BaseResult được khởi tạo trong các Repository/Service
  void log() {
    if (!kDebugMode) return;
    try {
      final icon = success ? '✅' : '❌';
      final statusText = success ? 'SUCCESS' : 'FAILURE';
      final buffer = StringBuffer();
      buffer.writeln('$icon [BaseResult $statusText]');
      if (code != null) buffer.writeln('   • Code   : $code');
      if (message != null && message!.isNotEmpty) buffer.writeln('   • Message: $message');
      if (data != null) {
        buffer.writeln('   • Data   : ${_prettyJson(data)}');
      }
      debugPrint(buffer.toString());
    } catch (_) {}
  }

  /// Log chi tiết ẩn khi gửi request API đi
  static void logSend({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic params,
  }) {
    if (!kDebugMode) return;
    try {
      final buffer = StringBuffer();
      buffer.writeln('╔════════════════════ 🚀 [API REQUEST SEND] ════════════════════');
      buffer.writeln('║ METHOD: $method');
      buffer.writeln('║ URL   : $url');
      if (params != null) {
        buffer.writeln('║ BODY  :\n${_indentString(_prettyJson(params), "║   ")}');
      }
      buffer.writeln('╚══════════════════════════════════════════════════════════════');
      debugPrint(buffer.toString());
    } catch (_) {}
  }

  /// Log chi tiết ẩn khi nhận response API về
  static void logReceive({
    required String url,
    required int statusCode,
    dynamic body,
  }) {
    if (!kDebugMode) return;
    try {
      final isOk = statusCode >= 200 && statusCode < 300;
      final icon = isOk ? '📥' : '⚠️';
      final buffer = StringBuffer();
      buffer.writeln('╔════════════════════ $icon [API RESPONSE RECEIVE] ════════════════════');
      buffer.writeln('║ STATUS: $statusCode');
      buffer.writeln('║ URL   : $url');
      if (body != null) {
        buffer.writeln('║ BODY  :\n${_indentString(_prettyJson(body), "║   ")}');
      }
      buffer.writeln('╚══════════════════════════════════════════════════════════════════');
      debugPrint(buffer.toString());
    } catch (_) {}
  }

  /// Log chi tiết ẩn khi xảy ra lỗi mạng / timeout
  static void logError({
    required String url,
    required String error,
  }) {
    if (!kDebugMode) return;
    try {
      final buffer = StringBuffer();
      buffer.writeln('╔════════════════════ ❌ [API NETWORK ERROR] ════════════════════');
      buffer.writeln('║ URL  : $url');
      buffer.writeln('║ ERROR: $error');
      buffer.writeln('╚═══════════════════════════════════════════════════════════════');
      debugPrint(buffer.toString());
    } catch (_) {}
  }

  static String _indentString(String str, String indent) {
    return str.split('\n').map((line) => '$indent$line').join('\n');
  }

  static String _prettyJson(dynamic raw, {int maxLines = 12, int maxChars = 350}) {
    if (raw == null) return 'null';
    String formatted;
    try {
      if (raw is Map || raw is List) {
        formatted = const JsonEncoder.withIndent('  ').convert(raw);
      } else if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          formatted = const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          formatted = raw;
        }
      } else {
        formatted = raw.toString();
      }
    } catch (_) {
      formatted = raw.toString();
    }

    final lines = formatted.split('\n');
    if (lines.length > maxLines) {
      final truncated = lines.take(maxLines).join('\n');
      return '$truncated\n... [${lines.length - maxLines} dòng ẩn]';
    }

    if (formatted.length > maxChars) {
      return '${formatted.substring(0, maxChars)}\n... [cắt ngắn]';
    }

    return formatted;
  }
}
