import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LocalStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = LocalStorage(prefs: prefs);
  });

  group('LocalStorage Multi-Location and TTL Cache Tests', () {
    test('weather cache stores independently by coordinates', () async {
      final hanoiData = {'temperature_2m': 28.5, 'city': 'Hà Nội'};
      final danangData = {'temperature_2m': 32.0, 'city': 'Đà Nẵng'};

      await storage.saveCachedWeather(hanoiData, lat: 21.0285, lon: 105.8542);

      await storage.saveCachedWeather(danangData, lat: 16.0544, lon: 108.2022);

      final cachedHanoi = storage.getCachedWeather(lat: 21.0285, lon: 105.8542);
      final cachedDanang = storage.getCachedWeather(
        lat: 16.0544,
        lon: 108.2022,
      );

      expect(cachedHanoi, isNotNull);
      expect(cachedHanoi?['city'], 'Hà Nội');
      expect(cachedHanoi?['temperature_2m'], 28.5);

      expect(cachedDanang, isNotNull);
      expect(cachedDanang?['city'], 'Đà Nẵng');
      expect(cachedDanang?['temperature_2m'], 32.0);
    });

    test('weather cache respects TTL expiration', () async {
      final data = {'temp': 25.0};
      await storage.saveCachedWeather(
        data,
        lat: 21.02,
        lon: 105.85,
        ttl: const Duration(milliseconds: 1),
      );

      await Future.delayed(const Duration(milliseconds: 5));

      final validCache = storage.getCachedWeather(
        lat: 21.02,
        lon: 105.85,
        checkTtl: true,
      );
      expect(validCache, isNull);

      final offlineCache = storage.getCachedWeather(
        lat: 21.02,
        lon: 105.85,
        checkTtl: false,
      );
      expect(offlineCache, isNotNull);
      expect(offlineCache?['temp'], 25.0);
    });

    test('air quality cache stores independently and respects TTL', () async {
      final hanoiAqi = {'us_aqi': 155, 'city': 'Hà Nội'};
      final sgAqi = {'us_aqi': 68, 'city': 'TP. Hồ Chí Minh'};

      await storage.saveCachedAirQuality(
        hanoiAqi,
        lat: 21.03,
        lon: 105.85,
        ttl: const Duration(milliseconds: 1),
      );
      await storage.saveCachedAirQuality(
        sgAqi,
        lat: 10.78,
        lon: 106.70,
        ttl: const Duration(minutes: 30),
      );

      await Future.delayed(const Duration(milliseconds: 5));

      expect(
        storage.getCachedAirQuality(lat: 21.03, lon: 105.85, checkTtl: true),
        isNull,
      );
      expect(
        storage.getCachedAirQuality(lat: 21.03, lon: 105.85, checkTtl: false),
        isNotNull,
      );
      expect(
        storage.getCachedAirQuality(
          lat: 10.78,
          lon: 106.70,
          checkTtl: true,
        )?['us_aqi'],
        68,
      );
    });

    test('backwards compatibility without lat lon parameters', () async {
      final data = {'default': true};
      await storage.saveCachedWeather(data);

      final retrieved = storage.getCachedWeather();
      expect(retrieved, isNotNull);
      expect(retrieved?['default'], true);
    });
  });
}
