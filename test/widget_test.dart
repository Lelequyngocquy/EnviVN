import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:envivn/src/common/utils/activity_advice_helper.dart';
import 'package:envivn/src/common/utils/aqi_helper.dart';
import 'package:envivn/src/common/utils/date_helper.dart';
import 'package:envivn/src/common/utils/weather_code_helper.dart';
import 'package:envivn/src/core/domain/entities/base.dart';
import 'package:envivn/src/core/infrastructure/configs/env_config.dart';
import 'package:envivn/src/core/presentation/widgets/app_dialog.dart';
import 'package:envivn/src/core/presentation/widgets/app_status_tag.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';
import 'package:envivn/src/features/home/presentation/widgets/location_loading_overlay.dart';
import 'package:envivn/src/features/map_pollution/domain/entities/station_pollution_entity.dart';
import 'package:envivn/src/features/map_pollution/domain/interfaces/i_map_pollution_repository.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_cubit.dart';
import 'package:envivn/src/features/map_pollution/presentation/cubits/map_pollution_state.dart';

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
  });
}

class _FakeMapPollutionRepository implements IMapPollutionRepository {
  final List<StationPollutionEntity> stations;
  _FakeMapPollutionRepository(this.stations);

  @override
  Future<BaseResult<List<StationPollutionEntity>>> getVietnamStations() async {
    return BaseResult(success: true, data: stations);
  }
}
