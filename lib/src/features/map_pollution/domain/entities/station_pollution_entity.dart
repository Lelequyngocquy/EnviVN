import 'package:envivn/src/common/utils/heat_index_helper.dart';

class StationPollutionEntity {
  final String id;
  final String name;
  final String province;
  final double latitude;
  final double longitude;
  final int aqi;
  final double pm25;
  final double pm10;
  final DateTime updatedAt;

  // Weather & Climate Fields
  final double? temperature;
  final double? apparentTemp;
  final int? weatherCode;
  final int? humidity;
  final double? windSpeed;
  final double? precipitation;
  final double? uvIndex;

  // Flood / Blackspot Context (cho các điểm đen ngập úng đô thị)
  final bool isFloodBlackspot;
  final int? historicalDepthCm;
  final String? floodTriggerCondition;
  final String? floodProneTime;
  final String? spotDescription;

  // Thermal / Fire Hotspot Context (cho các điểm nhiệt & cháy)
  final bool isThermalHotspot;
  final bool isActiveFire;
  final String? fireType;
  final double? fireBrightnessCelsius;
  final double? fireConfidence;
  final String? fireProneSeason;
  final String? fireDetectedTime;

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
    this.apparentTemp,
    this.weatherCode,
    this.humidity,
    this.windSpeed,
    this.precipitation,
    this.uvIndex,
    this.isFloodBlackspot = false,
    this.historicalDepthCm,
    this.floodTriggerCondition,
    this.floodProneTime,
    this.spotDescription,
    this.isThermalHotspot = false,
    this.isActiveFire = false,
    this.fireType,
    this.fireBrightnessCelsius,
    this.fireConfidence,
    this.fireProneSeason,
    this.fireDetectedTime,
  });

  /// Tính chỉ số nhiệt cảm nhận (Heat Index) theo công thức NOAA / Steadman
  double get calculatedHeatIndex => HeatIndexHelper.calculateHeatIndex(
        temperature ?? 28.0,
        humidity ?? 70,
      );

  /// Cấp độ rủi ro sốc nhiệt
  HeatRiskLevel get heatRiskLevel =>
      HeatIndexHelper.getRiskLevel(calculatedHeatIndex);

  /// Cảnh báo rủi ro ngập úng khi lượng mưa thực tế >= 20mm/h
  bool get isHighFloodRisk => (precipitation ?? 0.0) >= 20.0;

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
    double? apparentTemp,
    int? weatherCode,
    int? humidity,
    double? windSpeed,
    double? precipitation,
    double? uvIndex,
    bool? isFloodBlackspot,
    int? historicalDepthCm,
    String? floodTriggerCondition,
    String? floodProneTime,
    String? spotDescription,
    bool? isThermalHotspot,
    bool? isActiveFire,
    String? fireType,
    double? fireBrightnessCelsius,
    double? fireConfidence,
    String? fireProneSeason,
    String? fireDetectedTime,
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
      apparentTemp: apparentTemp ?? this.apparentTemp,
      weatherCode: weatherCode ?? this.weatherCode,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      precipitation: precipitation ?? this.precipitation,
      uvIndex: uvIndex ?? this.uvIndex,
      isFloodBlackspot: isFloodBlackspot ?? this.isFloodBlackspot,
      historicalDepthCm: historicalDepthCm ?? this.historicalDepthCm,
      floodTriggerCondition:
          floodTriggerCondition ?? this.floodTriggerCondition,
      floodProneTime: floodProneTime ?? this.floodProneTime,
      spotDescription: spotDescription ?? this.spotDescription,
      isThermalHotspot: isThermalHotspot ?? this.isThermalHotspot,
      isActiveFire: isActiveFire ?? this.isActiveFire,
      fireType: fireType ?? this.fireType,
      fireBrightnessCelsius:
          fireBrightnessCelsius ?? this.fireBrightnessCelsius,
      fireConfidence: fireConfidence ?? this.fireConfidence,
      fireProneSeason: fireProneSeason ?? this.fireProneSeason,
      fireDetectedTime: fireDetectedTime ?? this.fireDetectedTime,
    );
  }
}
