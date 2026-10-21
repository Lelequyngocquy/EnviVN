import '../../domain/entities/station_entity.dart';
import '../../domain/entities/vietnam_monitoring_station.dart';

class StationModel extends StationEntity {
  const StationModel({
    required super.id,
    required super.name,
    required super.province,
    required super.latitude,
    required super.longitude,
    required super.aqi,
    required super.pm25,
    required super.pm10,
    required super.updatedAt,
    super.temperature,
    super.weatherCode,
    super.humidity,
    super.windSpeed,
  });

  factory StationModel.fromApiResponse({
    required VietnamMonitoringStation station,
    required Map<String, dynamic> currentData,
  }) {
    return StationModel(
      id: station.id,
      name: station.stationName,
      province: station.province,
      latitude: station.latitude,
      longitude: station.longitude,
      aqi:
          int.tryParse(currentData['us_aqi']?.toString() ?? '') ??
          station.defaultAqi,
      pm25:
          double.tryParse(currentData['pm2_5']?.toString() ?? '') ??
          station.defaultPm25,
      pm10:
          double.tryParse(currentData['pm10']?.toString() ?? '') ??
          station.defaultPm10,
      updatedAt: DateTime.now(),
      temperature: station.defaultTemp,
      weatherCode: station.defaultWeatherCode,
      humidity: station.defaultHumidity,
      windSpeed: station.defaultWindSpeed,
    );
  }

  factory StationModel.fromStation(VietnamMonitoringStation station) {
    return StationModel(
      id: station.id,
      name: station.stationName,
      province: station.province,
      latitude: station.latitude,
      longitude: station.longitude,
      aqi: station.defaultAqi,
      pm25: station.defaultPm25,
      pm10: station.defaultPm10,
      updatedAt: DateTime.now(),
      temperature: station.defaultTemp,
      weatherCode: station.defaultWeatherCode,
      humidity: station.defaultHumidity,
      windSpeed: station.defaultWindSpeed,
    );
  }
}
