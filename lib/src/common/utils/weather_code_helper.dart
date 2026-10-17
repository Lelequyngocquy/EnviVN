import 'package:flutter/material.dart';

class WeatherCodeInfo {
  final String description;
  final IconData icon;

  const WeatherCodeInfo(this.description, this.icon);
}

class WeatherCodeHelper {
  WeatherCodeHelper._();

  static WeatherCodeInfo getInfo(int? code) {
    if (code == null) return const WeatherCodeInfo('Không rõ', Icons.cloud_outlined);

    switch (code) {
      case 0:
        return const WeatherCodeInfo('Trời quang đãng', Icons.wb_sunny_rounded);
      case 1:
        return const WeatherCodeInfo('Hầu như không mây', Icons.wb_sunny_outlined);
      case 2:
        return const WeatherCodeInfo('Mây rải rác', Icons.cloud_queue_rounded);
      case 3:
        return const WeatherCodeInfo('Trời nhiều mây', Icons.cloud_rounded);
      case 45:
      case 48:
        return const WeatherCodeInfo('Có sương mù', Icons.blur_on_rounded);
      case 51:
      case 53:
      case 55:
        return const WeatherCodeInfo('Mưa phùn nhẹ', Icons.grain_rounded);
      case 61:
        return const WeatherCodeInfo('Mưa nhỏ', Icons.water_drop_outlined);
      case 63:
        return const WeatherCodeInfo('Mưa vừa', Icons.water_drop_rounded);
      case 65:
        return const WeatherCodeInfo('Mưa rào lớn', Icons.thunderstorm_rounded);
      case 80:
      case 81:
      case 82:
        return const WeatherCodeInfo('Mưa rào bất chợt', Icons.shower_rounded);
      case 95:
      case 96:
      case 99:
        return const WeatherCodeInfo('Dông sét & Mưa bão', Icons.flash_on_rounded);
      default:
        return const WeatherCodeInfo('Có mây', Icons.cloud_outlined);
    }
  }
}
