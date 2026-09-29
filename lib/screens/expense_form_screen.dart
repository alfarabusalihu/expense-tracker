import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_form.dart';
import '../widgets/gradient_app_bar.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? initialExpense;

  const ExpenseFormScreen({super.key, this.initialExpense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  bool _isLoading = false;

  Future<void> _handleFormSubmit({
    required String title,
    required int amountMinorUnits,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<ExpenseProvider>();

    try {
      if (widget.initialExpense == null) {
        // Add Mode
        await provider.addExpense(
          title: title,
          amountMinorUnits: amountMinorUnits,
          category: category,
          date: date,
          note: note,
        );
      } else {
        // Edit Mode: Save changes to existing expense
        final updatedExpense = widget.initialExpense!.copyWith(
          title: title,
          amount: amountMinorUnits,
          category: category,
          date: date,
          note: note,
        );
        await provider.updateExpense(updatedExpense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialExpense == null
                ? 'Expense saved successfully!'
                : 'Expense updated successfully!'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmAndDelete(BuildContext context) {
    if (widget.initialExpense == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${widget.initialExpense!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              final provider = context.read<ExpenseProvider>();
              await provider.deleteExpense(widget.initialExpense!.id);

              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Expense deleted successfully!')),
              );
              navigator.pop(true); // Pop back to Home / Dashboard
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExpense != null;

    return Scaffold(
      appBar: GradientAppBar(
        title: isEditing ? 'Edit Expense' : 'Add Expense',
      ),
      body: ExpenseForm(
        initialExpense: widget.initialExpense,
        isLoading: _isLoading,
        onSubmit: _handleFormSubmit,
        onDelete: isEditing ? () => _confirmAndDelete(context) : null,
      ),
    );
  }
}
