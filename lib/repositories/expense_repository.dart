import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

/// Repository handling Cloud Firestore database operations for Expenses.
class ExpenseRepository {
  final FirebaseFirestore? _customFirestore;

  ExpenseRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  /// Helper reference to user's expense sub-collection: users/{userId}/expenses
  CollectionReference<Map<String, dynamic>> _userExpensesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('expenses');
  }

  /// Create a new expense record in Firestore
  Future<String> addExpense({
    required String userId,
    required Expense expense,
  }) async {
    try {
      final docRef = await _userExpensesRef(userId).add(expense.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  /// Stream real-time expenses for a user sorted by date descending
  Stream<List<Expense>> streamExpenses({required String userId}) {
    return _userExpensesRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Fetch expenses once for a given date range (start inclusive, end exclusive)
  Future<List<Expense>> getExpensesForRange({
    required String userId,
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    try {
      final snapshot = await _userExpensesRef(userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startInclusive))
          .where('date', isLessThan: Timestamp.fromDate(endExclusive))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  /// Update an existing expense record by ID
  Future<void> updateExpense({
    required String userId,
    required Expense expense,
  }) async {
    try {
      final updatedData = expense.toMap();
      updatedData['updatedAt'] = FieldValue.serverTimestamp();

      await _userExpensesRef(userId).doc(expense.id).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete an expense record by ID
  Future<void> deleteExpense({
    required String userId,
    required String expenseId,
  }) async {
    try {
      await _userExpensesRef(userId).doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
