import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/features/map/domain/entities/station_entity.dart';
import 'package:envivn/src/features/map/presentation/widgets/station_marker_widget.dart';

void main() {
  testWidgets(
    'StationMarkerWidget renders without overflow across all 4 layers including 0mm and 120mm rainfall',
    (WidgetTester tester) async {
      final stations = [
        StationEntity(
          id: 'station_0mm',
          name: 'Trạm 0mm',
          province: 'Hà Nội',
          latitude: 21.0,
          longitude: 105.8,
          aqi: 45,
          pm25: 12.0,
          pm10: 20.0,
          updatedAt: DateTime.now(),
          temperature: 28.0,
          weatherCode: 1,
          precipitation: 0.0,
        ),
        StationEntity(
          id: 'station_heavy_rain',
          name: 'Trạm Mưa Lớn',
          province: 'Đà Nẵng',
          latitude: 16.0,
          longitude: 108.2,
          aqi: 120,
          pm25: 65.0,
          pm10: 95.0,
          updatedAt: DateTime.now(),
          temperature: 38.5,
          weatherCode: 65,
          precipitation: 125.0,
        ),
      ];

      for (final st in stations) {
        for (final layer in MapLayerType.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 80.0,
                    height: 34.0,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: StationMarkerWidget(
                        station: st,
                        isSelected: false,
                        activeLayer: layer,
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          final err = tester.takeException();
          if (err != null) {
            debugPrint('FAILED on station ${st.name}, layer $layer: $err');
          }
          expect(err, isNull);
        }
      }
    },
  );
}
