import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:envivn/src/common/constants/colors.dart';
import 'package:envivn/src/common/utils/activity_advice_helper.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/domain/entities/base.dart';
import 'package:envivn/src/core/infrastructure/configs/env_config.dart';
import 'package:envivn/src/core/presentation/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/location_service.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/home/domain/entities/city_entity.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_action_panel.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_loading_overlay.dart';
import 'package:envivn/src/features/home/presentation/widgets/home_top_bar.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/quick_city_target.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/station_pollution_entity.dart';
import 'package:envivn/src/features/map_pollution/domain/interfaces/i_map_pollution_repository.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_cubit.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_state.dart';
import 'package:envivn/src/features/map_pollution/presentation/widgets/map_top_control_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/weather/domain/entities/weather_entity.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_cubit.dart';
import 'package:envivn/src/features/weather/presentation/cubits/weather_state.dart';
import 'package:envivn/src/features/weather/presentation/pages/twenty_four_hour_detail_page.dart';

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

    test('WeatherCodeHelper correctly detects daytime vs nighttime hours', () {
      expect(
        WeatherCodeHelper.isDaytime(DateTime(2026, 10, 17, 5, 59)),
        isFalse,
      );
      expect(WeatherCodeHelper.isDaytime(DateTime(2026, 10, 17, 6, 0)), isTrue);
      expect(
        WeatherCodeHelper.isDaytime(DateTime(2026, 10, 17, 12, 0)),
        isTrue,
      );
      expect(
        WeatherCodeHelper.isDaytime(DateTime(2026, 10, 17, 17, 59)),
        isTrue,
      );
      expect(
        WeatherCodeHelper.isDaytime(DateTime(2026, 10, 17, 18, 0)),
        isFalse,
      );
      expect(
        WeatherCodeHelper.isDaytime(DateTime(2026, 10, 17, 23, 30)),
        isFalse,
      );
    });

    test('WeatherCodeHelper resolves clear sky with day/night icons', () {
      final dayInfo = WeatherCodeHelper.getInfo(0, isDay: true);
      expect(dayInfo.description, 'Trời quang đãng');
      expect(dayInfo.icon, Icons.wb_sunny_rounded);
      expect(dayInfo.isNight, isFalse);

      final nightInfo = WeatherCodeHelper.getInfo(0, isDay: false);
      expect(nightInfo.description, 'Đêm quang đãng');
      expect(nightInfo.icon, Icons.nightlight_round);
      expect(nightInfo.isNight, isTrue);
    });

    test('WeatherCodeHelper resolves partly cloudy with day/night icons', () {
      final dayInfo = WeatherCodeHelper.getInfo(1, isDay: true);
      expect(dayInfo.icon, Icons.wb_sunny_outlined);
      expect(dayInfo.isNight, isFalse);

      final nightInfo = WeatherCodeHelper.getInfo(1, isDay: false);
      expect(nightInfo.icon, Icons.nights_stay_rounded);
      expect(nightInfo.isNight, isTrue);

      final dayScattered = WeatherCodeHelper.getInfo(2, isDay: true);
      expect(dayScattered.icon, Icons.cloud_queue_rounded);

      final nightScattered = WeatherCodeHelper.getInfo(2, isDay: false);
      expect(nightScattered.icon, Icons.nights_stay_outlined);
    });

    test('WeatherCodeHelper resolves rain correctly', () {
      final info = WeatherCodeHelper.getInfo(63);
      expect(info.description, 'Mưa vừa');
      expect(info.isRain, isTrue);
    });

    test(
      'ActivityAdviceHelper evaluates multi-factor safety realistically',
      () {
        final idealAdvice = ActivityAdviceHelper.evaluate(
          aqi: 30,
          uv: 3.0,
          rainProb: 10,
        );
        expect(idealAdvice.level, ActivitySafetyLevel.safe);
        expect(idealAdvice.statusLabel, 'An toàn');

        final unhealthyAdvice = ActivityAdviceHelper.evaluate(
          aqi: 220,
          uv: 2.0,
          rainProb: 0,
        );
        expect(unhealthyAdvice.level, ActivitySafetyLevel.avoid);
        expect(unhealthyAdvice.statusLabel, 'Không nên');

        final rainyAdvice = ActivityAdviceHelper.evaluate(
          aqi: 40,
          uv: 1.0,
          rainProb: 90,
        );
        expect(rainyAdvice.level, ActivitySafetyLevel.avoid);
        expect(rainyAdvice.statusLabel, 'Không nên');

        final cautionAdvice = ActivityAdviceHelper.evaluate(
          aqi: 120,
          uv: 5.0,
          rainProb: 20,
        );
        expect(cautionAdvice.level, ActivitySafetyLevel.caution);
        expect(cautionAdvice.statusLabel, 'Cần chú ý');
      },
    );

    test(
      'ActivityAdviceHelper dynamically shifts and forecasts smart time slots based on current time (Option B)',
      () {
        final morningTime = DateTime(2026, 10, 18, 6, 0);
        final morningAdvice = ActivityAdviceHelper.evaluate(
          aqi: 40,
          uv: 2.0,
          rainProb: 10,
          currentTime: morningTime,
        );
        expect(morningAdvice.slots.length, 2);
        expect(morningAdvice.slots[0].activity, contains('Sáng nay'));
        expect(morningAdvice.slots[1].activity, contains('Chiều nay'));

        final afternoonTime = DateTime(2026, 10, 18, 14, 0);
        final hourlyWeather = [
          HourlyWeatherPoint(
            time: DateTime(2026, 10, 18, 17, 0),
            temperature: 28.0,
            humidity: 75,
            precipitationProbability: 80,
            weatherCode: 61,
          ),
          HourlyWeatherPoint(
            time: DateTime(2026, 10, 19, 6, 0),
            temperature: 24.0,
            humidity: 60,
            precipitationProbability: 10,
            weatherCode: 1,
          ),
        ];
        final hourlyAqi = [
          HourlyAqiPoint(
            time: DateTime(2026, 10, 18, 17, 0),
            aqi: 45,
            pm25: 12.0,
            pm10: 25.0,
          ),
          HourlyAqiPoint(
            time: DateTime(2026, 10, 19, 6, 0),
            aqi: 30,
            pm25: 8.0,
            pm10: 15.0,
          ),
        ];

        final afternoonAdvice = ActivityAdviceHelper.evaluate(
          aqi: 50,
          uv: 6.0,
          rainProb: 20,
          currentTime: afternoonTime,
          hourlyWeather: hourlyWeather,
          hourlyAqi: hourlyAqi,
        );

        // Giờ trưa 14:00: Sáng nay đã qua -> Gợi ý Chiều nay & Sáng mai
        expect(afternoonAdvice.slots.length, 2);
        expect(afternoonAdvice.slots[0].activity, contains('Chiều nay'));
        expect(afternoonAdvice.slots[0].status, contains('Nguy cơ mưa 80%'));
        expect(afternoonAdvice.slots[0].isOk, isFalse);

        expect(afternoonAdvice.slots[1].activity, contains('Sáng mai'));
        expect(afternoonAdvice.slots[1].status, contains('Rất lý tưởng'));
        expect(afternoonAdvice.slots[1].isOk, isTrue);

        // Buổi tối 20:00: Gợi ý Tối nay & Sáng mai
        final eveningTime = DateTime(2026, 10, 18, 20, 0);
        final eveningAdvice = ActivityAdviceHelper.evaluate(
          aqi: 40,
          uv: 0.0,
          rainProb: 0,
          currentTime: eveningTime,
        );
        expect(eveningAdvice.slots.length, 2);
        expect(eveningAdvice.slots[0].activity, contains('Tối nay'));
        expect(eveningAdvice.slots[1].activity, contains('Sáng mai'));
      },
    );

    test(
      'DateHelper formats Vietnamese date without throwing LocaleDataException',
      () {
        final date = DateTime(2026, 10, 17, 13, 0);
        final formatted = DateHelper.formatVietnamese(date);
        expect(formatted, isNotEmpty);

        final fullFormatted = DateHelper.formatVietnameseFull(date);
        expect(fullFormatted, isNotEmpty);
      },
    );

    test('StationPollutionEntity stores weather information correctly', () {
      final station = StationPollutionEntity(
        id: 'test_01',
        name: 'Trạm Hoàn Kiếm',
        province: 'Hà Nội',
        latitude: 21.0285,
        longitude: 105.8542,
        aqi: 85,
        pm25: 28.5,
        pm10: 42.0,
        updatedAt: DateTime(2026, 10, 17),
        temperature: 27.5,
        weatherCode: 2,
        humidity: 70,
        windSpeed: 12.0,
      );

      expect(station.temperature, 27.5);
      expect(station.weatherCode, 2);
      expect(station.humidity, 70);
      expect(station.windSpeed, 12.0);

      final updated = station.copyWith(temperature: 29.0);
      expect(updated.temperature, 29.0);
      expect(updated.humidity, 70);
    });

    test('MapPollutionState copyWith clearSelectedStation works reliably', () {
      final station = StationPollutionEntity(
        id: 'st_01',
        name: 'Trạm Test',
        province: 'Đà Nẵng',
        latitude: 16.05,
        longitude: 108.20,
        aqi: 40,
        pm25: 12.0,
        pm10: 20.0,
        updatedAt: DateTime.now(),
      );

      var state = MapPollutionState(selectedStation: station);
      expect(state.selectedStation, isNotNull);

      state = state.copyWith(clearSelectedStation: true);
      expect(state.selectedStation, isNull);
    });

    test(
      'HomeDashboardState isChangingLocation flag works correctly in copyWith',
      () {
        const state = HomeDashboardState();
        expect(state.isChangingLocation, false);

        final changingState = state.copyWith(isChangingLocation: true);
        expect(changingState.isChangingLocation, true);

        final finishedState = changingState.copyWith(isChangingLocation: false);
        expect(finishedState.isChangingLocation, false);
      },
    );

    test(
      'HomeDashboardState isLocationPermissionGranted flag works correctly in copyWith',
      () {
        const state = HomeDashboardState();
        expect(state.isLocationPermissionGranted, false);

        final grantedState = state.copyWith(isLocationPermissionGranted: true);
        expect(grantedState.isLocationPermissionGranted, true);

        final revokedState =
            grantedState.copyWith(isLocationPermissionGranted: false);
        expect(revokedState.isLocationPermissionGranted, false);
      },
    );

    test('LocalStorage persists and retrieves location permission granted state',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs: prefs);

      expect(storage.isLocationPermissionGranted(), false);

      await storage.saveLocationPermission(true);
      expect(storage.isLocationPermissionGranted(), true);

      await storage.saveLocationPermission(false);
      expect(storage.isLocationPermissionGranted(), false);
    });

    testWidgets('LocationActionPanel displays custom button titles dynamically',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationActionPanel(
              primaryButtonText: 'Chọn vị trí hiện tại',
              secondaryButtonText: 'Chọn thành phố khác',
              onAllow: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.text('Chọn vị trí hiện tại'), findsOneWidget);
      expect(find.text('Chọn thành phố khác'), findsOneWidget);
    });

    test(
      'MapPollutionCubit synchronizes selection by station and city name',
      () async {
        final testStations = [
          StationPollutionEntity(
            id: 'hn_01',
            name: 'Trạm Hoàn Kiếm',
            province: 'Hà Nội',
            latitude: 21.0285,
            longitude: 105.8542,
            aqi: 110,
            pm25: 38.0,
            pm10: 55.0,
            updatedAt: DateTime.now(),
            temperature: 26.0,
            weatherCode: 2,
          ),
          StationPollutionEntity(
            id: 'dn_01',
            name: 'Trạm Hải Châu',
            province: 'Đà Nẵng',
            latitude: 16.0544,
            longitude: 108.2022,
            aqi: 35,
            pm25: 10.0,
            pm10: 18.0,
            updatedAt: DateTime.now(),
            temperature: 28.0,
            weatherCode: 0,
          ),
        ];

        final fakeRepo = _FakeMapPollutionRepository(testStations);
        final cubit = MapPollutionCubit(repository: fakeRepo);

        // 1. Fetch stations
        await cubit.fetchVietnamStations();
        expect(cubit.state.stations.length, 2);

        // 2. Select station by city name "Hà Nội"
        cubit.selectLocationByCityName('Hà Nội');
        expect(cubit.state.selectedStation?.id, 'hn_01');
        expect(cubit.state.targetLocation?.latitude, 21.0285);
        expect(cubit.state.selectedCityName, 'Hà Nội');

        // 3. Select station directly
        cubit.selectStation(testStations[1]);
        expect(cubit.state.selectedStation?.id, 'dn_01');
        expect(cubit.state.targetLocation?.latitude, 16.0544);

        // 4. Clear selection
        cubit.clearSelection();
        expect(cubit.state.selectedStation, isNull);
        expect(cubit.state.targetLocation, isNull);

        // 5. Show all Vietnam
        cubit.showAllVietnam();
        expect(cubit.state.selectedStation, isNull);
        expect(cubit.state.selectedCityName, 'Toàn quốc');
        expect(cubit.state.targetLocation?.latitude, 16.0544);
        expect(cubit.state.targetZoom, 5.8);

        cubit.close();
      },
    );

    test(
      'HomeDashboardState hasPendingMapSync flag works correctly and defaults to true',
      () {
        const state = HomeDashboardState();
        expect(state.hasPendingMapSync, isTrue);

        final consumedState = state.copyWith(hasPendingMapSync: false);
        expect(consumedState.hasPendingMapSync, isFalse);

        final pendingState = consumedState.copyWith(hasPendingMapSync: true);
        expect(pendingState.hasPendingMapSync, isTrue);
      },
    );

    test(
      'MapPollutionCubit selectLocationCoordinates targets nearest station without mutating home city (One-way sync & Isolation)',
      () async {
        final testStations = [
          StationPollutionEntity(
            id: 'hn_01',
            name: 'Trạm Hoàn Kiếm',
            province: 'Hà Nội',
            latitude: 21.0285,
            longitude: 105.8542,
            aqi: 110,
            pm25: 38.0,
            pm10: 55.0,
            updatedAt: DateTime.now(),
            temperature: 26.0,
            weatherCode: 2,
          ),
          StationPollutionEntity(
            id: 'dn_01',
            name: 'Trạm Hải Châu',
            province: 'Đà Nẵng',
            latitude: 16.0544,
            longitude: 108.2022,
            aqi: 35,
            pm25: 10.0,
            pm10: 18.0,
            updatedAt: DateTime.now(),
            temperature: 28.0,
            weatherCode: 0,
          ),
        ];

        final fakeRepo = _FakeMapPollutionRepository(testStations);
        final mapCubit = MapPollutionCubit(repository: fakeRepo);
        await mapCubit.fetchVietnamStations();

        var homeState = const HomeDashboardState(
          currentCity: CityEntity(
            name: 'Hà Nội',
            province: 'Hà Nội',
            latitude: 21.0285,
            longitude: 105.8542,
          ),
          hasPendingMapSync: true,
        );

        if (homeState.hasPendingMapSync) {
          mapCubit.selectLocationCoordinates(
            homeState.currentCity.latitude,
            homeState.currentCity.longitude,
            label: homeState.currentCity.name,
          );
          homeState = homeState.copyWith(hasPendingMapSync: false);
        }

        expect(mapCubit.state.selectedStation?.id, 'hn_01');
        expect(mapCubit.state.targetLocation?.latitude, 21.0285);
        expect(homeState.hasPendingMapSync, isFalse);

        // Khám phá trạm khác trên bản đồ
        mapCubit.selectStation(testStations[1]);
        expect(mapCubit.state.selectedStation?.id, 'dn_01');
        expect(mapCubit.state.targetLocation?.latitude, 16.0544);

        // Đảm bảo không ảnh hưởng đến vị trí Trang chủ
        expect(homeState.currentCity.name, 'Hà Nội');
        expect(homeState.currentCity.latitude, 21.0285);

        mapCubit.close();
      },
    );

    test(
      'QuickCityTarget domain enum accurately defines coordinates, zoom and handles isSelected matching',
      () {
        expect(QuickCityTarget.allVietnam.isAllCountry, isTrue);
        expect(QuickCityTarget.allVietnam.zoom, 5.8);
        expect(QuickCityTarget.allVietnam.isSelected('Toàn quốc'), isTrue);
        expect(QuickCityTarget.allVietnam.isSelected('Hà Nội'), isFalse);

        expect(QuickCityTarget.hanoi.label, 'Hà Nội');
        expect(QuickCityTarget.hanoi.latitude, 21.0285);
        expect(QuickCityTarget.hanoi.longitude, 105.8542);
        expect(QuickCityTarget.hanoi.isSelected('Trạm Hoàn Kiếm, Hà Nội'), isTrue);

        expect(QuickCityTarget.hoChiMinh.isSelected('TP. Hồ Chí Minh'), isTrue);
        expect(QuickCityTarget.hoChiMinh.isSelected('Quận 1, Sài Gòn'), isTrue);
        expect(QuickCityTarget.hoChiMinh.isSelected('Đà Nẵng'), isFalse);

        // matchesPinnedLocation deduplication tests
        expect(QuickCityTarget.hanoi.matchesPinnedLocation('Hà Nội'), isTrue);
        expect(QuickCityTarget.hanoi.matchesPinnedLocation('Vị trí hiện tại (Hà Nội)'), isTrue);
        expect(QuickCityTarget.hanoi.matchesPinnedLocation('Đà Nẵng'), isFalse);
        expect(QuickCityTarget.hanoi.matchesPinnedLocation(null), isFalse);
        expect(QuickCityTarget.hoChiMinh.matchesPinnedLocation('TP. Hồ Chí Minh'), isTrue);
        expect(QuickCityTarget.hoChiMinh.matchesPinnedLocation('Vị trí hiện tại (Sài Gòn)'), isTrue);
        expect(QuickCityTarget.allVietnam.matchesPinnedLocation('Toàn quốc'), isFalse);
      },
    );

    test(
      'MapPollutionCubit selectQuickCity navigates to target location or country view',
      () {
        final fakeRepo = _FakeMapPollutionRepository([]);
        final mapCubit = MapPollutionCubit(repository: fakeRepo);

        // 1. Select specific quick city
        mapCubit.selectQuickCity(QuickCityTarget.daNang);
        expect(mapCubit.state.targetLocation?.latitude, 16.0544);
        expect(mapCubit.state.targetLocation?.longitude, 108.2022);
        expect(mapCubit.state.selectedCityName, 'Đà Nẵng');

        // 2. Select all country
        mapCubit.selectQuickCity(QuickCityTarget.allVietnam);
        expect(mapCubit.state.targetZoom, 5.8);
        expect(mapCubit.state.selectedCityName, 'Toàn quốc');

        // 3. Update quick cities dynamically from cubit
        mapCubit.updateQuickCities([
          QuickCityTarget.allVietnam,
          QuickCityTarget.hanoi,
          QuickCityTarget.hoChiMinh,
        ]);
        expect(mapCubit.state.quickCities.length, 3);

        mapCubit.close();
      },
    );

    testWidgets(
      'MapTopControlBar renders quick city chips dynamically from QuickCityTarget list inside horizontal ListView',
      (tester) async {
        QuickCityTarget? selectedTarget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapTopControlBar(
                activeFilter: 'all',
                onFilterChanged: (_) {},
                showHeatmap: true,
                onToggleHeatmap: () {},
                selectedCityName: 'Hà Nội',
                homeCityName: 'Đà Nẵng',
                onSelectCity: (_) {},
                onSelectAllVietnam: () {},
                quickCities: const [
                  QuickCityTarget.allVietnam,
                  QuickCityTarget.hanoi,
                  QuickCityTarget.hoChiMinh,
                ],
                onSelectQuickCity: (target) {
                  selectedTarget = target;
                },
              ),
            ),
          ),
        );

        // Verify ListView is rendered
        expect(find.byType(ListView), findsOneWidget);

        // Verify Home city chip is displayed with icon
        expect(find.text('Đà Nẵng'), findsOneWidget);
        expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);

        // Verify quick city chips are displayed
        expect(find.text('Toàn quốc'), findsOneWidget);
        expect(find.text('Hà Nội'), findsOneWidget);
        expect(find.text('TP. Hồ Chí Minh'), findsOneWidget);

        // Verify tap triggers onSelectQuickCity with target enum
        await tester.tap(find.text('TP. Hồ Chí Minh'));
        expect(selectedTarget, QuickCityTarget.hoChiMinh);
      },
    );

    testWidgets(
      'MapTopControlBar deduplicates pinned home city from quick cities list to prevent duplicate chips',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapTopControlBar(
                activeFilter: 'all',
                onFilterChanged: (_) {},
                showHeatmap: true,
                onToggleHeatmap: () {},
                selectedCityName: 'Hà Nội',
                homeCityName: 'Hà Nội',
                onSelectCity: (_) {},
                onSelectAllVietnam: () {},
                quickCities: const [
                  QuickCityTarget.allVietnam,
                  QuickCityTarget.hanoi,
                  QuickCityTarget.daNang,
                  QuickCityTarget.hoChiMinh,
                ],
              ),
            ),
          ),
        );

        // 'Hà Nội' is pinned at the start as home chip and removed from the subsequent chips
        expect(find.text('Hà Nội'), findsOneWidget);
        expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);

        // Other quick cities remain untouched
        expect(find.text('Toàn quốc'), findsOneWidget);
        expect(find.text('Đà Nẵng'), findsOneWidget);
        expect(find.text('TP. Hồ Chí Minh'), findsOneWidget);
      },
    );

    test(
      'MapPollutionCubit selectHomeLocation sets isHomeSelected to true and selects closest station',
      () async {
        final testStations = [
          StationPollutionEntity(
            id: 'hn_01',
            name: 'Trạm Hoàn Kiếm',
            province: 'Hà Nội',
            latitude: 21.0285,
            longitude: 105.8542,
            aqi: 110,
            pm25: 38.0,
            pm10: 55.0,
            updatedAt: DateTime.now(),
            temperature: 26.0,
            weatherCode: 2,
          ),
        ];

        final fakeRepo = _FakeMapPollutionRepository(testStations);
        final mapCubit = MapPollutionCubit(repository: fakeRepo);
        await mapCubit.fetchVietnamStations();

        // 1. Select Home location
        mapCubit.selectHomeLocation(
          lat: 21.0285,
          lon: 105.8542,
          label: 'Vị trí hiện tại',
        );

        expect(mapCubit.state.isHomeSelected, isTrue);
        expect(mapCubit.state.selectedStation?.id, 'hn_01');
        expect(mapCubit.state.selectedCityName, 'Vị trí hiện tại');

        // 2. Select another city target -> isHomeSelected turns false
        mapCubit.selectQuickCity(QuickCityTarget.daNang);
        expect(mapCubit.state.isHomeSelected, isFalse);
        expect(mapCubit.state.selectedCityName, 'Đà Nẵng');

        mapCubit.close();
      },
    );

    testWidgets(
      'MapTopControlBar highlights Home chip when isHomeSelected is true',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapTopControlBar(
                activeFilter: 'all',
                onFilterChanged: (_) {},
                showHeatmap: true,
                onToggleHeatmap: () {},
                selectedCityName: 'Hà Nội',
                homeCityName: 'Vị trí hiện tại',
                isHomeSelected: true,
                onSelectCity: (_) {},
                onSelectAllVietnam: () {},
                quickCities: const [
                  QuickCityTarget.allVietnam,
                  QuickCityTarget.hanoi,
                  QuickCityTarget.daNang,
                ],
              ),
            ),
          ),
        );

        expect(find.text('Vị trí hiện tại'), findsOneWidget);
        expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
      },
    );

    test('AppTagSize enum defines consistent sizing properties', () {
      expect(AppTagSize.small.fontSize, lessThan(AppTagSize.medium.fontSize));
      expect(AppTagSize.medium.fontSize, lessThan(AppTagSize.large.fontSize));
      expect(AppTagSize.small.borderRadius, 10);
      expect(AppTagSize.medium.borderRadius, 14);
      expect(AppTagSize.large.borderRadius, 20);
    });

    testWidgets('AppStatusTag renders label, icon and handles tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppStatusTag(
                label: 'Không khí tốt',
                icon: Icons.check_circle_rounded,
                color: Colors.green,
                size: AppTagSize.medium,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Không khí tốt'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text('Không khí tốt'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'Row with Expanded Text (maxLines: 3) and AppStatusTag handles long text without overflow',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Text(
                          'Đây là một tiêu đề rất dài nhằm kiểm tra tính năng tự động xuống dòng tối đa 3 dòng khi đứng cạnh tag trạng thái mà không bao giờ bị lỗi overflow pixel',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      AppStatusTag(
                        label: 'Nhãn siêu dài',
                        color: Colors.orange,
                        size: AppTagSize.medium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(AppStatusTag), findsOneWidget);
      },
    );

    testWidgets(
      'AppDialog renders text content without buttons when showButtons is false',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppDialog(
                title: 'Cảnh báo tự động',
                content: 'Nội dung thông báo chỉ có chữ không có nút bấm.',
                showButtons: false,
              ),
            ),
          ),
        );

        expect(find.text('Cảnh báo tự động'), findsOneWidget);
        expect(
          find.text('Nội dung thông báo chỉ có chữ không có nút bấm.'),
          findsOneWidget,
        );
        expect(find.text('Đóng'), findsNothing);
        expect(find.text('Hủy'), findsNothing);
      },
    );

    testWidgets('AppDialog renders 1 back button and responds to tap', (
      tester,
    ) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDialog(
              title: 'Lưu ý',
              content: 'Vui lòng kiểm tra lại kết nối GPS.',
              leftButtonTitle: 'Quay lại',
              leftButtonFunc: () => backTapped = true,
              showLeftButton: true,
            ),
          ),
        ),
      );

      expect(find.text('Quay lại'), findsOneWidget);
      await tester.tap(find.text('Quay lại'));
      expect(backTapped, isTrue);
    });

    testWidgets('AppDialog renders 2 buttons and triggers rightButtonFunc', (
      tester,
    ) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDialog(
              title: 'Xác nhận đổi trạm',
              content: 'Bạn có muốn chuyển sang trạm Hoàn Kiếm không?',
              leftButtonTitle: 'Thoát',
              rightButtonTitle: 'Đồng ý',
              rightButtonFunc: () => confirmed = true,
            ),
          ),
        ),
      );

      expect(find.text('Thoát'), findsOneWidget);
      expect(find.text('Đồng ý'), findsOneWidget);

      await tester.tap(find.text('Đồng ý'));
      expect(confirmed, isTrue);
    });

    testWidgets(
      'LocationLoadingOverlay displays city name and pulses using AppDialog',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: LocationLoadingOverlay(cityName: 'Đà Nẵng')),
          ),
        );

        expect(find.text('Đang cập nhật vị trí'), findsOneWidget);
        expect(find.text('Đà Nẵng'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(AppDialog), findsOneWidget);
      },
    );

    test(
      'EnvConfig provides robust fallback defaults before initialization',
      () {
        expect(EnvConfig.openMeteoWeatherBaseUrl, 'https://api.open-meteo.com');
        expect(
          EnvConfig.openMeteoAirQualityBaseUrl,
          'https://air-quality-api.open-meteo.com',
        );
        expect(
          EnvConfig.openMeteoGeocodingBaseUrl,
          'https://geocoding-api.open-meteo.com',
        );
        expect(EnvConfig.ipApiBaseUrl, 'http://ip-api.com/json');
        expect(EnvConfig.osmTileUrl, contains('tile.openstreetmap.org'));
        expect(EnvConfig.mapUserAgent, 'com.envivn.envivn');
        expect(EnvConfig.appName, 'EnviVN');
        expect(EnvConfig.appEnv, 'development');
      },
    );

    test(
      'EnvConfig parses and loads configuration from .env and .env_example',
      () {
        EnvConfig.reset();

        // 1. Nạp file mẫu .env_example làm cơ sở
        EnvConfig.loadFromString('''
APP_NAME=EnviVN
OPEN_METEO_WEATHER_BASE_URL=https://api.open-meteo.com
OPEN_METEO_AIR_QUALITY_BASE_URL=https://air-quality-api.open-meteo.com
OSM_TILE_URL=https://tile.openstreetmap.org/{z}/{x}/{y}.png
APP_DEBUG=true
WAQI_API_KEY=
''', isOverride: false);

        expect(EnvConfig.appName, 'EnviVN');
        expect(EnvConfig.openMeteoWeatherBaseUrl, 'https://api.open-meteo.com');
        expect(
          EnvConfig.openMeteoAirQualityBaseUrl,
          'https://air-quality-api.open-meteo.com',
        );

        // 2. Gộp tiếp file cấu hình .env vào (bổ sung token bảo mật và ghi đè tùy chỉnh)
        EnvConfig.loadFromString('''
WAQI_API_KEY=test_secret_token_12345
WAQI_BASE_URL=https://api.waqi.info
MAPBOX_ACCESS_TOKEN=test_mapbox_token
OPEN_METEO_WEATHER_BASE_URL=
APP_DEBUG=false
''', isOverride: true);

        // Kiểm tra các biến được nạp chính xác:
        // - Biến từ .env_example vẫn được bảo toàn:
        expect(EnvConfig.openMeteoWeatherBaseUrl, 'https://api.open-meteo.com');
        expect(
          EnvConfig.openMeteoAirQualityBaseUrl,
          'https://air-quality-api.open-meteo.com',
        );
        expect(
          EnvConfig.osmTileUrl,
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        );
        expect(EnvConfig.appName, 'EnviVN');
        expect(EnvConfig.isDebug, isFalse);

        EnvConfig.reset();
      },
    );

    testWidgets(
      'TwentyFourHourDetailPage displays location name text and removes insights icon in header',
      (tester) async {
        final fakeHomeCubit = _FakeHomeDashboardCubit(
          const HomeDashboardState(
            currentCity: CityEntity(
              name: 'Đà Nẵng',
              province: 'Đà Nẵng',
              latitude: 16.0544,
              longitude: 108.2022,
            ),
          ),
        );
        final fakeWeatherCubit = _FakeWeatherCubit();
        final fakeAqiCubit = _FakeAirQualityCubit();

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<HomeDashboardCubit>.value(value: fakeHomeCubit),
              BlocProvider<WeatherCubit>.value(value: fakeWeatherCubit),
              BlocProvider<AirQualityCubit>.value(value: fakeAqiCubit),
            ],
            child: const MaterialApp(
              home: TwentyFourHourDetailPage(),
            ),
          ),
        );

        // Verify the location name text is displayed in header
        expect(find.text('Đà Nẵng'), findsOneWidget);
        // Verify insights icon is completely removed
        expect(find.byIcon(Icons.insights_rounded), findsNothing);
        expect(find.text('Chi tiết 24 giờ'), findsOneWidget);

        fakeHomeCubit.close();
        fakeWeatherCubit.close();
        fakeAqiCubit.close();
      },
    );

    testWidgets(
      'HomeTopBar displays "Chọn vị trí hiện tại" suggestion button when current city is not current location',
      (tester) async {
        bool selectedCurrentLocation = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeTopBar(
                cityName: 'Hà Nội',
                isGps: false,
                dateText: 'Chủ Nhật, 18 tháng 10',
                hasNotification: false,
                onLocationTap: () {},
                onNotificationTap: () {},
                onSelectCurrentLocation: () {
                  selectedCurrentLocation = true;
                },
              ),
            ),
          ),
        );

        // Verify dropdown displays 'Hà Nội'
        expect(find.text('Hà Nội'), findsOneWidget);

        // Verify suggestion button 'Chọn vị trí hiện tại' is displayed
        expect(find.text('Chọn vị trí hiện tại'), findsOneWidget);

        // Tap suggestion button
        await tester.tap(find.text('Chọn vị trí hiện tại'));
        expect(selectedCurrentLocation, isTrue);
      },
    );

    testWidgets(
      'HomeTopBar hides "Chọn vị trí hiện tại" suggestion button when current city is already current location',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeTopBar(
                cityName: 'Vị trí hiện tại (Hà Nội)',
                isGps: true,
                dateText: 'Chủ Nhật, 18 tháng 10',
                hasNotification: false,
                onLocationTap: () {},
                onNotificationTap: () {},
                onSelectCurrentLocation: () {},
              ),
            ),
          ),
        );

        // Verify dropdown displays current location
        expect(find.text('Vị trí hiện tại (Hà Nội)'), findsOneWidget);

        // Verify suggestion button 'Chọn vị trí hiện tại' is NOT displayed
        expect(find.text('Chọn vị trí hiện tại'), findsNothing);
      },
    );

    testWidgets(
      'AppText renders with correct font weights, default styling, and handles size aliases & maxLines',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: const [
                  AppText.regular('Regular Text'),
                  AppText.medium('Medium Text', size: 16),
                  AppText.semiBold('SemiBold Text', fontSize: 18),
                  AppText.semibold('Semibold Alias Text'),
                  AppText.bold('Bold Text', color: UIColors.primary),
                  AppText.light('Light Text'),
                  AppText.extraBold('ExtraBold Text'),
                  AppText('Default Text', maxLines: 2),
                ],
              ),
            ),
          ),
        );

        // Verify all texts are found
        expect(find.text('Regular Text'), findsOneWidget);
        expect(find.text('Medium Text'), findsOneWidget);
        expect(find.text('SemiBold Text'), findsOneWidget);
        expect(find.text('Semibold Alias Text'), findsOneWidget);
        expect(find.text('Bold Text'), findsOneWidget);
        expect(find.text('Light Text'), findsOneWidget);
        expect(find.text('ExtraBold Text'), findsOneWidget);
        expect(find.text('Default Text'), findsOneWidget);

        // Verify Text widget styles
        final regularText = tester.widget<Text>(find.text('Regular Text'));
        expect(regularText.style?.fontWeight, FontWeight.w400);
        expect(regularText.style?.fontSize, 14.0);
        expect(regularText.style?.color, UIColors.textPrimary);

        final mediumText = tester.widget<Text>(find.text('Medium Text'));
        expect(mediumText.style?.fontWeight, FontWeight.w500);
        expect(mediumText.style?.fontSize, 16.0);

        final semiBoldText = tester.widget<Text>(find.text('SemiBold Text'));
        expect(semiBoldText.style?.fontWeight, FontWeight.w600);
        expect(semiBoldText.style?.fontSize, 18.0);

        final boldText = tester.widget<Text>(find.text('Bold Text'));
        expect(boldText.style?.fontWeight, FontWeight.w700);
        expect(boldText.style?.color, UIColors.primary);

        final lightText = tester.widget<Text>(find.text('Light Text'));
        expect(lightText.style?.fontWeight, FontWeight.w300);

        final extraBoldText = tester.widget<Text>(find.text('ExtraBold Text'));
        expect(extraBoldText.style?.fontWeight, FontWeight.w800);

        // Verify maxLines & automatic ellipsis overflow
        final defaultText = tester.widget<Text>(find.text('Default Text'));
        expect(defaultText.maxLines, 2);
        expect(defaultText.overflow, TextOverflow.ellipsis);
      },
    );

    testWidgets(
      'AppIcon applies default 20.0 size and UIColors, and honors preset constructors',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AppIcon(Icons.home),
                  AppIcon.small(Icons.star),
                  AppIcon.medium(Icons.settings),
                  AppIcon.large(Icons.favorite),
                  AppIcon.primary(Icons.check),
                  AppIcon.secondary(Icons.close),
                  AppIcon(Icons.eco, size: 24, color: UIColors.aqiGood),
                ],
              ),
            ),
          ),
        );

        final homeIcon = tester.widget<Icon>(find.byIcon(Icons.home));
        expect(homeIcon.size, 20.0);
        expect(homeIcon.color, UIColors.textPrimary);

        final smallIcon = tester.widget<Icon>(find.byIcon(Icons.star));
        expect(smallIcon.size, 14.0);
        expect(smallIcon.color, UIColors.textPrimary);

        final mediumIcon = tester.widget<Icon>(find.byIcon(Icons.settings));
        expect(mediumIcon.size, 20.0);

        final largeIcon = tester.widget<Icon>(find.byIcon(Icons.favorite));
        expect(largeIcon.size, 28.0);

        final primaryIcon = tester.widget<Icon>(find.byIcon(Icons.check));
        expect(primaryIcon.color, UIColors.primary);
        expect(primaryIcon.size, 20.0);

        final secondaryIcon = tester.widget<Icon>(find.byIcon(Icons.close));
        expect(secondaryIcon.color, UIColors.textSecondary);
        expect(secondaryIcon.size, 20.0);

        final customIcon = tester.widget<Icon>(find.byIcon(Icons.eco));
        expect(customIcon.size, 24.0);
        expect(customIcon.color, UIColors.aqiGood);
      },
    );

    test(
      'HomeDashboardCubit fallback to default Hanoi when location permission is denied and never sets Ho Chi Minh IP fallback',
      () async {
        SharedPreferences.setMockInitialValues({
          'location_permission_granted': true,
        });
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorage(prefs: prefs);

        // Simulated scenario: User clicked "Don't allow" in OS permission dialog
        final fakeLocationService = _FakeLocationService(
          isGranted: false,
          result: const LocationResult(
            latitude: 21.0285,
            longitude: 105.8542,
            cityName: 'Hà Nội',
            isDefault: true,
            isPermissionDenied: true,
            errorMessage: 'Quyền truy cập vị trí bị từ chối. Sử dụng vị trí mặc định (Hà Nội).',
          ),
        );

        final fakeWeatherCubit = _FakeWeatherCubit();
        final fakeAqiCubit = _FakeAirQualityCubit();

        final cubit = HomeDashboardCubit(
          storage: storage,
          locationService: fakeLocationService,
          weatherCubit: fakeWeatherCubit,
          airQualityCubit: fakeAqiCubit,
        );

        // User taps "Vị trí hiện tại"
        await cubit.detectGpsLocation();

        // Must strictly set default Hanoi, not GPS city, not Ho Chi Minh
        expect(cubit.state.currentCity, CityEntity.defaultCity);
        expect(cubit.state.currentCity.name, 'Hà Nội');
        expect(cubit.state.currentCity.isGps, isFalse);
        expect(cubit.state.isLocationPermissionGranted, isFalse);
        expect(storage.isLocationPermissionGranted(), isFalse);
        expect(cubit.state.currentCity.name.contains('Ho Chi Minh'), isFalse);
        expect(cubit.state.currentCity.name.contains('Hồ Chí Minh'), isFalse);

        cubit.close();
        fakeWeatherCubit.close();
        fakeAqiCubit.close();
      },
    );

    test(
      'HomeDashboardCubit emits Quyền truy cập vị trí đang bị tắt toast and retains default Hanoi when location permission is initially off',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorage(prefs: prefs);

        final fakeLocationService = _FakeLocationService(
          isGranted: false,
          result: const LocationResult(
            latitude: 21.0285,
            longitude: 105.8542,
            cityName: 'Hà Nội',
            isDefault: true,
            isPermissionDenied: true,
          ),
        );

        final fakeWeatherCubit = _FakeWeatherCubit();
        final fakeAqiCubit = _FakeAirQualityCubit();

        final cubit = HomeDashboardCubit(
          storage: storage,
          locationService: fakeLocationService,
          weatherCubit: fakeWeatherCubit,
          airQualityCubit: fakeAqiCubit,
        );

        final notices = <String>[];
        final sub = cubit.stream.listen((state) {
          if (state.noticeMessage != null) {
            notices.add(state.noticeMessage!);
          }
        });

        await cubit.detectGpsLocation();

        // Must emit toast notice informing user that location permission is off
        expect(notices, contains('Quyền truy cập vị trí đang bị tắt'));
        // Must emit exactly 1 notification, NOT 2 notifications!
        expect(notices.length, 1);
        // And when user denies, retain Hanoi as default
        expect(cubit.state.currentCity, CityEntity.defaultCity);
        expect(cubit.state.isLocationPermissionGranted, isFalse);

        await sub.cancel();
        cubit.close();
        fakeWeatherCubit.close();
        fakeAqiCubit.close();
      },
    );

    test(
      'HomeDashboardCubit resets GPS location to default Hanoi on init when phone permission was turned off',
      () async {
        SharedPreferences.setMockInitialValues({
          'selected_city_name': 'Vị trí hiện tại (Đà Nẵng)',
          'selected_city_lat': 16.0544,
          'selected_city_lon': 108.2022,
          'location_permission_granted': true,
        });
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorage(prefs: prefs);

        // OS Permission is now FALSE (User turned off in phone settings)
        final fakeLocationService = _FakeLocationService(
          isGranted: false,
          result: const LocationResult(
            latitude: 21.0285,
            longitude: 105.8542,
            isDefault: true,
            isPermissionDenied: true,
          ),
        );

        final fakeWeatherCubit = _FakeWeatherCubit();
        final fakeAqiCubit = _FakeAirQualityCubit();

        final cubit = HomeDashboardCubit(
          storage: storage,
          locationService: fakeLocationService,
          weatherCubit: fakeWeatherCubit,
          airQualityCubit: fakeAqiCubit,
        );

        await cubit.initDashboard();

        // Must reset from previous GPS city to Hanoi
        expect(cubit.state.currentCity, CityEntity.defaultCity);
        expect(cubit.state.currentCity.name, 'Hà Nội');
        expect(cubit.state.currentCity.isGps, isFalse);
        expect(cubit.state.isLocationPermissionGranted, isFalse);
        expect(storage.isLocationPermissionGranted(), isFalse);

        cubit.close();
        fakeWeatherCubit.close();
        fakeAqiCubit.close();
      },
    );

    test(
      'HomeDashboardCubit sets GPS city only when location permission is successfully granted',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorage(prefs: prefs);

        // Location permission GRANTED with coordinates in HCMC
        final fakeLocationService = _FakeLocationService(
          isGranted: true,
          result: const LocationResult(
            latitude: 10.8231,
            longitude: 106.6297,
            cityName: 'TP. Hồ Chí Minh',
            isDefault: false,
            isPermissionDenied: false,
          ),
        );

        final fakeWeatherCubit = _FakeWeatherCubit();
        final fakeAqiCubit = _FakeAirQualityCubit();

        final cubit = HomeDashboardCubit(
          storage: storage,
          locationService: fakeLocationService,
          weatherCubit: fakeWeatherCubit,
          airQualityCubit: fakeAqiCubit,
        );

        await cubit.detectGpsLocation();

        expect(cubit.state.currentCity.isGps, isTrue);
        expect(cubit.state.currentCity.name, 'Vị trí hiện tại (TP. Hồ Chí Minh)');
        expect(cubit.state.isLocationPermissionGranted, isTrue);
        expect(storage.isLocationPermissionGranted(), isTrue);

        cubit.close();
        fakeWeatherCubit.close();
        fakeAqiCubit.close();
      },
    );

    test(
      'MapPollutionCubit clearUserGpsLocation removes user GPS coordinates',
      () {
        final fakeRepo = _FakeMapPollutionRepository([]);
        final cubit = MapPollutionCubit(repository: fakeRepo);

        cubit.setUserGpsLocation(const LatLng(21.0285, 105.8542));
        expect(cubit.state.userGpsLocation, isNotNull);

        cubit.clearUserGpsLocation();
        expect(cubit.state.userGpsLocation, isNull);

        cubit.close();
      },
    );

    test(
      'MapPollutionCubit loadUserGpsLocation clears userGpsLocation when location permission is false',
      () async {
        final fakeRepo = _FakeMapPollutionRepository([]);
        final fakeLocationService = _FakeLocationService(
          isGranted: false,
          result: const LocationResult(
            latitude: 21.0285,
            longitude: 105.8542,
            isDefault: true,
            isPermissionDenied: true,
          ),
        );
        final cubit = MapPollutionCubit(
          repository: fakeRepo,
          locationService: fakeLocationService,
        );

        cubit.setUserGpsLocation(const LatLng(10.8231, 106.6297));
        expect(cubit.state.userGpsLocation, isNotNull);

        await cubit.loadUserGpsLocation();
        expect(cubit.state.userGpsLocation, isNull);

        cubit.close();
      },
    );

    test(
      'MapPollutionCubit loadUserGpsLocation sets userGpsLocation when location permission is true',
      () async {
        final fakeRepo = _FakeMapPollutionRepository([]);
        final fakeLocationService = _FakeLocationService(
          isGranted: true,
          result: const LocationResult(
            latitude: 10.8231,
            longitude: 106.6297,
            cityName: 'TP. Hồ Chí Minh',
            isDefault: false,
            isPermissionDenied: false,
          ),
        );
        final cubit = MapPollutionCubit(
          repository: fakeRepo,
          locationService: fakeLocationService,
        );

        await cubit.loadUserGpsLocation();
        expect(cubit.state.userGpsLocation, const LatLng(10.8231, 106.6297));

        cubit.close();
      },
    );
  });
}

class _FakeLocationService extends LocationService {
  final bool isGranted;
  final LocationResult result;

  _FakeLocationService({required this.isGranted, required this.result});

  @override
  Future<bool> checkPermissionGranted() async => isGranted;

  @override
  Future<LocationResult> getCurrentLocation({bool allowIpFallback = false}) async => result;
}

class _FakeMapPollutionRepository implements IMapPollutionRepository {
  final List<StationPollutionEntity> stations;
  _FakeMapPollutionRepository(this.stations);

  @override
  Future<BaseResult<List<StationPollutionEntity>>> getVietnamStations() async {
    return BaseResult(success: true, data: stations);
  }
}

class _FakeHomeDashboardCubit extends Cubit<HomeDashboardState>
    implements HomeDashboardCubit {
  _FakeHomeDashboardCubit([HomeDashboardState? state])
      : super(state ?? const HomeDashboardState());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWeatherCubit extends Cubit<WeatherState> implements WeatherCubit {
  _FakeWeatherCubit([WeatherState? state])
      : super(state ?? const WeatherState());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAirQualityCubit extends Cubit<AirQualityState>
    implements AirQualityCubit {
  _FakeAirQualityCubit([AirQualityState? state])
      : super(state ?? const AirQualityState());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
