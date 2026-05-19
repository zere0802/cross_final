import 'package:finance_tracker/core/constants/app_routes.dart';
import 'package:finance_tracker/features/expenses/data/database/app_database.dart';
import 'package:finance_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finance_tracker/features/expenses/presentation/widgets/expense_card.dart';
import 'package:finance_tracker/features/expenses/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final notifier = ref.read(expenseProvider.notifier);
    final total = expenses.fold<double>(
      0,
      (previous, expense) => previous + expense.amount,
    );

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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              sliver: SliverToBoxAdapter(
                child: SummaryCard(total: total, count: expenses.length),
              ),
            ),
            if (notifier.isLoading && expenses.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (expenses.isEmpty)
              const SliverFillRemaining(
                child: _EmptyExpenses(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 1000 ? 4 : width >= 680 ? 3 : 2;

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: width < 420 ? 0.75 : 0.9,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final expense = expenses[index];

                          return ExpenseCard(
                            expense: expense,
                            onEdit: () => context.go(
                              AppRoutes.addExpense,
                              extra: expense,
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              ref,
                              expense,
                            ),
                          );
                        },
                        childCount: expenses.length,
                      ),
                    );
                  },
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

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap Add to record your first transaction.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
