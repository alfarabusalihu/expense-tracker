import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_utils.dart';
import '../theme/app_colors.dart';

/// Card widget displaying a single Expense with 3 horizontal partitions separated by dividers.
/// Tapping anywhere navigates directly to the Edit screen.
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onEdit;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onEdit,
  });

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

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      default:
        return Icons.more_horiz;
    }
  }

  Widget _buildVerticalDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(expense.category);
    final catIcon = _getCategoryIcon(expense.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedAmount = CurrencyFormatter.format(expense.amount);
    final formattedDate = AppDateUtils.formatDate(expense.date);

    return Semantics(
      label:
          '${expense.category} expense: ${expense.title}, $formattedAmount, $formattedDate. Tap to edit.',
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // PARTITION 1: Category Icon
                    Semantics(
                      label: '${expense.category} category',
                      excludeSemantics: true,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: catColor.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Icon(catIcon, color: catColor, size: 24),
                      ),
                    ),

                    _buildVerticalDivider(context),

                    // PARTITION 2: Title, Date, Amount & Notes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            expense.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: AppColors.textSecondaryLight,
                                semanticLabel: 'Date',
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formattedAmount,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                          if (expense.note != null &&
                              expense.note!.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sticky_note_2_outlined,
                                    size: 12,
                                    color: AppColors.primary,
                                    semanticLabel: 'Note',
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      expense.note!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 11,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    _buildVerticalDivider(context),

                    // PARTITION 3: Arrow Icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
