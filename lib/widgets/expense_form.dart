import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_utils.dart';
import '../theme/app_colors.dart';
import 'category_selector.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? initialExpense;
  final bool isLoading;
  final Future<void> Function({
    required String title,
    required int amountMinorUnits,
    required String category,
    required DateTime date,
    String? note,
  }) onSubmit;
  final VoidCallback? onDelete;

  const ExpenseForm({
    super.key,
    this.initialExpense,
    this.isLoading = false,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? CurrencyFormatter.toMainUnits(expense.amount).toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: expense?.note ?? '');
    _selectedCategory = expense?.category ?? 'food';
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(now) ? now : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double amountDouble = double.parse(_amountController.text.trim());
      final int amountMinorUnits = CurrencyFormatter.toMinorUnits(amountDouble);

      widget.onSubmit(
        title: _titleController.text.trim(),
        amountMinorUnits: amountMinorUnits,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExpense != null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. Groceries, Dinner, Taxi',
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: AppConstants.maxTitleLength,
              onChanged: (value) {
                // Auto-capitalize first letter (camelCase / sentence case)
                if (value.isNotEmpty) {
                  final capitalized =
                      value[0].toUpperCase() + value.substring(1);
                  if (capitalized != value) {
                    _titleController.value = _titleController.value.copyWith(
                      text: capitalized,
                      selection: TextSelection.collapsed(
                          offset: capitalized.length),
                    );
                  }
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length > AppConstants.maxTitleLength) {
                  return 'Title cannot exceed ${AppConstants.maxTitleLength} characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount Input
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (LKR) *',
                hintText: 'e.g. 1500.00',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'LKR',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Category Selection
            Text(
              'Category *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) {
                if (cat != null) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
              isHorizontal: true,
            ),
            const SizedBox(height: 20),

            // Date Picker Row
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date *'),
              subtitle: Text(AppDateUtils.formatDate(_selectedDate)),
              trailing: TextButton(
                onPressed: widget.isLoading ? null : _pickDate,
                child: const Text('Select Date'),
              ),
            ),
            const SizedBox(height: 16),

            // Optional Note Input
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'Additional details or memo...',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              maxLength: AppConstants.maxNoteLength,
              validator: (value) {
                if (value != null && value.length > AppConstants.maxNoteLength) {
                  return 'Note cannot exceed ${AppConstants.maxNoteLength} characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Action Buttons: Save & Delete with identical radius, height, and background style
            if (isEditing) ...[
              Row(
                children: [
                  if (widget.onDelete != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.isLoading ? null : widget.onDelete,
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (widget.onDelete != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.isLoading ? null : _submit,
                      icon: widget.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check, color: Colors.white),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: widget.isLoading ? null : _submit,
                icon: widget.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, color: Colors.white),
                label: const Text('Save Expense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
