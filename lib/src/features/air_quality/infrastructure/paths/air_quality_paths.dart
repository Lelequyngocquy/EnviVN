import 'package:envivn/src/core/infrastructure/configs/env_config.dart';

class AirQualityPaths {
  AirQualityPaths._();

  static String get airQualityBaseUrl => EnvConfig.openMeteoAirQualityBaseUrl;
  static const String airQuality = '/v1/air-quality';
}
