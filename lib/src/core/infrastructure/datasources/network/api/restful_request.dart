import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../domain/entities/base.dart';
import '../../../configs/env_config.dart';
import 'configs/base_response.dart';
import 'configs/endpoint.dart';

class RestfulRequest {
  final http.Client _client;
  final String defaultBaseUrl;
  final Duration timeout;

  RestfulRequest({
    http.Client? client,
    String? defaultBaseUrl,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       defaultBaseUrl = defaultBaseUrl ?? EnvConfig.openMeteoWeatherBaseUrl;

  Future<BaseResponse> requestData(
    EndpointType endpoint, {
    bool showErrorToast = true,
  }) async {
    final activeBaseUrl = endpoint.customBaseUrl ?? defaultBaseUrl;
    var uri = Uri.parse('$activeBaseUrl${endpoint.path}');

    if (endpoint.method == HttpMethod.get &&
        endpoint.params is Map<String, dynamic>) {
      uri = uri.replace(
        queryParameters: (endpoint.params as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }

    final headers = <String, String>{
      ...DefaultHeader.instance.defaultHeader,
      if (endpoint.header != null) ...endpoint.header!,
    };

    final body = (endpoint.method != HttpMethod.get && endpoint.params != null)
        ? jsonEncode(endpoint.params)
        : null;

    if (kDebugMode) {
      BaseResult.logSend(
        url: uri.toString(),
        method: endpoint.method.value,
        headers: headers,
        params: endpoint.params,
      );
    }

    try {
      http.Response response;
      switch (endpoint.method) {
        case HttpMethod.get:
          response = await _client.get(uri, headers: headers).timeout(timeout);
          break;
        case HttpMethod.post:
          response = await _client
              .post(uri, headers: headers, body: body)
              .timeout(timeout);
          break;
        case HttpMethod.put:
          response = await _client
              .put(uri, headers: headers, body: body)
              .timeout(timeout);
          break;
        case HttpMethod.delete:
          response = await _client
              .delete(uri, headers: headers, body: body)
              .timeout(timeout);
          break;
      }

      dynamic json;
      try {
        json = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        json = response.body;
      }

      if (kDebugMode) {
        BaseResult.logReceive(
          url: uri.toString(),
          statusCode: response.statusCode,
          body: json,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return BaseResponse.fromSuccessJson(json);
      } else {
        return BaseResponse.fromErrorJson(json);
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        BaseResult.logError(
          url: uri.toString(),
          error: 'Lỗi mất kết nối mạng: $e',
        );
      }
      return const BaseResponse(
        isSuccess: false,
        message:
            'Không thể kết nối đến máy chủ thời tiết. Vui lòng kiểm tra Internet!',
      );
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        BaseResult.logError(url: uri.toString(), error: 'Timeout: $e');
      }
      return const BaseResponse(
        isSuccess: false,
        message: 'Kết nối mạng quá hạn (Timeout). Vui lòng thử lại!',
      );
    } catch (e) {
      if (kDebugMode) {
        BaseResult.logError(url: uri.toString(), error: '$e');
      }
      return BaseResponse(
        isSuccess: false,
        message: 'Đã xảy ra sự cố không xác định: $e',
      );
    }
  }
}
