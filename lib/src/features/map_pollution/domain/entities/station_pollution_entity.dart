import 'package:equatable/equatable.dart';

class StationPollutionEntity extends Equatable {
  final String id;
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  final int aqi;
  final double pm25;
  final double pm10;
  final DateTime updatedAt;

  final double? temperature;
  final int? weatherCode;
  final int? humidity;
  final double? windSpeed;

  const StationPollutionEntity({
    required this.id,
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.updatedAt,
    this.temperature,
    this.weatherCode,
    this.humidity,
    this.windSpeed,
  });

  StationPollutionEntity copyWith({
    String? id,
    String? name,
    String? province,
    double? latitude,
    double? longitude,
    int? aqi,
    double? pm25,
    double? pm10,
    DateTime? updatedAt,
    double? temperature,
    int? weatherCode,
    int? humidity,
    double? windSpeed,
  }) {
    return StationPollutionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      aqi: aqi ?? this.aqi,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
      updatedAt: updatedAt ?? this.updatedAt,
      temperature: temperature ?? this.temperature,
      weatherCode: weatherCode ?? this.weatherCode,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        province,
        latitude,
        longitude,
        aqi,
        pm25,
        pm10,
        updatedAt,
        temperature,
        weatherCode,
        humidity,
        windSpeed,
      ];
}
