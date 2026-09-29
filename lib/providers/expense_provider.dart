import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../utils/date_utils.dart';

enum ProviderState { initial, loading, loaded, error }

/// Main presentation state manager for Expense Tracker using Provider / ChangeNotifier.
/// All CRUD operations persist to Cloud Firestore via [ExpenseRepository].
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;
  final String _userId;

  ProviderState _state = ProviderState.initial;
  List<Expense> _expenses = [];
  String? _errorMessage;

  DateTime _selectedMonth = DateTime.now();
  String? _selectedCategory; // null means 'All'

  ExpenseProvider({
    required ExpenseRepository repository,
    String userId = 'demo_user_1',
  })  : _repository = repository,
        _userId = userId;

  // ─── Getters ─────────────────────────────────────────────────────────────
  ProviderState get state => _state;
  bool get isLoading => _state == ProviderState.loading;
  String? get errorMessage => _errorMessage;
  List<Expense> get allExpenses => List.unmodifiable(_expenses);
  DateTime get selectedMonth => _selectedMonth;
  String? get selectedCategory => _selectedCategory;

  /// Expenses filtered by current selectedMonth boundary and selectedCategory
  List<Expense> get filteredExpenses {
    final monthStart = AppDateUtils.getStartOfMonth(_selectedMonth);
    final monthEndExclusive = AppDateUtils.getStartOfNextMonth(_selectedMonth);

    return _expenses.where((expense) {
      final matchesMonth =
          expense.date.isAfter(monthStart.subtract(const Duration(milliseconds: 1))) &&
              expense.date.isBefore(monthEndExclusive);

      final matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          expense.category.toLowerCase() == _selectedCategory!.toLowerCase();

      return matchesMonth && matchesCategory;
    }).toList();
  }

  /// Total amount in minor units for the currently selected month and filter
  int get monthlyTotalMinorUnits {
    return filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  /// Change selected month and reload from Firestore
  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
    fetchExpenses(); // Reload data for the new month
  }

  /// Change selected category filter (null for all)
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ─── Firestore Fetch ──────────────────────────────────────────────────────

  /// Fetch all expenses for the current user from Firestore (all-time, used in History).
  /// If no data is found, auto-seeds initial data from assets/seed.json.
  Future<void> fetchExpenses() async {
    _state = ProviderState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final expenses = await _repository.getExpensesForRange(
        userId: _userId,
        startInclusive: DateTime(2020, 1, 1),
        endExclusive: DateTime.now().add(const Duration(days: 365)),
      );
      _expenses = expenses;

      if (_expenses.isEmpty) {
        final seedData = await _loadSeedExpenses();
        if (seedData.isNotEmpty) {
          _expenses = seedData;
          for (final expense in seedData) {
            _repository.addExpense(userId: _userId, expense: expense).catchError((_) => '');
          }
        }
      }

      _state = ProviderState.loaded;
    } catch (e) {
      _state = ProviderState.error;
      _errorMessage = 'Unable to load expenses: ${e.toString()}';
      debugPrint('ExpenseProvider.fetchExpenses error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<List<Expense>> _loadSeedExpenses() async {
    try {
      final jsonString = await rootBundle.loadString('assets/seed.json');
      final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
      final now = DateTime.now();

      return list.map((item) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        DateTime date;
        try {
          final parsed = DateTime.parse(map['date'] as String);
          date = DateTime(now.year, now.month, parsed.day, parsed.hour, parsed.minute);
        } catch (_) {
          date = now;
        }

        return Expense(
          id: map['id'] as String? ?? 'seed_${DateTime.now().millisecondsSinceEpoch}',
          title: map['title'] as String? ?? 'Expense',
          amount: (map['amount'] as num?)?.toInt() ?? 0,
          category: map['category'] as String? ?? 'other',
          date: date,
          note: map['note'] as String?,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();
    } catch (e) {
      debugPrint('ExpenseProvider._loadSeedExpenses note: $e');
      return [];
    }
  }

  // ─── Add ─────────────────────────────────────────────────────────────────

  /// Save a new expense to Firestore, then reflect in local list immediately.
  Future<bool> addExpense({
    required String title,
    required int amountMinorUnits,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    try {
      final now = DateTime.now();
      final tempExpense = Expense(
        id: '', // Will be replaced by Firestore-generated ID
        title: title,
        amount: amountMinorUnits,
        category: category,
        date: date,
        note: note,
        createdAt: now,
        updatedAt: now,
      );

      // Persist to Firestore and get the real document ID back
      final docId = await _repository.addExpense(
        userId: _userId,
        expense: tempExpense,
      );

      // Add to local list with the real Firestore ID
      final savedExpense = tempExpense.copyWith(id: docId);
      _expenses.insert(0, savedExpense);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save expense: $e';
      debugPrint('ExpenseProvider.addExpense error: $e');
      notifyListeners();
      return false;
    }
  }

  // ─── Update ──────────────────────────────────────────────────────────────

  /// Update an existing expense in Firestore, then update local list.
  Future<bool> updateExpense(Expense updatedExpense) async {
    try {
      final expenseWithTimestamp = updatedExpense.copyWith(updatedAt: DateTime.now());

      // Persist update to Firestore
      await _repository.updateExpense(
        userId: _userId,
        expense: expenseWithTimestamp,
      );

      // Update local list
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = expenseWithTimestamp;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update expense: $e';
      debugPrint('ExpenseProvider.updateExpense error: $e');
      notifyListeners();
      return false;
    }
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  /// Delete an expense from Firestore, then remove from local list.
  Future<bool> deleteExpense(String id) async {
    try {
      // Persist deletion to Firestore
      await _repository.deleteExpense(userId: _userId, expenseId: id);

      // Remove from local list
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense: $e';
      debugPrint('ExpenseProvider.deleteExpense error: $e');
      notifyListeners();
      return false;
    }
  }
}
