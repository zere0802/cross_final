import 'package:finance_tracker/core/constants/app_categories.dart';
import 'package:finance_tracker/core/constants/app_routes.dart';
import 'package:finance_tracker/core/currency_provider.dart';
import 'package:finance_tracker/features/expenses/data/database/app_database.dart';
import 'package:finance_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finance_tracker/features/expenses/presentation/widgets/summary_card.dart';
import 'package:finance_tracker/shared/shared_expenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final notifier = ref.read(expenseProvider.notifier);
    final currency = ref.watch(currencyProvider);
    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final recent = [...expenses]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addExpense),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Finance Tracker'),
              actions: [
                IconButton(
                  tooltip: 'Shared Expenses',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SharedExpensesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_outlined),
                ),
                IconButton(
                  tooltip: 'Statistics',
                  onPressed: () => context.go(AppRoutes.statistics),
                  icon: const Icon(Icons.bar_chart_outlined),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => context.go(AppRoutes.settings),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: notifier.isLoading && expenses.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              key: ValueKey(expenses.length),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SummaryCard(
                                  total: total,
                                  count: expenses.length,
                                ),
                                const SizedBox(height: 16),
                                _QuickActions(
                                  onAdd: () => context.go(AppRoutes.addExpense),
                                ),
                                const SizedBox(height: 16),
                                _CategorySummary(
                                  expenses: expenses,
                                  currency: currency,
                                ),
                                const SizedBox(height: 16),
                                _RecentTransactions(
                                  expenses: recent.take(5).toList(),
                                  currency: currency,
                                  onEdit: (expense) => context.go(
                                    AppRoutes.addExpense,
                                    extra: expense,
                                  ),
                                  onDelete: (expense) =>
                                      _confirmDelete(context, ref, expense),
                                ),
                                const SizedBox(height: 16),
                                _WeeklySpending(
                                  expenses: expenses,
                                  currency: currency,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: Text('Remove "${expense.title}" from your expenses?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(expenseProvider.notifier).deleteExpense(expense.id);
    }
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_card_outlined,
              label: 'Expense',
              onTap: onAdd,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: _ActionButton(icon: Icons.savings_outlined, label: 'Budget'),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: _ActionButton(
              icon: Icons.swap_horiz_outlined,
              label: 'Transfer',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  const _CategorySummary({required this.expenses, required this.currency});

  final List<Expense> expenses;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final totals = _totalsByCategory(expenses);
    final entries = appCategories.take(4).toList();

    return _Panel(
      title: 'Quick categories',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 10) / 2;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: entries.map((category) {
              final amount = totals[category.name] ?? 0;

              return SizedBox(
                width: itemWidth,
                child: _CategoryChip(
                  category: category,
                  amount: amount,
                  currency: currency,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.amount,
    required this.currency,
  });

  final AppCategory category;
  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(category.icon, color: category.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$currency ${amount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({
    required this.expenses,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Expense> expenses;
  final String currency;
  final ValueChanged<Expense> onEdit;
  final ValueChanged<Expense> onDelete;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Recent transactions',
      child: expenses.isEmpty
          ? const _EmptyPanelMessage(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              subtitle: 'Added expenses will appear here.',
            )
          : Column(
              children: [
                for (var i = 0; i < expenses.length; i++) ...[
                  _TransactionRow(
                    expense: expenses[i],
                    currency: currency,
                    onEdit: () => onEdit(expenses[i]),
                    onDelete: () => onDelete(expenses[i]),
                  ),
                  if (i != expenses.length - 1) const Divider(height: 18),
                ],
              ],
            ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.expense,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = categoryByName(expense.category);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(category.icon, color: category.color),
      ),
      title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${expense.category} • ${_formatDate(expense.date)}'),
      trailing: Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$currency ${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _WeeklySpending extends StatelessWidget {
  const _WeeklySpending({required this.expenses, required this.currency});

  final List<Expense> expenses;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final values = _weeklyTotals(expenses);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return _Panel(
      title: 'Weekly spending',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$currency ${values.fold<double>(0, (sum, value) => sum + value).toStringAsFixed(2)} this week',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _WeeklyBar(
                        value: values[i],
                        maxValue: maxValue == 0 ? 1 : maxValue,
                        label: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({
    required this.value,
    required this.maxValue,
    required this.label,
  });

  final double value;
  final double maxValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final heightFactor = value == 0 ? 0.0 : (value / maxValue).clamp(0.12, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 92 * heightFactor,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _EmptyPanelMessage extends StatelessWidget {
  const _EmptyPanelMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, double> _totalsByCategory(List<Expense> expenses) {
  final totals = <String, double>{};
  for (final expense in expenses) {
    totals.update(
      expense.category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
}

List<double> _weeklyTotals(List<Expense> expenses) {
  final now = DateTime.now();
  final start = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));
  final values = List<double>.filled(7, 0);

  for (final expense in expenses) {
    final day = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );
    final index = day.difference(start).inDays;
    if (index >= 0 && index < 7) {
      values[index] += expense.amount;
    }
  }

  return values;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
