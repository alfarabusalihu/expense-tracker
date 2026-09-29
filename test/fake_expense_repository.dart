import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/repositories/expense_repository.dart';

/// In-memory fake repository used in unit/widget tests.
/// Avoids real Firestore network calls — fully hermetic.
class FakeExpenseRepository extends ExpenseRepository {
  final List<Expense> _store;

  FakeExpenseRepository({List<Expense> seedExpenses = const []})
      : _store = List<Expense>.from(seedExpenses);

  @override
  Future<String> addExpense({
    required String userId,
    required Expense expense,
  }) async {
    final id = 'fake_${DateTime.now().millisecondsSinceEpoch}';
    _store.insert(0, expense.copyWith(id: id));
    return id;
  }

  @override
  Future<List<Expense>> getExpensesForRange({
    required String userId,
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    return _store.where((e) {
      return !e.date.isBefore(startInclusive) && e.date.isBefore(endExclusive);
    }).toList();
  }

  @override
  Future<void> updateExpense({
    required String userId,
    required Expense expense,
  }) async {
    final idx = _store.indexWhere((e) => e.id == expense.id);
    if (idx != -1) _store[idx] = expense;
  }

  @override
  Future<void> deleteExpense({
    required String userId,
    required String expenseId,
  }) async {
    _store.removeWhere((e) => e.id == expenseId);
  }

  @override
  Stream<List<Expense>> streamExpenses({required String userId}) {
    return Stream.value(List<Expense>.from(_store));
  }
}
