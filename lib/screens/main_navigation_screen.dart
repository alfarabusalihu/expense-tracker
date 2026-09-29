import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'expense_history_screen.dart';
import 'reports_screen.dart';
import 'expense_form_screen.dart';
import '../theme/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ExpenseHistoryScreen(),
    ReportsScreen(),
  ];

  void _openAddExpenseForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpenseFormScreen(),
      ),
    );
  }

  Widget _buildFooterTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Semantics(
        label: label,
        selected: isSelected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              color: isSelected ? AppColors.secondary : Colors.transparent,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFooterTabItem(
              index: 0,
              icon: _currentIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
              label: 'Dashboard',
              isDark: isDark,
            ),
            _buildFooterTabItem(
              index: 1,
              icon: _currentIndex == 1 ? Icons.history : Icons.history_outlined,
              label: 'History',
              isDark: isDark,
            ),
            _buildFooterTabItem(
              index: 2,
              icon: _currentIndex == 2 ? Icons.analytics : Icons.analytics_outlined,
              label: 'Reports',
              isDark: isDark,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_nav_fab',
        onPressed: _openAddExpenseForm,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
