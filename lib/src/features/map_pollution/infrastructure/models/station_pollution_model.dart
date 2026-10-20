import '../../domain/entities/station_pollution_entity.dart';
import '../../domain/entities/vietnam_monitoring_station.dart';

class StationPollutionModel extends StationPollutionEntity {
  const StationPollutionModel({
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

  /// Parse dữ liệu đo thực tế từ API Open-Meteo kết hợp với metadata trạm
  factory StationPollutionModel.fromApiResponse({
    required VietnamMonitoringStation station,
    required Map<String, dynamic> currentData,
  }) {
    return StationPollutionModel(
      id: station.id,
      name: station.stationName,
      province: station.province,
      latitude: station.latitude,
      longitude: station.longitude,
      aqi: int.tryParse(currentData['us_aqi']?.toString() ?? '') ?? station.defaultAqi,
      pm25: double.tryParse(currentData['pm2_5']?.toString() ?? '') ?? station.defaultPm25,
      pm10: double.tryParse(currentData['pm10']?.toString() ?? '') ?? station.defaultPm10,
      updatedAt: DateTime.now(),
      temperature: station.defaultTemp,
      weatherCode: station.defaultWeatherCode,
      humidity: station.defaultHumidity,
      windSpeed: station.defaultWindSpeed,
    );
  }

  /// Khởi tạo dữ liệu dự phòng từ metadata trạm quan trắc khi ngoại tuyến hoặc lỗi mạng
  factory StationPollutionModel.fromStation(VietnamMonitoringStation station) {
    return StationPollutionModel(
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
