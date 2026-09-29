import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/expense_history_screen.dart';
import 'package:expense_tracker/models/expense.dart';
import 'fake_expense_repository.dart';

void main() {
  group('Expense History & Multi-Criteria Filter Tests', () {
    late ExpenseProvider provider;

    final now = DateTime.now();

    setUp(() async {
      final fakeRepo = FakeExpenseRepository(seedExpenses: [
        Expense(
          id: 'exp_1',
          title: 'Weekly Groceries',
          amount: 4500,
          category: 'food',
          date: DateTime(now.year, now.month, 10),
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

    test('Category filter isolates specific category items', () {
      provider.setSelectedCategory('food');
      final filtered = provider.filteredExpenses;
      expect(filtered.every((e) => e.category == 'food'), isTrue);
    });

    test('Clearing category filter restores all items', () {
      provider.setSelectedCategory('food');
      expect(provider.filteredExpenses.length, equals(1));

      provider.setSelectedCategory(null);
      expect(provider.filteredExpenses.length, equals(3));
    });

    testWidgets('ExpenseHistoryScreen renders filter bar and chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ExpenseProvider>.value(
          value: provider,
          child: const MaterialApp(home: ExpenseHistoryScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Expense History'), findsOneWidget);
      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
    });
  });
}
