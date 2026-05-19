import 'package:finance_tracker/core/constants/app_categories.dart';
import 'package:finance_tracker/core/constants/app_routes.dart';
import 'package:finance_tracker/features/expenses/data/database/app_database.dart';
import 'package:finance_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finance_tracker/features/expenses/presentation/widgets/category_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.expense});

  final Expense? expense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _selectedCategory;
  bool _isSaving = false;
  String? _errorText;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(2),
    );
    _selectedCategory = expense?.category ?? appCategories.first.name;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit expense' : 'Add expense'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter expense title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value ?? '');
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  CategoryGrid(
                    selectedCategory: _selectedCategory,
                    onSelected: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 18),
                    Text(
                      _errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveExpense,
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isEditing ? 'Save changes' : 'Add expense'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      final amount = double.parse(_amountController.text);
      final notifier = ref.read(expenseProvider.notifier);
      final expense = widget.expense;

      if (expense == null) {
        await notifier.addExpense(
          title: _titleController.text.trim(),
          amount: amount,
          category: _selectedCategory,
        );
      } else {
        await notifier.updateExpense(
          id: expense.id,
          title: _titleController.text.trim(),
          amount: amount,
          category: _selectedCategory,
        );
      }

      if (mounted) context.go(AppRoutes.home);
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = 'Could not save expense. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
