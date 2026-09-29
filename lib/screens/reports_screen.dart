import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_view.dart';
import '../widgets/gradient_app_bar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Color _getCategoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'food':
        return AppColors.categoryFood;
      case 'transport':
        return AppColors.categoryTransport;
      case 'shopping':
        return AppColors.categoryShopping;
      case 'bills':
        return AppColors.categoryBills;
      case 'entertainment':
        return AppColors.categoryEntertainment;
      case 'healthcare':
        return AppColors.categoryHealthcare;
      case 'education':
        return AppColors.categoryEducation;
      default:
        return AppColors.categoryOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.filteredExpenses;
    final totalMinor = provider.monthlyTotalMinorUnits;

    final Map<String, int> categoryTotals = {};
    for (final exp in expenses) {
      final cat = exp.category.toLowerCase();
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + exp.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Reports & Analytics',
      ),
      body: expenses.isEmpty
          ? const EmptyView(
              title: 'No Data for Reports',
              message: 'Add expenses in this month to see category breakdown analytics.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.pie_chart, size: 40, color: AppColors.primary),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Spending Breakdown',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(totalMinor),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Category Wise Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedCategories.length,
                    itemBuilder: (ctx, index) {
                      final entry = sortedCategories[index];
                      final catId = entry.key;
                      final catAmount = entry.value;
                      final percentage = totalMinor > 0 ? (catAmount / totalMinor) : 0.0;
                      final color = _getCategoryColor(catId);

                      final categoryMeta = AppConstants.categories.firstWhere(
                        (c) => c['id'] == catId,
                        orElse: () => {'label': catId.toUpperCase()},
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  categoryMeta['label']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${CurrencyFormatter.format(catAmount)} (${(percentage * 100).toStringAsFixed(1)}%)',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentage,
                                minHeight: 10,
                                backgroundColor: color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
