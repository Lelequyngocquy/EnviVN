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
  });

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
      ];
}
