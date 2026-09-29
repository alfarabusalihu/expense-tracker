import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_utils.dart';
import '../theme/app_colors.dart';

/// Monthly summary hero card displaying selected month total and controls.
class MonthlySummaryCard extends StatelessWidget {
  final DateTime selectedMonth;
  final int totalAmountMinorUnits;
  final int itemCount;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthlySummaryCard({
    super.key,
    required this.selectedMonth,
    required this.totalAmountMinorUnits,
    required this.itemCount,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: onPreviousMonth,
                tooltip: 'Previous Month',
              ),
              Text(
                AppDateUtils.formatMonthYear(selectedMonth),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: onNextMonth,
                tooltip: 'Next Month',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Total amount display
          const Text(
            'Total Expenses',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(totalAmountMinorUnits),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Record count indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$itemCount ${itemCount == 1 ? "expense" : "expenses"}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
