import '../../domain/entities/vietnam_province.dart';

class NasaFirmsPaths {
  static const defaultSatellite = 'VIIRS_NOAA20_NRT';

  static String areaCsv({
    required String baseUrl,
    required String apiKey,
    required int dayRange,
    String satellite = defaultSatellite,
    String bbox = VietnamProvince.vietnamBoundingBox,
  }) {
    return '$baseUrl/area/csv/$apiKey/$satellite/$bbox/$dayRange';
  }
}
