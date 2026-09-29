import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:expense_tracker/widgets/expense_form.dart';

void main() {
  group('UI Component & Form Validation Tests', () {
    final testExpense = Expense(
      id: 'test_101',
      title: 'Coffee & Snacks',
      amount: 850, // 8.50 LKR
      category: 'food',
      date: DateTime(2026, 9, 28),
      note: 'Morning coffee',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('ExpenseCard renders expense title and formatted currency', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: testExpense),
          ),
        ),
      );

      expect(find.text('Coffee & Snacks'), findsOneWidget);
      expect(find.textContaining('8.50'), findsOneWidget);
      expect(find.text('Morning coffee'), findsOneWidget);
    });

    testWidgets('ExpenseForm validation rejects empty title and 0 amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseForm(
              onSubmit: ({required amountMinorUnits, required category, required date, note, required title}) async {},
            ),
          ),
        ),
      );

      // Scroll to button and tap Save without entering values
      await tester.ensureVisible(find.text('Save Expense'));
      await tester.tap(find.text('Save Expense'));
      await tester.pump();

      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Amount is required'), findsOneWidget);
    });

    testWidgets('ExpenseForm prepopulates values in edit mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseForm(
              initialExpense: testExpense,
              onSubmit: ({required amountMinorUnits, required category, required date, note, required title}) async {},
            ),
          ),
        ),
      );

      expect(find.text('Coffee & Snacks'), findsOneWidget);
      expect(find.text('8.50'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}
