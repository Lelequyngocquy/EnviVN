import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:envivn/src/features/map/presentation/widgets/map_zoom_controls.dart';

void main() {
  testWidgets(
    'MapZoomControls renders without overflow and triggers zoom callbacks',
    (tester) async {
      bool zoomedIn = false;
      bool zoomedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MapZoomControls(
                onZoomIn: () {
                  zoomedIn = true;
                },
                onZoomOut: () {
                  zoomedOut = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(zoomedIn, isTrue);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(zoomedOut, isTrue);
    },
  );
}
