class AirQualityEntity {
  final int usAqi;
  final int europeanAqi;
  final double pm25; // µg/m³
  final double pm10; // µg/m³
  final double carbonMonoxide; // µg/m³
  final double nitrogenDioxide; // µg/m³
  final double sulphurDioxide; // µg/m³
  final double ozone; // µg/m³
  final List<HourlyAqiPoint> hourlyAqi;
  final bool isOfflineCache;

  const AirQualityEntity({
    this.usAqi = 0,
    this.europeanAqi = 0,
    this.pm25 = 0.0,
    this.pm10 = 0.0,
    this.carbonMonoxide = 0.0,
    this.nitrogenDioxide = 0.0,
    this.sulphurDioxide = 0.0,
    this.ozone = 0.0,
    this.hourlyAqi = const [],
    this.isOfflineCache = false,
  });
}

class HourlyAqiPoint {
  final DateTime time;
  final int aqi;
  final double pm25;
  final double pm10;

  const HourlyAqiPoint({
    required this.time,
    required this.aqi,
    required this.pm25,
    required this.pm10,
  });
}
