import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/features/map/infrastructure/models/thermal_hotspot_model.dart';
import 'package:envivn/src/features/map/infrastructure/repositories/nasa_firms_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorage storage;
  late SharedPreferences prefs;

  const sampleCsv = '''
latitude,longitude,bright_ti4,scan,track,acq_date,acq_time,satellite,instrument,confidence,version,bright_ti5,frp,daynight
10.26136,104.70278,330.83,0.39,0.36,2026-10-19,629,N20,VIIRS,n,2.0NRT,293.69,2.91,D
14.02500,107.82000,345.50,0.45,0.40,2026-10-19,629,N20,VIIRS,h,2.0NRT,298.10,24.50,D
''';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = LocalStorage(prefs: prefs);
  });

  group('NasaFirmsRepository Tests', () {
    test(
      'fetches and parses NOAA-20 VIIRS CSV successfully and caches data',
      () async {
        int requestCount = 0;
        final mockClient = MockClient((request) async {
          requestCount++;
          expect(request.url.path, contains('VIIRS_NOAA20_NRT'));
          expect(request.url.path, contains('102.1,8.3,114.5,23.4'));
          return http.Response(sampleCsv, 200);
        });

        final repository = NasaFirmsRepository(
          client: mockClient,
          storage: storage,
          apiKey: 'test_key',
        );

        final result = await repository.getVietnamActiveFires();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, 2);
        expect(requestCount, 1);

        final hotGiaLai = result.data!.firstWhere(
          (s) => s.province == 'Gia Lai',
        );
        expect(hotGiaLai.confidence, 95.0);
        expect(hotGiaLai.latitude, 14.02500);
        expect(hotGiaLai.longitude, 107.82000);
        expect(hotGiaLai.isActiveFire, isTrue);
        expect(hotGiaLai.detectedTime, contains('13:29'));

        final cachedInStorage = storage.getCachedThermalHotspots();
        expect(cachedInStorage, isNotNull);
        expect(cachedInStorage!.length, 2);
      },
    );

    test(
      'serves from 15-minute TTL cache without sending HTTP request',
      () async {
        int requestCount = 0;
        final mockClient = MockClient((request) async {
          requestCount++;
          return http.Response(sampleCsv, 200);
        });

        final repository = NasaFirmsRepository(
          client: mockClient,
          storage: storage,
          apiKey: 'test_key',
        );

        await repository.getVietnamActiveFires();
        expect(requestCount, 1);

        final cachedResult = await repository.getVietnamActiveFires();
        expect(cachedResult.isSuccess, isTrue);
        expect(cachedResult.data!.length, 2);
        expect(requestCount, 1);

        final forcedResult = await repository.getVietnamActiveFires(
          forceRefresh: true,
        );
        expect(forcedResult.isSuccess, isTrue);
        expect(requestCount, 2);
      },
    );

    test(
      'falls back to stale cache on HTTP 429 rate limit (5000 transactions / 10m)',
      () async {
        int requestCount = 0;
        final mockClient = MockClient((request) async {
          requestCount++;
          if (requestCount == 1) {
            return http.Response(sampleCsv, 200);
          }
          return http.Response('Rate limit exceeded', 429);
        });

        final repository = NasaFirmsRepository(
          client: mockClient,
          storage: storage,
          apiKey: 'test_key',
        );

        await repository.getVietnamActiveFires();
        expect(repository.isServingCachedData, isFalse);

        final result429 = await repository.getVietnamActiveFires(
          forceRefresh: true,
        );

        expect(result429.isSuccess, isTrue);
        expect(result429.data, isNotNull);
        expect(result429.data!.length, 2);
        expect(repository.isServingCachedData, isTrue);
        expect(result429.message, contains('giới hạn hạn ngạch NASA'));
      },
    );

    test(
      'falls back to sampleHotspots if storage is empty and network fails',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final repository = NasaFirmsRepository(
          client: mockClient,
          storage: storage,
          apiKey: 'test_key',
        );

        final result = await repository.getVietnamActiveFires();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, ThermalHotspotModel.sampleHotspots.length);
        expect(result.message, contains('danh mục điểm nhiệt thực địa'));
      },
    );
  });
}
