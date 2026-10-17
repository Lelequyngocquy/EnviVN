import 'package:flutter_test/flutter_test.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';

void main() {
  group('EnviVN Unit Tests', () {
    test('AQI Helper correctly classifies Good Air Quality (0-50)', () {
      final aqiInfo = AQIHelper.getAQIInfo(25);
      expect(aqiInfo.category, AQICategory.good);
      expect(aqiInfo.label, 'Tốt');
      expect(aqiInfo.wearMask, false);
    });

    test('AQI Helper correctly classifies Unhealthy Sensitive (101-150)', () {
      final aqiInfo = AQIHelper.getAQIInfo(135);
      expect(aqiInfo.category, AQICategory.unhealthySensitive);
      expect(aqiInfo.wearMask, true);
    });

    test('AQI Helper correctly classifies Hazardous (>300)', () {
      final aqiInfo = AQIHelper.getAQIInfo(350);
      expect(aqiInfo.category, AQICategory.hazardous);
      expect(aqiInfo.label, 'Nguy hại');
      expect(aqiInfo.wearMask, true);
    });

    test('WeatherCodeHelper resolves clear sky correctly', () {
      final info = WeatherCodeHelper.getInfo(0);
      expect(info.description, 'Trời quang đãng');
    });

    test('WeatherCodeHelper resolves rain correctly', () {
      final info = WeatherCodeHelper.getInfo(63);
      expect(info.description, 'Mưa vừa');
    });
  });
}
