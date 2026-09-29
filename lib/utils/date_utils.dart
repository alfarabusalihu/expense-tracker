import 'package:intl/intl.dart';

/// App date utility functions for month boundary calculation and formatting.
class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Get the start date of a given month (inclusive)
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1, 0, 0, 0, 0, 0);
  }

  /// Get the start date of the next month (exclusive upper bound for month queries)
  static DateTime getStartOfNextMonth(DateTime date) {
    if (date.month == 12) {
      return DateTime(date.year + 1, 1, 1, 0, 0, 0, 0, 0);
    }
    return DateTime(date.year, date.month + 1, 1, 0, 0, 0, 0, 0);
  }

  /// Check if date is in future compared to today (disallowed in scope)
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return date.isAfter(todayEnd);
  }
}
