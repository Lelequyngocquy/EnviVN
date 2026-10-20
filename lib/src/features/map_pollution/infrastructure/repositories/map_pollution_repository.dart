import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/base.dart';
import '../../../../core/infrastructure/datasources/network/api/configs/endpoint.dart';
import '../../../../core/infrastructure/datasources/network/api/restful_request.dart';
import '../../domain/entities/station_pollution_entity.dart';
import '../../domain/entities/vietnam_monitoring_station.dart';
import '../../domain/interfaces/i_map_pollution_repository.dart';
import '../models/station_pollution_model.dart';
import '../paths/map_pollution_paths.dart';

class MapPollutionRepository implements IMapPollutionRepository {
  final RestfulRequest network;

  MapPollutionRepository({required this.network});

  @override
  Future<BaseResult<List<StationPollutionEntity>>> getVietnamStations() async {
    try {
      final stationFutures = VietnamMonitoringStation.values.map((station) async {
        final endpoint = EndpointType(
          path: MapPollutionPaths.airQualityPath,
          customBaseUrl: MapPollutionPaths.airQualityBaseUrl,
          method: HttpMethod.get,
          params: {
            'latitude': station.latitude,
            'longitude': station.longitude,
            'current': 'us_aqi,pm2_5,pm10',
            'timezone': 'auto',
          },
        );

        try {
          final res = await network.requestData(endpoint, showErrorToast: false);
          if (res.isSuccess && res.data is Map) {
            final cur = res.data['current'] as Map<String, dynamic>? ?? {};
            return StationPollutionModel.fromApiResponse(
              station: station,
              currentData: cur,
            );
          }
        } catch (_) {}

        return StationPollutionModel.fromStation(station);
      });

      final stations = await Future.wait(stationFutures);
      return BaseResult(success: true, data: stations);
    } catch (e) {
      debugPrint('❌ [MapPollutionRepository] Lỗi: $e');
      return BaseResult(
        success: false,
        message: 'Lỗi tải danh sách trạm quan trắc: $e',
        data: const [],
      );
    }
  }
}
