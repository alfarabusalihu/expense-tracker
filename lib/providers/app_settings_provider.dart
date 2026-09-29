import 'package:flutter/material.dart';

/// Supported currencies in the app.
class CurrencyOption {
  final String code;
  final String symbol;
  final String label;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.label,
  });
}

/// Supported app languages.
class LanguageOption {
  final String code;
  final String label;
  final Locale locale;

  const LanguageOption({
    required this.code,
    required this.label,
    required this.locale,
  });
}

/// Global settings provider for theme, currency, and language.
class AppSettingsProvider extends ChangeNotifier {
  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }


  // Available Currencies
  static const List<CurrencyOption> availableCurrencies = [
    CurrencyOption(code: 'LKR', symbol: 'LKR', label: 'Sri Lankan Rupee (LKR)'),
    CurrencyOption(code: 'USD', symbol: '\$', label: 'US Dollar (USD)'),
    CurrencyOption(code: 'EUR', symbol: '€', label: 'Euro (EUR)'),
    CurrencyOption(code: 'GBP', symbol: '£', label: 'British Pound (GBP)'),
    CurrencyOption(code: 'INR', symbol: '₹', label: 'Indian Rupee (INR)'),
    CurrencyOption(code: 'JPY', symbol: '¥', label: 'Japanese Yen (JPY)'),
    CurrencyOption(code: 'AUD', symbol: 'A\$', label: 'Australian Dollar (AUD)'),
  ];

  CurrencyOption _selectedCurrency = availableCurrencies.first; // LKR default
  CurrencyOption get selectedCurrency => _selectedCurrency;

  void setCurrency(CurrencyOption currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  // Available Languages
  static const List<LanguageOption> availableLanguages = [
    LanguageOption(code: 'en', label: 'English', locale: Locale('en')),
    LanguageOption(code: 'si', label: 'සිංහල (Sinhala)', locale: Locale('si')),
    LanguageOption(code: 'ta', label: 'தமிழ் (Tamil)', locale: Locale('ta')),
    LanguageOption(code: 'de', label: 'Deutsch (German)', locale: Locale('de')),
    LanguageOption(code: 'fr', label: 'Français (French)', locale: Locale('fr')),
  ];

  LanguageOption _selectedLanguage = availableLanguages.first; // English default
  LanguageOption get selectedLanguage => _selectedLanguage;

  void setLanguage(LanguageOption language) {
    _selectedLanguage = language;
    notifyListeners();
  }
}
