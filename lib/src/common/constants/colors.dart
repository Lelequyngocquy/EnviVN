import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UIColors {
  UIColors._();

  // Dark Theme Palette matching the SVGs & Apple iOS design
  static const Color bg = Color(0xFF0B1220); // Dark Navy Background
  static const Color cardBg = Color(0xFF141D33); // Card Dark Navy
  static const Color cardGlass = Color(0x1AFFFFFF); // Translucent Glass
  static const Color cardGlassBorder = Color(0x33FFFFFF); // Glass Border
  static const Color surfaceVariant = Color(0xFF1E2A44); // Chip / Track Border
  static const Color border = Color(0xFF1E2A44);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8B93A7);
  static const Color textMuted = Color(0xFF5B6478);
  static const Color textLight = Color(0xFF8B93A7);

  // Status & AQI Colors from Design
  static const Color aqiGood = Color(0xFF4ADE80); // 0 - 50: Tốt (Mint/Emerald)
  static const Color aqiModerate = Color(0xFFFACC15); // 51 - 100: Trung bình (Amber/Yellow)
  static const Color aqiUnhealthySensitive = Color(0xFFFB923C); // 101 - 150: Nhạy cảm (Orange)
  static const Color aqiUnhealthy = Color(0xFFF87171); // 151 - 200: Xấu (Coral Red)
  static const Color aqiVeryUnhealthy = Color(0xFFA855F7); // 201 - 300: Rất xấu (Purple)
  static const Color aqiHazardous = Color(0xFFDC2626); // 301+: Nguy hại (Deep Red)

  // Functional Accents
  static const Color primary = Color(0xFF4ADE80);
  static const Color primaryLight = Color(0xFF86EFAC);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color secondary = Color(0xFF38BDF8); // Sky Blue
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);

  static void setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B1220),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }
}
