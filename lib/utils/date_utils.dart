import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  static String formatdate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static DateTime getLocalTime() {
    return DateTime.now();
  }

  static DateTime getUtcTime() {
    return DateTime.now().toUtc();
  }

  static DateTime convertToUtc(DateTime localTime) {
    return localTime.toUtc();
  }

  static DateTime convertToLocalTime(DateTime utcTime) {
    return utcTime.toLocal();
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
