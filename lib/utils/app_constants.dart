/// Application constants and predefined categories as per design spec.
class AppConstants {
  static const String appName = 'Expense Tracker';
  static const String currencySymbol = 'LKR';

  /// Predefined expense categories
  static const List<Map<String, String>> categories = [
    {'id': 'food', 'label': 'Food & Dining', 'icon': 'restaurant'},
    {'id': 'transport', 'label': 'Transport', 'icon': 'directions_car'},
    {'id': 'shopping', 'label': 'Shopping', 'icon': 'shopping_bag'},
    {'id': 'bills', 'label': 'Bills & Utilities', 'icon': 'receipt_long'},
    {'id': 'entertainment', 'label': 'Entertainment', 'icon': 'movie'},
    {'id': 'healthcare', 'label': 'Healthcare', 'icon': 'local_hospital'},
    {'id': 'education', 'label': 'Education', 'icon': 'school'},
    {'id': 'other', 'label': 'Other', 'icon': 'more_horiz'},
  ];

  static const int maxTitleLength = 100;
  static const int maxNoteLength = 500;
}
