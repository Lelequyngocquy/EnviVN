enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  final String value;
  const HttpMethod(this.value);
}

class EndpointType {
  final String path;
  final String? customBaseUrl;
  final HttpMethod method;
  final dynamic params;
  final Map<String, String>? header;

  EndpointType({
    required this.path,
    this.customBaseUrl,
    this.method = HttpMethod.get,
    this.params,
    this.header,
  });
}

class DefaultHeader {
  DefaultHeader._();
  static final DefaultHeader instance = DefaultHeader._();

  Map<String, String> get defaultHeader => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
