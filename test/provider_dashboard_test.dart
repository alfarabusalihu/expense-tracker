import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/models/expense.dart';
import 'fake_expense_repository.dart';

void main() {
  group('State Management & Dashboard Calculations Tests', () {
    late ExpenseProvider provider;
    late FakeExpenseRepository fakeRepo;

    final now = DateTime.now();

    setUp(() async {
      fakeRepo = FakeExpenseRepository(seedExpenses: [
        Expense(
          id: 'exp_1',
          title: 'Weekly Groceries',
          amount: 4500,
          category: 'food',
          date: DateTime(now.year, now.month, 10),
          note: 'Fruits, milk, bread',
          createdAt: now,
          updatedAt: now,
        ),
        Expense(
          id: 'exp_2',
          title: 'Bus & Transport Card',
          amount: 1200,
          category: 'transport',
          date: DateTime(now.year, now.month, 15),
          createdAt: now,
          updatedAt: now,
        ),
        Expense(
          id: 'exp_3',
          title: 'Internet & Water Bill',
          amount: 3500,
          category: 'bills',
          date: DateTime(now.year, now.month, 18),
          createdAt: now,
          updatedAt: now,
        ),
      ]);
      provider = ExpenseProvider(repository: fakeRepo);
      await provider.fetchExpenses();
    });

    test('Provider calculates monthly total math accurately', () {
      expect(provider.allExpenses.length, equals(3));
      // 4500 + 1200 + 3500 = 9200 minor units (92.00 LKR)
      expect(provider.monthlyTotalMinorUnits, equals(9200));
      expect(provider.filteredExpenses.length, equals(3));
    });

    test('Adding an expense updates provider state and monthly total math', () async {
      final success = await provider.addExpense(
        title: 'New Dinner',
        amountMinorUnits: 1800,
        category: 'food',
        date: now,
      );

      expect(success, isTrue);
      expect(provider.allExpenses.length, equals(4));
      expect(provider.monthlyTotalMinorUnits, equals(9200 + 1800)); // 11000
    });

    test('Deleting an expense updates provider state and recalculates total', () async {
      final success = await provider.deleteExpense('exp_1'); // 4500 minor units

      expect(success, isTrue);
      expect(provider.allExpenses.length, equals(2));
      expect(provider.monthlyTotalMinorUnits, equals(9200 - 4500)); // 4700
    });

    testWidgets('DashboardScreen renders provider monthly summary and recent list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: provider),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Expense Tracker'), findsOneWidget);
      expect(find.text('Total Expenses'), findsOneWidget);
      expect(find.text('Weekly Groceries'), findsOneWidget);
    });
  });
}
