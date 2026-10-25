import 'package:flutter_test/flutter_test.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';

void main() {
  group('AppLocationEntity Tests', () {
    test('gps factory sets correct properties', () {
      final loc = AppLocationEntity.gps(latitude: 21.0285, longitude: 105.8542);

      expect(loc.isGps, isTrue);
      expect(loc.isCustomPin, isFalse);
      expect(loc.isStation, isFalse);
      expect(loc.name, equals('Vị trí hiện tại'));
      expect(loc.province, equals('Định vị GPS'));
      expect(loc.originType, equals(LocationOriginType.gps));
    });

    test('city factory sets correct properties', () {
      final loc = AppLocationEntity.city(
        name: 'Đà Nẵng',
        province: 'Đà Nẵng',
        latitude: 16.0544,
        longitude: 108.2022,
      );

      expect(loc.isGps, isFalse);
      expect(loc.name, equals('Đà Nẵng'));
      expect(loc.province, equals('Đà Nẵng'));
      expect(loc.originType, equals(LocationOriginType.popularCity));
    });

    test('station factory sets correct properties', () {
      final loc = AppLocationEntity.station(
        id: 'st_001',
        name: 'Trạm Ba Đình',
        province: 'Hà Nội',
        latitude: 21.03,
        longitude: 105.83,
      );

      expect(loc.isStation, isTrue);
      expect(loc.id, equals('station_st_001'));
      expect(loc.name, equals('Trạm Ba Đình'));
      expect(loc.province, equals('Hà Nội'));
    });

    test('customPin factory formats subtitle and distance correctly', () {
      final loc = AppLocationEntity.customPin(
        latitude: 21.15,
        longitude: 105.95,
        referenceProvince: 'Hà Nội',
        distanceKm: 18.4,
      );

      expect(loc.isCustomPin, isTrue);
      expect(loc.name, equals('Điểm ghim (~18 km từ Hà Nội)'));
      expect(loc.formattedSubtitle, equals('Cách ~18 km từ Hà Nội'));
    });

    test('customPin factory formats small distance (<10km) with decimal', () {
      final loc = AppLocationEntity.customPin(
        latitude: 21.05,
        longitude: 105.88,
        referenceProvince: 'Hà Nội',
        distanceKm: 4.67,
      );

      expect(loc.isCustomPin, isTrue);
      expect(loc.name, equals('Điểm ghim (~4.7 km từ Hà Nội)'));
      expect(loc.formattedSubtitle, equals('Cách ~4.7 km từ Hà Nội'));
    });

    test('city factory sets correct properties', () {
      final city = AppLocationEntity.city(
        name: 'Hà Nội',
        province: 'Thủ đô Hà Nội',
        latitude: 21.0285,
        longitude: 105.8542,
      );
      expect(city.name, equals('Hà Nội'));
      expect(city.province, equals('Thủ đô Hà Nội'));
      expect(city.latitude, equals(21.0285));
      expect(city.longitude, equals(105.8542));
      expect(city.isGps, isFalse);
    });

    test(
      'PopularLocation enum and popularLocations in entity works correctly',
      () {
        expect(PopularLocation.values.length, equals(14));

        final hanoi = PopularLocation.hanoi.toEntity();
        expect(hanoi.name, equals('Hà Nội'));
        expect(hanoi.province, equals('Thủ đô Hà Nội'));
        expect(hanoi.originType, equals(LocationOriginType.popularCity));

        final popularLocs = AppLocationEntity.popularLocations;
        expect(popularLocs.length, equals(14));
        expect(popularLocs.first.name, equals('Hà Nội'));
        expect(popularLocs.last.name, equals('Quần đảo Trường Sa'));
      },
    );
  });
}
