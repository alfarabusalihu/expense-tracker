import 'package:intl/intl.dart';
import 'app_constants.dart';

/// Formatter for displaying minor currency units (ints) cleanly as currency strings.
class CurrencyFormatter {
  /// Formats amount in minor units (e.g. cents/cents equivalent, or LKR amount) to string.
  /// Assuming amount stored as integer (e.g. 1500 = 1,500.00 LKR or 1500 minor units).
  static String format(int minorUnits, {String currency = AppConstants.currencySymbol}) {
    final double mainUnits = minorUnits / 100.0;
    final formatter = NumberFormat.currency(
      symbol: '$currency ',
      decimalDigits: 2,
    );
    return formatter.format(mainUnits);
  }

  /// Convert user input double string (e.g. "150.50") to minor integer units (15050).
  static int toMinorUnits(double amount) {
    return (amount * 100).round();
  }

  /// Convert minor integer units (15050) back to double (150.50).
  static double toMainUnits(int minorUnits) {
    return minorUnits / 100.0;
  }
}
