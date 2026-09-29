import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/date_filter_bar.dart';
import '../widgets/empty_view.dart';
import '../widgets/gradient_app_bar.dart';
import '../models/expense.dart';
import 'expense_form_screen.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  DateQuickFilter _dateFilter = DateQuickFilter.allTime;

  List<Expense> _applyDateQuickFilter(List<Expense> input) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (_dateFilter) {
      case DateQuickFilter.today:
        return input
            .where((e) => e.date
                .isAfter(todayStart.subtract(const Duration(milliseconds: 1))))
            .toList();
      case DateQuickFilter.yesterday:
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));
        return input
            .where((e) =>
                e.date.isAfter(yesterdayStart.subtract(const Duration(milliseconds: 1))) &&
                e.date.isBefore(todayStart))
            .toList();
      case DateQuickFilter.thisWeek:
        final weekStart =
            todayStart.subtract(Duration(days: now.weekday - 1));
        return input
            .where((e) => e.date
                .isAfter(weekStart.subtract(const Duration(milliseconds: 1))))
            .toList();
      case DateQuickFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return input
            .where((e) => e.date
                .isAfter(monthStart.subtract(const Duration(milliseconds: 1))))
            .toList();
      case DateQuickFilter.lastMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        return input
            .where((e) =>
                e.date.isAfter(lastMonthStart.subtract(const Duration(milliseconds: 1))) &&
                e.date.isBefore(monthStart))
            .toList();
      case DateQuickFilter.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        return input
            .where((e) => e.date
                .isAfter(yearStart.subtract(const Duration(milliseconds: 1))))
            .toList();
      case DateQuickFilter.allTime:
        return input;
    }
  }

  void _clearAllFilters(ExpenseProvider provider) {
    setState(() {
      _dateFilter = DateQuickFilter.allTime;
    });
    provider.setSelectedCategory(null);
  }

  void _openEditForm(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(initialExpense: expense),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categoryFiltered = provider.selectedCategory == null
        ? provider.allExpenses
        : provider.allExpenses
            .where((e) =>
                e.category.toLowerCase() ==
                provider.selectedCategory!.toLowerCase())
            .toList();

    final finalFilteredList =
        List<Expense>.from(_applyDateQuickFilter(categoryFiltered));
    finalFilteredList.sort((a, b) => b.date.compareTo(a.date));

    final hasActiveFilters =
        provider.selectedCategory != null ||
        _dateFilter != DateQuickFilter.allTime;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Expense History',
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off, color: Colors.white),
              tooltip: 'Clear Filters',
              onPressed: () => _clearAllFilters(provider),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar Section
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12.0, vertical: 10.0),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Pills (Smooth Horizontal Scroll with Arrows + Mouse Wheel)
                CategorySelector(
                  selectedCategory: provider.selectedCategory ?? '',
                  onCategorySelected: (cat) => provider.setSelectedCategory(cat),
                  showAllOption: true,
                  isHorizontal: true,
                ),
                const SizedBox(height: 8),
                // Date Quick Filter Pills (Smooth Horizontal Scroll with Arrows + Mouse Wheel)
                DateFilterBar(
                  selectedFilter: _dateFilter,
                  onFilterSelected: (filter) => setState(() => _dateFilter = filter),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Expenses List
          Expanded(
            child: finalFilteredList.isEmpty
                ? EmptyView(
                    title: 'No Matching Expenses',
                    message: hasActiveFilters
                        ? 'No records match your selected filters.'
                        : 'No expense records found.',
                    actionLabel: hasActiveFilters ? 'Clear Filters' : null,
                    onActionPressed:
                        hasActiveFilters ? () => _clearAllFilters(provider) : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: finalFilteredList.length,
                    itemBuilder: (ctx, index) {
                      final expense = finalFilteredList[index];
                      return ExpenseCard(
                        expense: expense,
                        onEdit: () => _openEditForm(context, expense),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
