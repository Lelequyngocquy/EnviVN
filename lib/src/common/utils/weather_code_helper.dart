import 'package:flutter/material.dart';

class WeatherCodeInfo {
  final String description;
  final IconData icon;
  final Color color;
  final String shortLabel;
  final bool isRain;
  final bool isThunder;
  final bool isNight;

  const WeatherCodeInfo(
    this.description,
    this.icon, {
    this.color = const Color(0xFF38BDF8),
    this.shortLabel = 'Thời tiết',
    this.isRain = false,
    this.isThunder = false,
    this.isNight = false,
  });
}

class WeatherCodeHelper {
  WeatherCodeHelper._();

  /// Xác định thời điểm có phải ban ngày không (06:00 sáng đến trước 18:00 tối).
  /// Chiều tối đến gần sáng (18:00 - 05:59) là ban đêm, trả về false.
  static bool isDaytime([DateTime? time]) {
    final t = time ?? DateTime.now();
    return t.hour >= 6 && t.hour < 18;
  }

  /// Lấy thông tin thời tiết kèm biểu tượng thực tế theo thời gian (Ngày/Đêm).
  /// Nếu là chiều tối đến gần sáng (18:00 - 05:59), biểu tượng mặt trời sẽ tự động
  /// được chuyển thành biểu tượng trăng đêm (nightlight/nights_stay) để đảm bảo tính thực tế.
  static WeatherCodeInfo getInfo(int? code, {DateTime? time, bool? isDay}) {
    if (code == null) {
      return const WeatherCodeInfo('Không rõ', Icons.cloud_outlined);
    }

    final bool isDayTime = isDay ?? isDaytime(time);

    switch (code) {
      case 0:
        // Clear sky (Trời quang đãng)
        return isDayTime
            ? const WeatherCodeInfo(
                'Trời quang đãng',
                Icons.wb_sunny_rounded,
                color: Color(0xFFFBBF24),
                shortLabel: 'Quang đãng',
              )
            : const WeatherCodeInfo(
                'Đêm quang đãng',
                Icons.nightlight_round,
                color: Color(0xFF93C5FD),
                shortLabel: 'Quang đãng',
                isNight: true,
              );

      case 1:
        // Mainly clear (Hầu như không mây / Ít mây)
        return isDayTime
            ? const WeatherCodeInfo(
                'Hầu như không mây',
                Icons.wb_sunny_outlined,
                color: Color(0xFFFACC15),
                shortLabel: 'Ít mây',
              )
            : const WeatherCodeInfo(
                'Đêm ít mây',
                Icons.nights_stay_rounded,
                color: Color(0xFFBAE6FD),
                shortLabel: 'Ít mây',
                isNight: true,
              );

      case 2:
        // Partly cloudy (Mây rải rác)
        return isDayTime
            ? const WeatherCodeInfo(
                'Mây rải rác',
                Icons.cloud_queue_rounded,
                color: Color(0xFF38BDF8),
                shortLabel: 'Mây rải rác',
              )
            : const WeatherCodeInfo(
                'Đêm mây rải rác',
                Icons.nights_stay_outlined,
                color: Color(0xFF94A3B8),
                shortLabel: 'Mây rải rác',
                isNight: true,
              );

      case 3:
        // Overcast (Trời nhiều mây)
        return const WeatherCodeInfo(
          'Trời nhiều mây',
          Icons.cloud_rounded,
          color: Color(0xFF94A3B8),
          shortLabel: 'Nhiều mây',
        );

      case 45:
      case 48:
        // Fog (Có sương mù)
        return const WeatherCodeInfo(
          'Có sương mù',
          Icons.blur_on_rounded,
          color: Color(0xFFCBD5E1),
          shortLabel: 'Sương mù',
        );

      case 51:
      case 53:
      case 55:
        // Drizzle (Mưa phùn)
        return const WeatherCodeInfo(
          'Mưa phùn nhẹ',
          Icons.grain_rounded,
          color: Color(0xFF67E8F9),
          shortLabel: 'Mưa phùn',
          isRain: true,
        );

      case 61:
        // Slight rain (Mưa nhỏ)
        return const WeatherCodeInfo(
          'Mưa nhỏ',
          Icons.water_drop_outlined,
          color: Color(0xFF38BDF8),
          shortLabel: 'Mưa nhỏ',
          isRain: true,
        );

      case 63:
        // Moderate rain (Mưa vừa)
        return const WeatherCodeInfo(
          'Mưa vừa',
          Icons.water_drop_rounded,
          color: Color(0xFF0284C7),
          shortLabel: 'Mưa vừa',
          isRain: true,
        );

      case 65:
        // Heavy rain (Mưa to)
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
        // Rain showers (Mưa rào)
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
        // Thunderstorm (Dông sét & Mưa bão)
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
