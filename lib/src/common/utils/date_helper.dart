import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  /// Formats date to Vietnamese string safely without throwing LocaleDataException
  static String formatVietnamese(DateTime date, {String pattern = 'EEEE, dd \'tháng\' MM'}) {
    try {
      return DateFormat(pattern, 'vi').format(date);
    } catch (_) {
      try {
        return DateFormat(pattern, 'vi_VN').format(date);
      } catch (_) {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    }
  }

  /// Formats date to full Vietnamese weekday and date string
  static String formatVietnameseFull(DateTime date) {
    try {
      return DateFormat('EEEE, dd/MM/yyyy', 'vi').format(date);
    } catch (_) {
      try {
        return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
      } catch (_) {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    }
  }

  /// Formats time HH:mm safely
  static String formatTime(DateTime date) {
    try {
      return DateFormat('HH:mm').format(date);
    } catch (_) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
