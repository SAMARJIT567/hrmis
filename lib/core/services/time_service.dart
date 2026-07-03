// ============================================================
// 📁 lib/core/services/time_service.dart
// ============================================================
// Service for handling time-related operations
// ============================================================

import 'package:intl/intl.dart';

class TimeService {
  static const String _defaultFormat = 'hh:mm a';
  static const String _dateFormat = 'dd MMM yyyy';
  static const String _dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // ─── Get Current Time ──────────────────────────────────────
  static String getCurrentTime({String format = _defaultFormat}) {
    return DateFormat(format).format(DateTime.now());
  }

  // ─── Get Current Date ──────────────────────────────────────
  static String getCurrentDate({String format = _dateFormat}) {
    return DateFormat(format).format(DateTime.now());
  }

  // ─── Get Current DateTime ──────────────────────────────────
  static String getCurrentDateTime({String format = _dateTimeFormat}) {
    return DateFormat(format).format(DateTime.now());
  }

  // ─── Format Time ──────────────────────────────────────────
  static String formatTime(DateTime time, {String format = _defaultFormat}) {
    return DateFormat(format).format(time);
  }

  // ─── Format Date ──────────────────────────────────────────
  static String formatDate(DateTime date, {String format = _dateFormat}) {
    return DateFormat(format).format(date);
  }

  // ─── Format DateTime ──────────────────────────────────────
  static String formatDateTime(DateTime dateTime, {String format = _dateTimeFormat}) {
    return DateFormat(format).format(dateTime);
  }

  // ─── Parse Time ────────────────────────────────────────────
  static DateTime parseTime(String timeStr, {String format = _defaultFormat}) {
    return DateFormat(format).parse(timeStr);
  }

  // ─── Parse Date ────────────────────────────────────────────
  static DateTime parseDate(String dateStr, {String format = _dateFormat}) {
    return DateFormat(format).parse(dateStr);
  }

  // ─── Check if Time is Between ─────────────────────────────
  static bool isTimeBetween(DateTime time, DateTime start, DateTime end) {
    return time.isAfter(start) && time.isBefore(end);
  }

  // ─── Get Time Difference ──────────────────────────────────
  static String getTimeDifference(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '$hours h ${minutes}m';
  }

  // ─── Check if is Late ──────────────────────────────────────
  static bool isLate(DateTime checkInTime, {int expectedHour = 10}) {
    final expectedTime = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      expectedHour,
      0,
    );
    return checkInTime.isAfter(expectedTime);
  }

  // ─── Get Late Duration ─────────────────────────────────────
  static String getLateDuration(DateTime checkInTime, {int expectedHour = 10}) {
    final expectedTime = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      expectedHour,
      0,
    );
    if (checkInTime.isAfter(expectedTime)) {
      final diff = checkInTime.difference(expectedTime);
      final minutes = diff.inMinutes;
      if (minutes < 60) return '$minutes minutes';
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours hour${hours > 1 ? 's' : ''} ${mins > 0 ? '$mins minutes' : ''}';
    }
    return '';
  }

  // ─── Get Working Hours ─────────────────────────────────────
  static String getWorkingHours(DateTime checkIn, DateTime checkOut) {
    final diff = checkOut.difference(checkIn);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '$hours h ${minutes}m';
  }
}