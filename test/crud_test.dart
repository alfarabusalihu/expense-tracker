import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  group('Expense Data Model & CRUD Serialization Tests', () {
    final sampleDate = DateTime(2026, 9, 28, 14, 30);
    final sampleCreatedAt = DateTime(2026, 9, 28, 10, 0);
    final sampleUpdatedAt = DateTime(2026, 9, 28, 10, 0);

    test('Expense converts toMap correctly with Timestamps and trimmed text', () {
      final expense = Expense(
        id: 'test_exp_123',
        title: '  Groceries Supermarket  ',
        amount: 4500, // 45.00 LKR
        category: 'Food ',
        date: sampleDate,
        note: ' Weekly fruits & vegetables ',
        createdAt: sampleCreatedAt,
        updatedAt: sampleUpdatedAt,
      );

      final map = expense.toMap();

      expect(map['title'], equals('Groceries Supermarket'));
      expect(map['amount'], equals(4500));
      expect(map['category'], equals('food'));
      expect(map['note'], equals('Weekly fruits & vegetables'));
      expect(map['date'], isA<Timestamp>());
      expect((map['date'] as Timestamp).toDate(), equals(sampleDate));
    });

    test('Expense parses fromMap document map correctly', () {
      final documentMap = <String, dynamic>{
        'title': 'Electricity Bill',
        'amount': 8500,
        'category': 'bills',
        'date': Timestamp.fromDate(sampleDate),
        'note': 'Paid via app',
        'createdAt': Timestamp.fromDate(sampleCreatedAt),
        'updatedAt': Timestamp.fromDate(sampleUpdatedAt),
      };

      final expense = Expense.fromMap(documentMap, 'doc_abc99');

      expect(expense.id, equals('doc_abc99'));
      expect(expense.title, equals('Electricity Bill'));
      expect(expense.amount, equals(8500));
      expect(expense.category, equals('bills'));
      expect(expense.date, equals(sampleDate));
      expect(expense.note, equals('Paid via app'));
    });

    test('Expense copyWith updates selected fields immutably', () {
      final original = Expense(
        id: 'doc_1',
        title: 'Lunch',
        amount: 1200,
        category: 'food',
        date: sampleDate,
        createdAt: sampleCreatedAt,
        updatedAt: sampleUpdatedAt,
      );

      final updated = original.copyWith(
        amount: 1500,
        title: 'Team Lunch',
      );

      expect(updated.id, equals('doc_1'));
      expect(updated.title, equals('Team Lunch'));
      expect(updated.amount, equals(1500));
      expect(updated.category, equals('food')); // Preserved
      expect(updated.date, equals(sampleDate)); // Preserved
    });
  });
}
