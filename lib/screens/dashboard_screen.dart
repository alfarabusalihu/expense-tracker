import 'package:flutter/material.dart';
import '../providers/expense_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/monthly_summary.dart';
import '../widgets/expense_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/gradient_app_bar.dart';
import 'expense_form_screen.dart';
import 'settings_screen.dart';
import '../models/expense.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  void _openAddExpenseForm(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpenseFormScreen(),
      ),
    ).then((result) {
      if (!mounted) return;
      if (result == true) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Expense saved successfully!')),
        );
      }
    });
  }

  void _openEditExpenseForm(BuildContext context, Expense expense) {
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
    final filteredList = provider.filteredExpenses;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Expense Tracker',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingView(message: 'Loading expenses...')
          : provider.state == ProviderState.error
              ? ErrorView(
                  errorMessage: provider.errorMessage ?? 'Unknown error occurred',
                  onRetry: () => provider.fetchExpenses(),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonthlySummaryCard(
                        selectedMonth: provider.selectedMonth,
                        totalAmountMinorUnits: provider.monthlyTotalMinorUnits,
                        itemCount: filteredList.length,
                        onPreviousMonth: () {
                          final prev = DateTime(
                            provider.selectedMonth.year,
                            provider.selectedMonth.month - 1,
                            1,
                          );
                          provider.setSelectedMonth(prev);
                        },
                        onNextMonth: () {
                          final next = DateTime(
                            provider.selectedMonth.year,
                            provider.selectedMonth.month + 1,
                            1,
                          );
                          provider.setSelectedMonth(next);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Recent Expenses',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      if (filteredList.isEmpty)
                        EmptyView(
                          title: 'No expenses for this month',
                          message:
                              'Tap the + button to record a new expense.',
                          onActionPressed: () => _openAddExpenseForm(context),
                          actionLabel: 'Add Expense',
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (ctx, index) {
                            final expense = filteredList[index];
                            return ExpenseCard(
                              expense: expense,
                              onEdit: () => _openEditExpenseForm(context, expense),
                            );
                          },
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => _openAddExpenseForm(context),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
