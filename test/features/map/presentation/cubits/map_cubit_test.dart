import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:envivn/src/core/domain/entities/base.dart';
import 'package:envivn/src/features/air_quality/domain/entities/air_quality_entity.dart';
import 'package:envivn/src/features/air_quality/domain/interfaces/i_air_quality_repository.dart';
import 'package:envivn/src/features/map/domain/entities/map_layer_type.dart';
import 'package:envivn/src/features/map/domain/entities/quick_city_target.dart';
import 'package:envivn/src/features/map/domain/entities/station_entity.dart';
import 'package:envivn/src/features/map/domain/interfaces/i_map_repository.dart';
import 'package:envivn/src/features/map/presentation/cubits/map_cubit.dart';
import 'package:envivn/src/features/details/domain/entities/details_entity.dart';
import 'package:envivn/src/features/details/domain/interfaces/i_details_repository.dart';

class FakeMapRepository implements IMapRepository {
  @override
  Future<BaseResult<List<StationEntity>>> getVietnamStations() async {
    return BaseResult(
      data: [
        StationEntity(
          id: 'station_1',
          name: 'Trạm Định Quán',
          province: 'Đồng Nai',
          latitude: 11.1,
          longitude: 107.2,
          aqi: 65,
          pm25: 18.5,
          pm10: 25.0,
          updatedAt: DateTime.now(),
        ),
      ],
    );
  }
}

class FakeDetailsRepository implements IDetailsRepository {
  @override
  Future<BaseResult<DetailsEntity>> getDetailsForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    return BaseResult(
      data: const DetailsEntity(
        currentTemp: 29.5,
        apparentTemp: 32.0,
        relativeHumidity: 75,
        weatherCode: 1,
        windSpeed: 12.0,
      ),
    );
  }

  @override
  DetailsEntity? getCachedDetails({double? latitude, double? longitude}) =>
      null;

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

  @override
  DetailsEntity? getCachedWeather({double? latitude, double? longitude}) =>
      null;
}

typedef FakeWeatherRepository = FakeDetailsRepository;

