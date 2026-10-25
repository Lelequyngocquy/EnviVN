import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class EnvConfig {
  EnvConfig._();

  static final Map<String, String> _envMap = {};
  static bool _isInitialized = false;

  /// Kiểm tra xem cấu hình đã được nạp hay chưa.
  static bool get isInitialized => _isInitialized;

  /// Khởi tạo và nạp file môi trường (.env_example làm khung cơ sở, ghi đè bằng .env nếu có).
  static Future<void> init() async {
    // 1. Nạp khung cấu hình mặc định từ .env_example (nếu có)
    try {
      final exampleContent = await rootBundle.loadString('.env_example');
      _parseAndMerge(exampleContent, isOverride: false);
      if (kDebugMode) {
        debugPrint(
          '[EnvConfig] Đã nạp cấu hình cơ sở từ .env_example (${_envMap.length} biến)',
        );
      }
    } catch (_) {
      // Bỏ qua nếu không tìm thấy .env_example trong asset bundle
    }

    // 2. Nạp cấu hình chính thức từ .env (ghi đè và bổ sung các token cá nhân)
    try {
      final envContent = await rootBundle.loadString('.env');
      final prevCount = _envMap.length;
      _parseAndMerge(envContent, isOverride: true);
      if (kDebugMode) {
        debugPrint(
          '[EnvConfig] Đã nạp thành công .env (+${_envMap.length - prevCount} biến)',
        );
      }
    } catch (_) {
      if (kDebugMode) {
        debugPrint(
          '[EnvConfig] Không tìm thấy .env (sử dụng cấu hình từ .env_example hoặc hằng số mặc định)',
        );
      }
    }

    _isInitialized = true;
  }

  /// Nạp trực tiếp từ chuỗi (hữu ích cho Unit Test hoặc Mocking).
  static void loadFromString(String rawContent, {bool isOverride = true}) {
    _parseAndMerge(rawContent, isOverride: isOverride);
    _isInitialized = true;
  }

  /// Xóa toàn bộ cấu hình (dùng để reset trong test suites).
  static void reset() {
    _envMap.clear();
    _isInitialized = false;
  }

  /// Phân tích cú pháp KEY=VALUE từ nội dung file cấu hình .env / .env_example
  static void _parseAndMerge(String content, {required bool isOverride}) {
    final lines = content.split('\n');
    for (var line in lines) {
      line = line.trim();
      // Bỏ qua dòng trống hoặc dòng chú thích (#)
      if (line.isEmpty || line.startsWith('#')) continue;

      final equalIndex = line.indexOf('=');
      if (equalIndex > 0) {
        final key = line.substring(0, equalIndex).trim();
        var value = line.substring(equalIndex + 1).trim();

        // Loại bỏ dấu ngoặc kép hoặc ngoặc đơn bọc ngoài giá trị
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          if (value.length >= 2) {
            value = value.substring(1, value.length - 1);
          }
        }

        // Cơ chế nạp & ghi đè:
        // - Nếu isOverride=true: chỉ ghi đè khi value có giá trị (không rỗng) hoặc key chưa tồn tại
        // - Nếu isOverride=false: chỉ thêm mới nếu key chưa tồn tại
        if (isOverride) {
          if (value.isNotEmpty || !_envMap.containsKey(key)) {
            _envMap[key] = value;
          }
        } else {
          if (!_envMap.containsKey(key)) {
            _envMap[key] = value;
          }
        }
      }
    }
  }

  /// Lấy giá trị chuỗi theo Key, trả về [defaultValue] nếu không tìm thấy.
  static String get(String key, {String defaultValue = ''}) {
    final val = _envMap[key];
    if (val == null || val.isEmpty) {
      return defaultValue;
    }
    return val;
  }

  /// Lấy giá trị boolean (true/false) theo Key.
  static bool getBool(String key, {bool defaultValue = false}) {
    final val = _envMap[key]?.toLowerCase().trim();
    if (val == 'true' || val == '1' || val == 'yes') return true;
    if (val == 'false' || val == '0' || val == 'no') return false;
    return defaultValue;
  }

  // ===========================================================================
  // CÁC GETTERS ĐỊNH DANH QUY CHUẨN CHO ỨNG DỤNG
  // ===========================================================================

  /// Tên ứng dụng
  static String get appName => get('APP_NAME', defaultValue: 'EnviVN');

  /// Môi trường chạy (development / staging / production)
  static String get appEnv => get('APP_ENV', defaultValue: 'development');

  /// Chế độ debug
  static bool get isDebug => getBool('APP_DEBUG', defaultValue: kDebugMode);

  /// URL Open-Meteo Weather API
  static String get openMeteoWeatherBaseUrl => get(
    'OPEN_METEO_WEATHER_BASE_URL',
    defaultValue: 'https://api.open-meteo.com',
  );

  /// URL Open-Meteo Air Quality API
  static String get openMeteoAirQualityBaseUrl => get(
    'OPEN_METEO_AIR_QUALITY_BASE_URL',
    defaultValue: 'https://air-quality-api.open-meteo.com',
  );

  /// URL Open-Meteo Geocoding API
  static String get openMeteoGeocodingBaseUrl => get(
    'OPEN_METEO_GEOCODING_BASE_URL',
    defaultValue: 'https://geocoding-api.open-meteo.com',
  );

  /// URL IP Geolocation API
  static String get ipApiBaseUrl =>
      get('IP_API_BASE_URL', defaultValue: 'http://ip-api.com/json');

  /// URL OpenStreetMap Tiles Template
  static String get osmTileUrl => get(
    'OSM_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  /// User Agent cho dịch vụ bản đồ
  static String get mapUserAgent =>
      get('MAP_USER_AGENT', defaultValue: 'com.envivn.envivn');

  /// URL NASA FIRMS API
  static String get nasaFirmsBaseUrl => get(
    'NASA_FIRMS_BASE_URL',
    defaultValue: 'https://firms.modaps.eosdis.nasa.gov/api',
  );

  /// Key xác thực dịch vụ vệ tinh NASA FIRMS (5000 transactions / 10 phút)
  static String get nasaFirmsMapKey => get(
    'NASA_FIRMS_MAP_KEY',
    defaultValue: 'aaa04b831a37f75677607b924c5df1de',
  );

  static String get gemmaModelDownloadUrl => get(
    'GEMMA_MODEL_DOWNLOAD_URL',
    defaultValue:
        'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf',
  );

  static String get huggingFaceToken =>
      get('HF_TOKEN', defaultValue: get('HUGGINGFACE_TOKEN', defaultValue: ''));

  static String get gemmaModelFileName =>
      get('GEMMA_MODEL_FILE_NAME', defaultValue: 'gemma-2-2b-it-gpu-int4.bin');

  static int get gemmaModelExpectedSizeBytes =>
      int.tryParse(get('GEMMA_MODEL_EXPECTED_SIZE_BYTES')) ?? 1708582752;
}
