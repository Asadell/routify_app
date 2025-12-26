import 'package:intl/intl.dart';

class DateHelper {
  static String formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime? parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime? parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  static int getDayOfWeek(DateTime date) {
    // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    return date.weekday % 7;
  }

  static DateTime getStartOfWeek(DateTime date) {
    final dayOfWeek = date.weekday % 7;
    return date.subtract(Duration(days: dayOfWeek));
  }

  static DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return startOfWeek.add(const Duration(days: 6));
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}