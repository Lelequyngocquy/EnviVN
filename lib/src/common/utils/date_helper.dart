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

  /// Formats weekday safely in Vietnamese (Hôm nay, Ngày mai, Thứ Hai, etc.)
  static String formatWeekday(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hôm nay';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Ngày mai';
    }
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '${date.day}/${date.month}';
    }
  }
}
