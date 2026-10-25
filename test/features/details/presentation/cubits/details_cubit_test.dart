import 'package:flutter_test/flutter_test.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/core/domain/entities/base.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/features/details/domain/interfaces/i_details_repository.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_cubit.dart';
import 'package:envivn/src/features/details/presentation/cubits/details_state.dart';
import 'package:envivn/src/features/details/presentation/widgets/detail_segmented_filter.dart';

class FakeDetailsRepository implements IDetailsRepository {
  DetailsEntity? cached;
  BaseResult<DetailsEntity>? nextResult;

  @override
  DetailsEntity? getCachedDetails({double? latitude, double? longitude}) =>
      cached;

  @override
  DetailsEntity? getCachedWeather({double? latitude, double? longitude}) =>
      cached;

  @override
  Future<BaseResult<DetailsEntity>> getDetailsForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    await Future<void>.delayed(Duration.zero);
    return nextResult ??
        BaseResult<DetailsEntity>(
          success: true,
          data: const DetailsEntity(currentTemp: 28.0, relativeHumidity: 70),
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

void main() {
  late FakeDetailsRepository repository;
  late DetailsCubit cubit;

  setUp(() {
    repository = FakeDetailsRepository();
  });

  tearDown(() {
    cubit.close();
  });

  group('DetailsCubit Tests', () {
    test('initial state loads cached details if present', () {
      repository.cached = const DetailsEntity(
        currentTemp: 32.0,
        relativeHumidity: 80,
      );
      cubit = DetailsCubit(repository: repository);

      expect(cubit.state.status, equals(DetailsStatus.success));
      expect(cubit.state.details.currentTemp, equals(32.0));
      expect(cubit.state.noticeMessage, equals('Dữ liệu đã lưu ngoại tuyến'));
    });

    test('setDetailTab switches active tab correctly', () {
      cubit = DetailsCubit(repository: repository);
      expect(cubit.state.activeDetailTab, equals(DetailTab.all));

      cubit.setDetailTab(DetailTab.weather);
      expect(cubit.state.activeDetailTab, equals(DetailTab.weather));

      cubit.setDetailTab(DetailTab.airQuality);
      expect(cubit.state.activeDetailTab, equals(DetailTab.airQuality));
    });

    test('fetchDetails success emits loading then success with data', () async {
      cubit = DetailsCubit(repository: repository);
      repository.nextResult = BaseResult<DetailsEntity>(
        success: true,
        data: const DetailsEntity(currentTemp: 25.5, relativeHumidity: 65),
        message: 'Dữ liệu thời tiết mới nhất',
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<DetailsState>((s) => s.status == DetailsStatus.loading),
          predicate<DetailsState>(
            (s) =>
                s.status == DetailsStatus.success &&
                s.details.currentTemp == 25.5 &&
                s.noticeMessage == 'Dữ liệu thời tiết mới nhất',
          ),
        ]),
      );

      await cubit.fetchDetails(latitude: 21.0, longitude: 105.8);
      await expectation;
    });

    test(
      'fetchDetails failure emits loading then failure with error message',
      () async {
        cubit = DetailsCubit(repository: repository);
        repository.nextResult = BaseResult<DetailsEntity>(
          success: false,
          code: '404',
          message: 'Không tìm thấy dữ liệu',
        );

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<DetailsState>((s) => s.status == DetailsStatus.loading),
            predicate<DetailsState>(
              (s) =>
                  s.status == DetailsStatus.failure &&
                  s.errorMessage == 'Không tìm thấy dữ liệu',
            ),
          ]),
        );

        await cubit.fetchDetails(latitude: 21.0, longitude: 105.8);
        await expectation;
      },
    );

    test(
      'fetchWeather and fetchForLocation delegate coordinates properly',
      () async {
        cubit = DetailsCubit(repository: repository);
        repository.nextResult = BaseResult<DetailsEntity>(
          success: true,
          data: const DetailsEntity(currentTemp: 22.0),
        );

        await cubit.fetchWeather(latitude: 16.0, longitude: 108.0);
        expect(cubit.state.status, equals(DetailsStatus.success));

        await cubit.fetchForLocation(
          AppLocationEntity.city(
            name: 'Hải Phòng',
            province: 'Hải Phòng',
            latitude: 20.8,
            longitude: 106.6,
          ),
        );
        expect(cubit.state.status, equals(DetailsStatus.success));
      },
    );
  });
}
