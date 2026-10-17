import 'package:flutter/material.dart';

class WeatherCodeInfo {
  final String description;
  final IconData icon;
  final Color color;
  final String shortLabel;
  final bool isRain;
  final bool isThunder;

  const WeatherCodeInfo(
    this.description,
    this.icon, {
    this.color = const Color(0xFF38BDF8),
    this.shortLabel = 'Thời tiết',
    this.isRain = false,
    this.isThunder = false,
  });
}

class WeatherCodeHelper {
  WeatherCodeHelper._();

  static WeatherCodeInfo getInfo(int? code) {
    if (code == null) {
      return const WeatherCodeInfo('Không rõ', Icons.cloud_outlined);
    }

    switch (code) {
      case 0:
        return const WeatherCodeInfo(
          'Trời quang đãng',
          Icons.wb_sunny_rounded,
          color: Color(0xFFFBBF24),
          shortLabel: 'Quang đãng',
        );
      case 1:
        return const WeatherCodeInfo(
          'Hầu như không mây',
          Icons.wb_sunny_outlined,
          color: Color(0xFFFACC15),
          shortLabel: 'Ít mây',
        );
      case 2:
        return const WeatherCodeInfo(
          'Mây rải rác',
          Icons.cloud_queue_rounded,
          color: Color(0xFF38BDF8),
          shortLabel: 'Mây rải rác',
        );
      case 3:
        return const WeatherCodeInfo(
          'Trời nhiều mây',
          Icons.cloud_rounded,
          color: Color(0xFF94A3B8),
          shortLabel: 'Nhiều mây',
        );
      case 45:
      case 48:
        return const WeatherCodeInfo(
          'Có sương mù',
          Icons.blur_on_rounded,
          color: Color(0xFFCBD5E1),
          shortLabel: 'Sương mù',
        );
      case 51:
      case 53:
      case 55:
        return const WeatherCodeInfo(
          'Mưa phùn nhẹ',
          Icons.grain_rounded,
          color: Color(0xFF67E8F9),
          shortLabel: 'Mưa phùn',
          isRain: true,
        );
      case 61:
        return const WeatherCodeInfo(
          'Mưa nhỏ',
          Icons.water_drop_outlined,
          color: Color(0xFF38BDF8),
          shortLabel: 'Mưa nhỏ',
          isRain: true,
        );
      case 63:
        return const WeatherCodeInfo(
          'Mưa vừa',
          Icons.water_drop_rounded,
          color: Color(0xFF0284C7),
          shortLabel: 'Mưa vừa',
          isRain: true,
        );
      case 65:
        return const WeatherCodeInfo(
          'Mưa rào lớn',
          Icons.thunderstorm_rounded,
          color: Color(0xFF2563EB),
          shortLabel: 'Mưa to',
          isRain: true,
        );
      case 80:
      case 81:
      case 82:
        return const WeatherCodeInfo(
          'Mưa rào bất chợt',
          Icons.shower_rounded,
          color: Color(0xFF0EA5E9),
          shortLabel: 'Mưa rào',
          isRain: true,
        );
      case 95:
      case 96:
      case 99:
        return const WeatherCodeInfo(
          'Dông sét & Mưa bão',
          Icons.flash_on_rounded,
          color: Color(0xFFA855F7),
          shortLabel: 'Dông bão',
          isRain: true,
          isThunder: true,
        );
      default:
        return const WeatherCodeInfo(
          'Có mây',
          Icons.cloud_outlined,
          color: Color(0xFF94A3B8),
          shortLabel: 'Có mây',
        );
    }
  }
}
