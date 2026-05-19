import 'package:finance_tracker/core/constants/app_categories.dart';
import 'package:finance_tracker/core/currency_provider.dart';
import 'package:finance_tracker/features/expenses/data/database/app_database.dart';
import 'package:finance_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final currency = ref.watch(currencyProvider);
    final totals = _totalsByCategory(expenses);
    final total = totals.values.fold<double>(0, (sum, value) => sum + value);
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatsHeader(
                        total: total,
                        currency: currency,
                        categories: sortedEntries.length,
                        isMock: expenses.isEmpty,
                      ),
                      const SizedBox(height: 16),
                      _PieChartPanel(entries: sortedEntries, total: total),
                      const SizedBox(height: 16),
                      _WeeklyBarChart(expenses: expenses, currency: currency),
                      const SizedBox(height: 16),
                      _CategoryBreakdown(
                        entries: sortedEntries,
                        total: total,
                        currency: currency,
                      ),
                    ],
                  ),
                ),
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
    required this.isMock,
  });

  final double total;
  final String currency;
  final int categories;
  final bool isMock;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMock ? 'No spending yet' : 'Monthly overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currency ${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
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
    );
  }
}

class _PieChartPanel extends StatelessWidget {
  const _PieChartPanel({required this.entries, required this.total});

  final List<MapEntry<String, double>> entries;
  final double total;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Category split',
      child: entries.isEmpty
          ? const _EmptyAnalyticsMessage(
              icon: Icons.pie_chart_outline,
              title: 'No category data',
              subtitle: 'Add expenses to build the pie chart.',
            )
          : SizedBox(
              height: 230,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 46,
                        sectionsSpace: 3,
                        sections: entries.take(6).map((entry) {
                          final category = categoryByName(entry.key);
                          final percent = total == 0
                              ? 0.0
                              : entry.value / total * 100;

                          return PieChartSectionData(
                            value: entry.value,
                            color: category.color,
                            radius: 64,
                            title: '${percent.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.take(5).map((entry) {
                        final category = categoryByName(entry.key);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.expenses, required this.currency});

  final List<Expense> expenses;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final values = _weeklyTotals(expenses);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final colorScheme = Theme.of(context).colorScheme;

    return _Panel(
      title: 'Weekly trend',
      child: SizedBox(
        height: 230,
        child: BarChart(
          BarChartData(
            maxY: maxValue == 0 ? 100 : maxValue * 1.25,
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 44,
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    return Text(
                      '$currency ${value.toInt()}',
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final index = value.toInt();

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        index >= 0 && index < labels.length
                            ? labels[index]
                            : '',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < values.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i],
                      width: 18,
                      borderRadius: BorderRadius.circular(8),
                      color: values[i] == 0
                          ? colorScheme.outlineVariant.withValues(alpha: 0.55)
                          : null,
                      gradient: values[i] == 0
                          ? null
                          : LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                colorScheme.primary,
                                colorScheme.tertiary,
                              ],
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.entries,
    required this.total,
    required this.currency,
  });

  final List<MapEntry<String, double>> entries;
  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Category summaries',
      child: entries.isEmpty
          ? const _EmptyAnalyticsMessage(
              icon: Icons.insights_outlined,
              title: 'No summaries yet',
              subtitle: 'Category summaries are calculated from your expenses.',
            )
          : Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _CategoryStatTile(
                    category: categoryByName(entries[i].key),
                    amount: entries[i].value,
                    currency: currency,
                    percent: total == 0 ? 0 : entries[i].value / total,
                  ),
                  if (i != entries.length - 1) const SizedBox(height: 12),
                ],
              ],
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
    return Column(
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
          backgroundColor: category.color.withValues(alpha: 0.14),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

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
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmptyAnalyticsMessage extends StatelessWidget {
  const _EmptyAnalyticsMessage({
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
      padding: const EdgeInsets.symmetric(vertical: 18),
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
