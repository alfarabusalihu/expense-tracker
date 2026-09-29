// Expense Tracker - App-level smoke test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/app_settings_provider.dart';
import 'package:expense_tracker/screens/main_navigation_screen.dart';
import 'fake_expense_repository.dart';

void main() {
  testWidgets('App smoke test - MainNavigationScreen renders footer tabs', (WidgetTester tester) async {
    final provider = ExpenseProvider(repository: FakeExpenseRepository());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsProvider>(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider<ExpenseProvider>.value(value: provider),
        ],
        child: const MaterialApp(home: MainNavigationScreen()),
      ),
    );

    await tester.pump();

    // Bottom navigation tabs should be present
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}
