import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/base.dart';
import '../../../../core/infrastructure/datasources/network/api/configs/endpoint.dart';
import '../../../../core/infrastructure/datasources/network/api/restful_request.dart';
import '../../domain/entities/station_entity.dart';
import '../../domain/entities/vietnam_monitoring_station.dart';
import '../../domain/interfaces/i_map_repository.dart';
import '../models/station_model.dart';
import '../paths/map_paths.dart';

class MapRepository implements IMapRepository {
  final RestfulRequest network;

  MapRepository({required this.network});

  @override
  Future<BaseResult<List<StationEntity>>> getVietnamStations() async {
    final stationList = VietnamMonitoringStation.values;
    try {
      final latitudes = stationList.map((s) => s.latitude.toString()).join(',');
      final longitudes = stationList
          .map((s) => s.longitude.toString())
          .join(',');

      final endpoint = EndpointType(
        path: MapPaths.airQualityPath,
        customBaseUrl: MapPaths.airQualityBaseUrl,
        method: HttpMethod.get,
        params: {
          'latitude': latitudes,
          'longitude': longitudes,
          'current': 'us_aqi,pm2_5,pm10',
          'timezone': 'auto',
        },
      );

      final res = await network.requestData(endpoint, showErrorToast: false);
      if (res.isSuccess && res.data is List) {
        final list = res.data as List;
        final stations = <StationEntity>[];
        for (int i = 0; i < stationList.length; i++) {
          final station = stationList[i];
          if (i < list.length && list[i] is Map) {
            final cur =
                (list[i] as Map)['current'] as Map<String, dynamic>? ?? {};
            stations.add(
              StationModel.fromApiResponse(station: station, currentData: cur),
            );
          } else {
            stations.add(StationModel.fromStation(station));
          }
        }
        return BaseResult(success: true, data: stations);
      } else if (res.isSuccess && res.data is Map) {
        final cur = (res.data as Map)['current'] as Map<String, dynamic>? ?? {};
        final stations = stationList
            .map(
              (s) => StationModel.fromApiResponse(station: s, currentData: cur),
            )
            .toList();
        return BaseResult(success: true, data: stations);
      }

      final fallbackStations = stationList
          .map(StationModel.fromStation)
          .toList();
      return BaseResult(
        success: false,
        message: 'Không nhận được dữ liệu hợp lệ từ máy chủ',
        data: fallbackStations,
      );
    } catch (e) {
      debugPrint('[MapRepository] Lỗi: $e');
      final fallbackStations = stationList
          .map(StationModel.fromStation)
          .toList();
      return BaseResult(
        success: false,
        message: 'Lỗi tải danh sách trạm quan trắc: $e',
        data: fallbackStations,
      );
    }
  }
}
