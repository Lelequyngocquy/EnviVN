import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:envivn/src/core/infrastructure/datasources/network/api/restful_request.dart';
import 'package:envivn/src/features/map/infrastructure/repositories/map_repository.dart';
import 'package:envivn/src/features/map/domain/entities/vietnam_monitoring_station.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapRepository Batch Request Tests', () {
    test(
      'getVietnamStations sends 1 single batch request for all 14 stations',
      () async {
        int requestCount = 0;
        Uri? capturedUri;

        final mockClient = MockClient((request) async {
          requestCount++;
          capturedUri = request.url;

          final mockResponseList = List.generate(
            VietnamMonitoringStation.values.length,
            (index) => {
              'latitude': VietnamMonitoringStation.values[index].latitude,
              'longitude': VietnamMonitoringStation.values[index].longitude,
              'current': {
                'us_aqi': 50 + index * 5,
                'pm2_5': 15.0 + index,
                'pm10': 20.0 + index,
              },
            },
          );

          return http.Response(
            jsonEncode(mockResponseList),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final network = RestfulRequest(client: mockClient);
        final repository = MapRepository(network: network);

        final result = await repository.getVietnamStations();

        expect(requestCount, 1);
        expect(capturedUri, isNotNull);
        expect(
          capturedUri.toString().contains('current=us_aqi%2Cpm2_5%2Cpm10'),
          isTrue,
        );

        expect(result.isSuccess, isTrue);
        expect(result.data?.length, VietnamMonitoringStation.values.length);

        final firstStation = result.data?.first;
        expect(firstStation?.aqi, 50);
        expect(firstStation?.pm25, 15.0);
      },
    );

    test(
      'getVietnamStations handles API failure gracefully by returning fallback models',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final network = RestfulRequest(client: mockClient);
        final repository = MapRepository(network: network);

        final result = await repository.getVietnamStations();

        expect(result.isSuccess, isFalse);
        expect(result.data?.length, VietnamMonitoringStation.values.length);
        expect(result.data?.first.name, isNotEmpty);
      },
    );
  });
}
