import 'package:intl/intl.dart';
import 'package:geofencingpoc/core/constants/app_constants.dart';

/// A utility class for date and time formatting operations.
class DateFormatter {
  /// Formats a date to the specified format.
  /// 
  /// If [date] is a String, it will be parsed to DateTime first.
  /// If [format] is not provided, it defaults to 'dd/MM/yyyy'.
  static String formatDate({
    required dynamic date,
    String format = AppConstants.dateFormat,
  }) {
    if (date == null) return "";
    
    DateTime dateTime;
    if (date is String) {
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        return "";
      }
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return "";
    }
    
    final DateFormat formatter = DateFormat(format);
    return formatter.format(dateTime);
  }
  
  /// Formats the current date and time using the specified format.
  static String formatNow({String format = AppConstants.dateTimeFormat}) {
    return formatDate(date: DateTime.now(), format: format);
  }
  
  /// Parses a string date to DateTime object.
  static DateTime? parseDate(String dateStr, {String format = AppConstants.dateFormat}) {
    try {
      final DateFormat formatter = DateFormat(format);
      return formatter.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
