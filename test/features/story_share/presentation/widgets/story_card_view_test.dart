import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:envivn/src/features/story_share/presentation/widgets/story_options_bottom_sheet.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/features/story_share/presentation/widgets/story_card_view.dart';

void main() {
  const testCity = AppLocationEntity(
    id: 'test_city',
    displayName: 'Hà Nội',
    provinceOrRegion: 'Hà Nội',
    latitude: 21.0285,
    longitude: 105.8542,
  );

  const testAqi = AirQualityEntity(usAqi: 85, pm25: 28.5, pm10: 45.0);

  final testWeather = DetailsEntity(
    currentTemp: 28.0,
    apparentTemp: 31.0,
    weatherCode: 1,
    relativeHumidity: 72,
    windSpeed: 10.5,
    uvIndex: 5.5,
    surfacePressure: 1012.0,
    precipitation: 0.0,
    hourlyForecast: [
      HourlyDetailsPoint(
        time: DateTime.now().add(const Duration(hours: 1)),
        temperature: 28.5,
        humidity: 70,
        precipitationProbability: 35,
        weatherCode: 1,
      ),
    ],
  );

  testWidgets(
    'StoryCardView renders compactly with default cards without overflow',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 568,
                child: StoryCardView(
                  city: testCity,
                  airQuality: testAqi,
                  weather: testWeather,
                  updateTime: DateTime.now(),
                  ratio: StoryRatio.story,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('EnviVN'), findsWidgets);
      expect(find.text('Hà Nội'), findsOneWidget);
      expect(find.text('KHÔNG KHÍ'), findsOneWidget);
      expect(find.text('THỜI TIẾT'), findsOneWidget);
      expect(find.text('NGẬP & MƯA'), findsOneWidget);
      expect(find.text('CỐ VẤN Y TẾ'), findsOneWidget);

      final airCardFinder = find.ancestor(
        of: find.text('KHÔNG KHÍ'),
        matching: find.byType(AnimatedContainer),
      );
      final airCardSize = tester.getSize(airCardFinder.first);
      expect(airCardSize.height, lessThan(125.0));
      expect(airCardSize.height, greaterThanOrEqualTo(76.0));
    },
  );

  testWidgets(
    'StoryCardView with 2 cards and 6 cards scales flexibly without overflow in square and story ratios',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 568,
                child: StoryCardView(
                  city: testCity,
                  airQuality: testAqi,
                  weather: testWeather,
                  updateTime: DateTime.now(),
                  ratio: StoryRatio.story,
                  cards: const [
                    StoryCardType.airQuality,
                    StoryCardType.weather,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final airCard = find.ancestor(
        of: find.text('KHÔNG KHÍ'),
        matching: find.byType(AnimatedContainer),
      );
      expect(tester.getSize(airCard.first).height, lessThan(125.0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: StoryCardView(
                  city: testCity,
                  airQuality: testAqi,
                  weather: testWeather,
                  updateTime: DateTime.now(),
                  ratio: StoryRatio.square,
                  cards: const [
                    StoryCardType.airQuality,
                    StoryCardType.weather,
                    StoryCardType.floodRisk,
                    StoryCardType.advisorHealth,
                    StoryCardType.outdoorActivity,
                    StoryCardType.windAtmosphere,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'StoryCardView selection displays arrow controls with proper edge disable',
    (tester) async {
      int? selected;
      int? swapFrom;
      int? swapTo;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 320,
                    height: 568,
                    child: StoryCardView(
                      city: testCity,
                      airQuality: testAqi,
                      weather: testWeather,
                      updateTime: DateTime.now(),
                      ratio: StoryRatio.story,
                      isInteractive: true,
                      selectedIndex: selected,
                      onCardSelected: (index) {
                        setState(() {
                          selected = index;
                        });
                      },
                      onSwapCards: (from, to) {
                        swapFrom = from;
                        swapTo = to;
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      expect(find.byIcon(Icons.open_with_rounded), findsNothing);

      await tester.tap(find.text('KHÔNG KHÍ'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.open_with_rounded), findsOneWidget);
      expect(selected, 0);

      final rightArrow = find.byIcon(Icons.arrow_forward_rounded);
      expect(rightArrow, findsOneWidget);

      await tester.tap(rightArrow);
      await tester.pumpAndSettle();

      expect(swapFrom, 0);
      expect(swapTo, 1);
    },
  );

  testWidgets(
    'StoryOptionsBottomSheet renders ratio selection and card previews',
    (tester) async {
      StoryRatio appliedRatio = StoryRatio.story;
      List<StoryCardType> appliedCards = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    StoryOptionsBottomSheet.show(
                      context,
                      currentRatio: StoryRatio.story,
                      currentCards: [
                        StoryCardType.airQuality,
                        StoryCardType.weather,
                      ],
                      city: testCity,
                      airQuality: testAqi,
                      weather: testWeather,
                      onApply: (ratio, cards) {
                        appliedRatio = ratio;
                        appliedCards = cards;
                      },
                    );
                  },
                  child: const Text('Mở tùy chọn'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mở tùy chọn'));
      await tester.pumpAndSettle();

      expect(find.text('Tùy chỉnh thẻ Story'), findsOneWidget);
      expect(find.text('TỶ LỆ KHUNG HÌNH'), findsOneWidget);
      expect(find.text('9:16'), findsOneWidget);
      expect(find.text('1:1'), findsOneWidget);
      expect(find.text('4:5'), findsOneWidget);
      expect(find.text('CÁC THẺ DỮ LIỆU'), findsOneWidget);

      await tester.tap(find.text('1:1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Áp dụng tùy chọn'));
      await tester.pumpAndSettle();

      expect(appliedRatio, StoryRatio.square);
      expect(appliedCards.length, 2);
    },
  );
}
