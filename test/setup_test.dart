import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/app_settings_provider.dart';
import 'package:expense_tracker/screens/main_navigation_screen.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/utils/date_utils.dart';
import 'fake_expense_repository.dart';

void main() {
  group('Project Setup & Foundation Tests', () {
    testWidgets('App initializes and displays Dashboard screen', (WidgetTester tester) async {
      final provider = ExpenseProvider(repository: FakeExpenseRepository());
      await provider.fetchExpenses();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppSettingsProvider>(create: (_) => AppSettingsProvider()),
            ChangeNotifierProvider<ExpenseProvider>.value(value: provider),
          ],
          child: Consumer<AppSettingsProvider>(
            builder: (ctx, settings, _) => MaterialApp(
              themeMode: settings.themeMode,
              home: const MainNavigationScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Dashboard app bar title appears
      expect(find.text('Expense Tracker'), findsOneWidget);
      // Verify MonthlySummaryCard text appears
      expect(find.text('Total Expenses'), findsOneWidget);
    });

    test('CurrencyFormatter converts minor units correctly', () {
      final formatted = CurrencyFormatter.format(15050);
      expect(formatted, contains('150.50'));
      expect(formatted, contains('LKR'));

      expect(CurrencyFormatter.toMinorUnits(150.50), equals(15050));
      expect(CurrencyFormatter.toMainUnits(15050), equals(150.50));
    });

    test('AppDateUtils calculates month boundaries correctly', () {
      final testDate = DateTime(2026, 9, 27);
      final start = AppDateUtils.getStartOfMonth(testDate);
      final nextMonthStart = AppDateUtils.getStartOfNextMonth(testDate);

      expect(start, equals(DateTime(2026, 9, 1, 0, 0, 0)));
      expect(nextMonthStart, equals(DateTime(2026, 10, 1, 0, 0, 0)));
    });
  });
}