class FakeAirQualityRepository implements IAirQualityRepository {
  @override
  Future<BaseResult<AirQualityEntity>> getAirQuality({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    return BaseResult(
      data: const AirQualityEntity(usAqi: 82, pm25: 27.4, pm10: 45.0),
    );
  }

  @override
  AirQualityEntity? getCachedAirQuality({
    double? latitude,
    double? longitude,
  }) => null;
}

void main() {
  late MapCubit cubit;
  late FakeMapRepository mapRepo;
  late FakeWeatherRepository weatherRepo;
  late FakeAirQualityRepository airRepo;

  setUp(() {
    mapRepo = FakeMapRepository();
    weatherRepo = FakeWeatherRepository();
    airRepo = FakeAirQualityRepository();
    cubit = MapCubit(
      repository: mapRepo,
      weatherRepository: weatherRepo,
      airQualityRepository: airRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('MapCubit Custom Location Picker Tests', () {
    test(
      'pickCustomLocation sets pickedLocation and enriches with AQI & Weather',
      () async {
        const point = LatLng(10.8231, 106.6297);

        expect(cubit.state.pickedLocation, isNull);

        final pickFuture = cubit.pickCustomLocation(point);

        expect(cubit.state.pickedLocation, point);

        await pickFuture;

        expect(cubit.state.isPickingLocation, isFalse);
        expect(cubit.state.pickedLocation, point);
        expect(cubit.state.selectedStation, isNotNull);
        expect(cubit.state.selectedStation!.aqi, 82);
        expect(cubit.state.selectedStation!.pm25, 27.4);
        expect(cubit.state.selectedStation!.temperature, 29.5);
        expect(cubit.state.selectedStation!.humidity, 75);
      },
    );

    test(
      'clearPickedLocation resets pickedLocation and closes selected picked station',
      () async {
        const point = LatLng(10.8231, 106.6297);
        await cubit.pickCustomLocation(point);

        expect(cubit.state.pickedLocation, isNotNull);
        expect(cubit.state.selectedStation, isNotNull);

        cubit.clearPickedLocation();

        expect(cubit.state.pickedLocation, isNull);
        expect(cubit.state.selectedStation, isNull);
        expect(cubit.state.isPickingLocation, isFalse);
      },
    );

    test(
      'pickCustomLocation clears previously selected city and isHomeSelected',
      () async {
        cubit.selectQuickCity(QuickCityTarget.hanoi);
        expect(cubit.state.selectedQuickCity, QuickCityTarget.hanoi);
        expect(cubit.state.selectedCityName, 'Hà Nội');
        expect(cubit.state.isHomeSelected, isFalse);

        await cubit.pickCustomLocation(const LatLng(10.8231, 106.6297));

        expect(cubit.state.selectedQuickCity, isNull);
        expect(cubit.state.selectedCityName, isNull);
        expect(cubit.state.isHomeSelected, isFalse);
        expect(cubit.state.pickedLocation, isNotNull);
      },
    );

    test(
      'selecting a quick city after custom pick sets selectedQuickCity and clears pickedLocation',
      () async {
        await cubit.pickCustomLocation(const LatLng(10.8231, 106.6297));
        expect(cubit.state.pickedLocation, isNotNull);
        expect(cubit.state.selectedQuickCity, isNull);

        cubit.selectQuickCity(QuickCityTarget.daNang);

        expect(cubit.state.selectedQuickCity, QuickCityTarget.daNang);
        expect(cubit.state.selectedCityName, 'Đà Nẵng');
        expect(cubit.state.pickedLocation, isNull);
        expect(cubit.state.isHomeSelected, isFalse);
      },
    );

    test(
      'selectHomeLocation sets isHomeSelected and clears selectedQuickCity and pickedLocation',
      () async {
        cubit.selectQuickCity(QuickCityTarget.hanoi);
        expect(cubit.state.selectedQuickCity, QuickCityTarget.hanoi);

        cubit.selectHomeLocation(
          lat: 10.7769,
          lon: 106.7009,
          label: 'TP. Hồ Chí Minh',
        );

        expect(cubit.state.isHomeSelected, isTrue);
        expect(cubit.state.selectedQuickCity, isNull);
        expect(cubit.state.pickedLocation, isNull);
      },
    );

    test(
      'moveToUserGpsLocation moves to GPS location and returns true when userGpsLocation is set',
      () {
        cubit.setUserGpsLocation(const LatLng(10.7769, 106.7009));
        final success = cubit.moveToUserGpsLocation();

        expect(success, isTrue);
        expect(cubit.state.isHomeSelected, isTrue);
        expect(cubit.state.targetLocation, const LatLng(10.7769, 106.7009));
        expect(cubit.state.selectedCityName, 'Vị trí hiện tại');
      },
    );

    test(
      'moveToUserGpsLocation returns false when userGpsLocation is null',
      () {
        cubit.clearUserGpsLocation();
        final success = cubit.moveToUserGpsLocation();

        expect(success, isFalse);
      },
    );

    test(
      'showAllVietnam sets selectedQuickCity to allVietnam and clears pickedLocation',
      () {
        cubit.showAllVietnam();

        expect(cubit.state.selectedQuickCity, QuickCityTarget.allVietnam);
        expect(cubit.state.isHomeSelected, isFalse);
        expect(cubit.state.pickedLocation, isNull);
      },
    );

    test(
      'selectStation for Nha Trang (province: Khánh Hòa) sets selectedQuickCity to QuickCityTarget.nhaTrang',
      () {
        final nhaTrangStation = StationEntity(
          id: 'vn_nt_01',
          name: 'Trạm Nha Trang',
          province: 'Khánh Hòa',
          latitude: 12.2388,
          longitude: 109.1967,
          aqi: 45,
          pm25: 12.0,
          pm10: 20.0,
          updatedAt: DateTime.now(),
        );

        cubit.selectStation(nhaTrangStation);

        expect(cubit.state.selectedStation, nhaTrangStation);
        expect(cubit.state.selectedQuickCity, QuickCityTarget.nhaTrang);
        expect(cubit.state.selectedCityName, 'Nha Trang');
        expect(cubit.state.isHomeSelected, isFalse);
        expect(cubit.state.pickedLocation, isNull);
      },
    );

    test(
      'selectStation for Đà Lạt (province: Lâm Đồng) sets selectedQuickCity to QuickCityTarget.daLat',
      () {
        final daLatStation = StationEntity(
          id: 'vn_dl_01',
          name: 'Trạm TP. Đà Lạt',
          province: 'Lâm Đồng',
          latitude: 11.9404,
          longitude: 108.4583,
          aqi: 30,
          pm25: 8.0,
          pm10: 15.0,
          updatedAt: DateTime.now(),
        );

        cubit.selectStation(daLatStation);

        expect(cubit.state.selectedStation, daLatStation);
        expect(cubit.state.selectedQuickCity, QuickCityTarget.daLat);
        expect(cubit.state.selectedCityName, 'Đà Lạt');
        expect(cubit.state.isHomeSelected, isFalse);
        expect(cubit.state.pickedLocation, isNull);
      },
    );

    test(
      'selectStation for Hoàng Sa sets selectedQuickCity to QuickCityTarget.hoangSa',
      () {
        final hoangSaStation = StationEntity(
          id: 'vn_hs_01',
          name: 'Trạm Quần đảo Hoàng Sa',
          province: 'TP. Đà Nẵng',
          latitude: 16.5333,
          longitude: 112.0333,
          aqi: 25,
          pm25: 6.0,
          pm10: 12.0,
          updatedAt: DateTime.now(),
        );

        cubit.selectStation(hoangSaStation);

        expect(cubit.state.selectedStation, hoangSaStation);
        expect(cubit.state.selectedQuickCity, QuickCityTarget.hoangSa);
        expect(cubit.state.selectedCityName, 'Hoàng Sa');
      },
    );

    test(
      'selectStation for Trường Sa sets selectedQuickCity to QuickCityTarget.truongSa',
      () {
        final truongSaStation = StationEntity(
          id: 'vn_ts_01',
          name: 'Trạm Quần đảo Trường Sa',
          province: 'Tỉnh Khánh Hòa',
          latitude: 9.8833,
          longitude: 114.2500,
          aqi: 20,
          pm25: 5.0,
          pm10: 10.0,
          updatedAt: DateTime.now(),
        );

        cubit.selectStation(truongSaStation);

        expect(cubit.state.selectedStation, truongSaStation);
        expect(cubit.state.selectedQuickCity, QuickCityTarget.truongSa);
        expect(cubit.state.selectedCityName, 'Trường Sa');
      },
    );

    test(
      'selectStation for a station not in quickCities leaves selectedQuickCity null',
      () {
        final otherStation = StationEntity(
          id: 'vn_other_01',
          name: 'Trạm Định Quán',
          province: 'Đồng Nai',
          latitude: 11.1,
          longitude: 107.2,
          aqi: 65,
          pm25: 18.5,
          pm10: 25.0,
          updatedAt: DateTime.now(),
        );

        cubit.selectStation(otherStation);

        expect(cubit.state.selectedStation, otherStation);
        expect(cubit.state.selectedQuickCity, isNull);
        expect(cubit.state.selectedCityName, 'Đồng Nai');
        expect(cubit.state.isHomeSelected, isFalse);
        expect(cubit.state.pickedLocation, isNull);
      },
    );

    test(
      'activeLayer defaults to MapLayerType.weather and switches correctly while preserving state',
      () {
        expect(cubit.state.activeLayer, MapLayerType.weather);

        const targetPoint = LatLng(10.7769, 106.7009);
        cubit.selectLocationCoordinates(
          targetPoint.latitude,
          targetPoint.longitude,
          label: 'TP. HCM',
        );

        expect(cubit.state.selectedCityName, 'TP. HCM');
        expect(cubit.state.targetLocation, targetPoint);

        cubit.switchMapLayer(MapLayerType.airQuality);
        expect(cubit.state.activeLayer, MapLayerType.airQuality);
        expect(cubit.state.selectedCityName, 'TP. HCM');
        expect(cubit.state.targetLocation, targetPoint);

        cubit.switchMapLayer(MapLayerType.thermal);
        expect(cubit.state.activeLayer, MapLayerType.thermal);
        expect(cubit.state.selectedCityName, 'TP. HCM');

        cubit.switchMapLayer(MapLayerType.flood);
        expect(cubit.state.activeLayer, MapLayerType.flood);
        expect(cubit.state.selectedCityName, 'TP. HCM');
      },
    );

    test(
      'selectStation sets isLoadingPointData true initially, then false after weather enrichment',
      () async {
        final testStation = StationEntity(
          id: 'st_load_test',
          name: 'Trạm Test Loading',
          province: 'Đồng Nai',
          latitude: 11.0,
          longitude: 107.0,
          aqi: 55,
          pm25: 14.0,
          pm10: 20.0,
          updatedAt: DateTime.now(),
        );

        expect(cubit.state.isLoadingPointData, isFalse);

        cubit.selectStation(testStation);

        expect(cubit.state.isLoadingPointData, isTrue);
        expect(cubit.state.selectedStation?.id, 'st_load_test');

        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.isLoadingPointData, isFalse);
        expect(cubit.state.selectedStation?.temperature, 29.5);
      },
    );

    test(
      'pickCustomLocation sets isLoadingPointData true initially, then false after APIs return',
      () async {
        const point = LatLng(10.8231, 106.6297);
        expect(cubit.state.isLoadingPointData, isFalse);

        final pickFuture = cubit.pickCustomLocation(point);

        expect(cubit.state.isLoadingPointData, isTrue);
        expect(cubit.state.isPickingLocation, isTrue);

        await pickFuture;

        expect(cubit.state.isLoadingPointData, isFalse);
        expect(cubit.state.isPickingLocation, isFalse);
        expect(cubit.state.selectedStation?.aqi, 82);
        expect(cubit.state.selectedStation?.temperature, 29.5);
      },
    );

    test(
      'pickCustomLocation always formats distance (~Xkm từ province) even when > 30km',
      () async {
        await cubit.fetchVietnamStations();

        const closePoint = LatLng(11.13, 107.2);
        await cubit.pickCustomLocation(closePoint);

        expect(cubit.state.pickedLocation, closePoint);
        expect(cubit.state.pickedReferenceLocation, const LatLng(11.1, 107.2));
        expect(cubit.state.pickedDistanceKm, isNotNull);
        expect(cubit.state.pickedDistanceKm!, lessThan(10.0));
        expect(
          cubit.state.selectedStation?.name,
          contains('Điểm ghim (~3.3km từ Đồng Nai)'),
        );
        expect(cubit.state.selectedStation?.province, 'Đồng Nai');

        const farPoint = LatLng(12.4, 107.2);
        await cubit.pickCustomLocation(farPoint);

        expect(cubit.state.pickedLocation, farPoint);
        expect(cubit.state.pickedReferenceLocation, const LatLng(11.1, 107.2));
        expect(cubit.state.pickedDistanceKm, isNotNull);
        expect(cubit.state.pickedDistanceKm!, greaterThan(100.0));
        expect(
          cubit.state.selectedStation?.name,
          isNot(contains('(12.400, 107.200)')),
        );
        expect(
          cubit.state.selectedStation?.name,
          contains('Điểm ghim (~145km từ Đồng Nai)'),
        );
        expect(cubit.state.selectedStation?.province, 'Đồng Nai');

        cubit.clearPickedLocation();
        expect(cubit.state.pickedLocation, isNull);
        expect(cubit.state.pickedReferenceLocation, isNull);
        expect(cubit.state.pickedDistanceKm, isNull);
      },
    );
  });
}
