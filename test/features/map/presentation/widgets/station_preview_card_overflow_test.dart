import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/features/map/domain/entities/station_entity.dart';
import 'package:envivn/src/features/map/presentation/widgets/station_preview_card.dart';

void main() {
  testWidgets(
    'StationPreviewCard renders without any overflow on narrow screen (320px) across all 4 layers',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testStation = StationEntity(
        id: 'test_station_long_id',
        name:
            'Trạm Quan Trắc Khí Tượng Thủy Văn Tự Động Khu Công Nghiệp Sóng Thần 2',
        province: 'Tỉnh Bình Dương & Vùng Phụ Cận',
        latitude: 10.762622,
        longitude: 106.660172,
        aqi: 185,
        pm25: 125.4,
        pm10: 178.9,
        updatedAt: DateTime.now(),
        temperature: 36.8,
        apparentTemp: 44.5,
        weatherCode: 65,
        humidity: 88,
        windSpeed: 28.5,
        precipitation: 45.0,
        uvIndex: 11.5,
        isThermalHotspot: true,
        isActiveFire: true,
        fireType: 'Điểm phát xạ nhiệt ở vùng cao (công suất cao)',
        fireBrightnessCelsius: 58.0,
        fireConfidence: 95.0,
        fireDetectedTime: 'Hôm nay, 14:35 (NASA VIIRS vệ tinh tầm quét 375m)',
        isFloodBlackspot: true,
        historicalDepthCm: 55,
        floodProneTime:
            'Tháng 9 - 11 hàng năm khi triều cường đỉnh điểm kết hợp mưa to',
        floodTriggerCondition:
            'Mưa từ 40mm trở lên trong 30 phút hoặc triều cường sông Sài Gòn',
        spotDescription:
            'Khu vực trũng thấp ven sông, hệ thống thoát nước cũ đang trong diện nâng cấp',
      );

      for (final layer in MapLayerType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: StationPreviewCard(
                    station: testStation,
                    activeLayer: layer,
                    onClose: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'Layer $layer should not throw any layout overflow exception',
        );
      }
    },
  );

  testWidgets(
    'StationPreviewCard renders picked custom station with GPS coordinates and distance without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pickedStation = StationEntity(
        id: 'picked_18.3830_106.5690',
        name: 'Điểm ghim (~145km từ Thừa Thiên Huế)',
        province: 'Thừa Thiên Huế',
        latitude: 18.3830,
        longitude: 106.5690,
        aqi: 45,
        pm25: 12.0,
        pm10: 20.0,
        updatedAt: DateTime.now(),
        temperature: 28.5,
        apparentTemp: 31.0,
        weatherCode: 1,
        humidity: 78,
        windSpeed: 14.0,
        precipitation: 0.0,
        uvIndex: 7.0,
      );

      for (final layer in MapLayerType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: StationPreviewCard(
                    station: pickedStation,
                    activeLayer: layer,
                    onClose: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'Picked station card on $layer should not throw overflow',
        );
        expect(
          find.textContaining('Điểm ghim (~145km từ Thừa Thiên Huế)'),
          findsOneWidget,
        );
        expect(find.textContaining('18.3830°B, 106.5690°Đ'), findsOneWidget);
      }
    },
  );
}
