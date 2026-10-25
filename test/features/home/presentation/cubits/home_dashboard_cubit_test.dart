import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/core/domain/entities/base.dart';
import 'package:envivn/src/core/infrastructure/datasources/local/local_storage.dart';
import 'package:envivn/src/core/infrastructure/services/location_service.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/air_quality/domain/interfaces/i_air_quality_repository.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/features/details/domain/interfaces/i_details_repository.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_cubit.dart';
import 'package:envivn/src/features/home/presentation/cubits/home_dashboard_state.dart';

class FakeLocationService extends LocationService {
  bool isGranted = true;

  @override
  Future<bool> checkPermissionGranted() async => isGranted;

  @override
  Future<LocationResult> getCurrentLocation({
    bool allowIpFallback = false,
  }) async {
    return const LocationResult(
      latitude: 10.7769,
      longitude: 106.7009,
      cityName: 'TP. Hồ Chí Minh',
    );
  }
}

class FakeDetailsRepository implements IDetailsRepository {
  @override
  DetailsEntity? getCachedDetails({double? latitude, double? longitude}) =>
      null;

  @override
  DetailsEntity? getCachedWeather({double? latitude, double? longitude}) =>
      null;

  @override
  Future<BaseResult<DetailsEntity>> getDetailsForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    return BaseResult<DetailsEntity>(
      success: true,
      data: const DetailsEntity(currentTemp: 30.0),
    );
  }

  @override
  Future<BaseResult<DetailsEntity>> getWeatherForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) => getDetailsForecast(
    latitude: latitude,
    longitude: longitude,
    forceRefresh: forceRefresh,
  );
}

class FakeAirQualityRepository implements IAirQualityRepository {
  @override
  AirQualityEntity? getCachedAirQuality({
    double? latitude,
    double? longitude,
  }) => null;

  @override
  Future<BaseResult<AirQualityEntity>> getAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    return BaseResult<AirQualityEntity>(
      success: true,
      data: const AirQualityEntity(usAqi: 55),
    );
  }
}

void main() {
  late LocalStorage storage;
  late FakeLocationService locationService;
  late DetailsCubit detailsCubit;
  late AirQualityCubit airQualityCubit;
  late HomeDashboardCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = LocalStorage(prefs: prefs);

    locationService = FakeLocationService();
    detailsCubit = DetailsCubit(repository: FakeDetailsRepository());
    airQualityCubit = AirQualityCubit(repository: FakeAirQualityRepository());

    cubit = HomeDashboardCubit(
      storage: storage,
      locationService: locationService,
      detailsCubit: detailsCubit,
      airQualityCubit: airQualityCubit,
    );
  });

  tearDown(() {
    cubit.close();
    detailsCubit.close();
    airQualityCubit.close();
  });

  group('HomeDashboardCubit Tests', () {
    test('initial state has default tab 0 and empty city', () {
      expect(cubit.state.currentTab, equals(0));
      expect(cubit.state.status, equals(DashboardStatus.initial));
    });

    test('setTab switches tab correctly', () {
      cubit.setTab(1);
      expect(cubit.state.currentTab, equals(1));

      cubit.setTab(2);
      expect(cubit.state.currentTab, equals(2));
    });

    test('handleBackPress switches tab to 0 if not on tab 0', () {
      cubit.setTab(2);
      expect(cubit.state.currentTab, equals(2));

      final handled = cubit.handleBackPress();
      expect(handled, isTrue);
      expect(cubit.state.currentTab, equals(0));

      final handledAgain = cubit.handleBackPress();
      expect(handledAgain, isFalse);
    });

    test('markPendingMapSync and consumeMapSync work properly', () {
      expect(cubit.state.hasPendingMapSync, isTrue);

      cubit.consumeMapSync();
      expect(cubit.state.hasPendingMapSync, isFalse);

      cubit.markPendingMapSync();
      expect(cubit.state.hasPendingMapSync, isTrue);
    });

    test(
      'changeCity updates currentCity, saves to storage and fetches data',
      () async {
        final newCity = AppLocationEntity.city(
          name: 'Đà Nẵng',
          province: 'Đà Nẵng',
          latitude: 16.0544,
          longitude: 108.2022,
        );

        await cubit.changeCity(newCity);

        expect(cubit.state.currentCity.name, equals('Đà Nẵng'));
        expect(cubit.state.status, equals(DashboardStatus.success));

        final saved = storage.getSelectedCity();
        expect(saved, isNotNull);
        expect(saved!['name'], equals('Đà Nẵng'));
      },
    );

    test('initDashboard loads saved city from storage if available', () async {
      await storage.saveSelectedCity('Huế', 16.4637, 107.5909);

      await cubit.initDashboard();

      expect(cubit.state.currentCity.name, equals('Huế'));
      expect(cubit.state.status, equals(DashboardStatus.success));
    });
  });
}
