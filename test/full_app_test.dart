import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/app_settings_provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/main_navigation_screen.dart';
import 'package:expense_tracker/screens/reports_screen.dart';
import 'fake_expense_repository.dart';

void main() {
  group('Full Application Integration & Reports Analytics Tests', () {
    late ExpenseProvider provider;

    setUp(() async {
      final now = DateTime.now();
      // Seed current-month expenses so ReportsScreen renders breakdown (not EmptyView)
      provider = ExpenseProvider(
        repository: FakeExpenseRepository(seedExpenses: [
          Expense(
            id: 'r1',
            title: 'Groceries',
            amount: 4500,
            category: 'food',
            date: DateTime(now.year, now.month, 5),
            createdAt: now,
            updatedAt: now,
          ),
          Expense(
            id: 'r2',
            title: 'Bus Pass',
            amount: 1200,
            category: 'transport',
            date: DateTime(now.year, now.month, 10),
            createdAt: now,
            updatedAt: now,
          ),
        ]),
      );
      await provider.fetchExpenses();
    });

    Widget buildApp(Widget home) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsProvider>(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider<ExpenseProvider>.value(value: provider),
        ],
        child: MaterialApp(home: home),
      );
    }

    testWidgets('ReportsScreen displays category percentage breakdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const ReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Reports & Analytics'), findsOneWidget);
      expect(find.text('Monthly Spending Breakdown'), findsOneWidget);
      expect(find.text('Category Wise Breakdown'), findsOneWidget);
    });

    testWidgets('MainNavigationScreen switches tabs between Dashboard, History, and Reports',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const MainNavigationScreen()));
      await tester.pumpAndSettle();

      // Verify Dashboard tab active
      expect(find.text('Total Expenses'), findsOneWidget);

      // Tap History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Expense History'), findsOneWidget);

      // Tap Reports tab
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();
      expect(find.text('Reports & Analytics'), findsOneWidget);
    });
  });
}
