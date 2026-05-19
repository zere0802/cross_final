import 'package:finance_tracker/core/constants/app_categories.dart';
import 'package:finance_tracker/core/currency_provider.dart';
import 'package:finance_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final currency = ref.watch(currencyProvider);
    final totals = <String, double>{};

    for (final expense in expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final total = totals.values.fold<double>(0, (sum, value) => sum + value);
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _StatsHeader(
                total: total,
                currency: currency,
                categories: sortedEntries.length,
              ),
            ),
          ),
          if (sortedEntries.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Statistics will appear here.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) return const SizedBox(height: 10);

                    final entry = sortedEntries[index ~/ 2];
                    final percent = total == 0 ? 0.0 : entry.value / total;
                    final category = categoryByName(entry.key);

                    return _CategoryStatTile(
                      category: category,
                      amount: entry.value,
                      currency: currency,
                      percent: percent,
                    );
                  },
                  childCount: sortedEntries.length * 2 - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({
    required this.total,
    required this.currency,
    required this.categories,
  });

  final double total;
  final String currency;
  final int categories;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly overview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency ${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            Chip(
              avatar: const Icon(Icons.category_outlined, size: 18),
              label: Text('$categories categories'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStatTile extends StatelessWidget {
  const _CategoryStatTile({
    required this.category,
    required this.amount,
    required this.currency,
    required this.percent,
  });

  final AppCategory category;
  final double amount;
  final String currency;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(category.icon, color: category.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '$currency ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: category.color,
              backgroundColor: category.color.withOpacity(0.14),
            ),
          ],
        ),
      ),
    );
  }
}
