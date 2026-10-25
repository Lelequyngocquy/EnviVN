class BaseResponse {
  final String? code;
  final String? message;
  final dynamic data;
  final Map<String, dynamic>? rawJson;
  final bool isSuccess;

  const BaseResponse({
    this.code,
    this.message,
    this.data,
    this.rawJson,
    this.isSuccess = false,
  });

  factory BaseResponse.fromSuccessJson(dynamic json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      return BaseResponse(
        isSuccess: true,
        data: map['data'] ?? map,
        rawJson: map,
        message: map['message']?.toString(),
        code: map['code']?.toString(),
      );
    }
    return BaseResponse(isSuccess: true, data: json);
  }

  factory BaseResponse.fromErrorJson(dynamic json) {
    final map = json is Map
        ? Map<String, dynamic>.from(json)
        : <String, dynamic>{};
    return BaseResponse(
      isSuccess: false,
      code: map['code']?.toString(),
      message:
          map['message']?.toString() ??
          map['error']?.toString() ??
          map['msg']?.toString() ??
          map['reason']?.toString() ??
          'Đã xảy ra lỗi khi kết nối',
    );
  }
}
