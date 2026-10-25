import 'package:flutter_test/flutter_test.dart';
import 'package:envivn/src/core/domain/entities/app_location_entity.dart';
import 'package:envivn/src/core/domain/entities/base.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/air_quality/domain/interfaces/i_air_quality_repository.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_cubit.dart';
import 'package:envivn/src/features/air_quality/presentation/cubits/air_quality_state.dart';

class FakeAirQualityRepository implements IAirQualityRepository {
  AirQualityEntity? cached;
  BaseResult<AirQualityEntity>? nextResult;

  @override
  AirQualityEntity? getCachedAirQuality({
    double? latitude,
    double? longitude,
  }) => cached;

  @override
  Future<BaseResult<AirQualityEntity>> getAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    await Future<void>.delayed(Duration.zero);
    return nextResult ??
        BaseResult<AirQualityEntity>(
          success: true,
          data: const AirQualityEntity(usAqi: 50, pm25: 15.0),
        );
  }
}

void main() {
  late FakeAirQualityRepository repository;
  late AirQualityCubit cubit;

  setUp(() {
    repository = FakeAirQualityRepository();
  });

  tearDown(() {
    cubit.close();
  });

  group('AirQualityCubit Tests', () {
    test('initial state loads cached data if present', () {
      repository.cached = const AirQualityEntity(usAqi: 75, pm25: 25.0);
      cubit = AirQualityCubit(repository: repository);

      expect(cubit.state.status, equals(AirQualityStatus.success));
      expect(cubit.state.airQuality.usAqi, equals(75));
      expect(cubit.state.noticeMessage, equals('Dữ liệu đã lưu ngoại tuyến'));
    });

    test(
      'fetchAirQuality success emits loading then success with data',
      () async {
        cubit = AirQualityCubit(repository: repository);
        repository.nextResult = BaseResult<AirQualityEntity>(
          success: true,
          data: const AirQualityEntity(usAqi: 42, pm25: 10.5),
          message: 'Cập nhật thành công',
        );

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<AirQualityState>(
              (s) => s.status == AirQualityStatus.loading,
            ),
            predicate<AirQualityState>(
              (s) =>
                  s.status == AirQualityStatus.success &&
                  s.airQuality.usAqi == 42 &&
                  s.noticeMessage == 'Cập nhật thành công',
            ),
          ]),
        );

        await cubit.fetchAirQuality(latitude: 21.0, longitude: 105.8);
        await expectation;
      },
    );

    test(
      'fetchAirQuality failure emits loading then failure with error message',
      () async {
        cubit = AirQualityCubit(repository: repository);
        repository.nextResult = BaseResult<AirQualityEntity>(
          success: false,
          code: '500',
          message: 'Lỗi máy chủ',
        );

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            predicate<AirQualityState>(
              (s) => s.status == AirQualityStatus.loading,
            ),
            predicate<AirQualityState>(
              (s) =>
                  s.status == AirQualityStatus.failure &&
                  s.errorMessage == 'Lỗi máy chủ',
            ),
          ]),
        );

        await cubit.fetchAirQuality(latitude: 21.0, longitude: 105.8);
        await expectation;
      },
    );

    test('fetchForLocation delegates coordinates properly', () async {
      cubit = AirQualityCubit(repository: repository);
      repository.nextResult = BaseResult<AirQualityEntity>(
        success: true,
        data: const AirQualityEntity(usAqi: 30, pm25: 8.0),
      );

      await cubit.fetchForLocation(
        AppLocationEntity.city(
          name: 'Đà Nẵng',
          province: 'Đà Nẵng',
          latitude: 16.05,
          longitude: 108.2,
        ),
      );

      expect(cubit.state.status, equals(AirQualityStatus.success));
      expect(cubit.state.airQuality.usAqi, equals(30));
    });
  });
}
