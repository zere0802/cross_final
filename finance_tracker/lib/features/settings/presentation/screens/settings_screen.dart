import 'package:finance_tracker/core/currency_provider.dart';
import 'package:finance_tracker/core/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(themePreference.icon),
                      const SizedBox(width: 12),
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<AppThemePreference>(
                    segments: AppThemePreference.values
                        .map(
                          (theme) => ButtonSegment(
                            value: theme,
                            icon: Icon(theme.icon),
                            label: Text(theme.label),
                          ),
                        )
                        .toList(),
                    selected: {themePreference},
                    onSelectionChanged: (selection) {
                      ref.read(themeProvider.notifier).setTheme(
                            selection.first,
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money),
                      const SizedBox(width: 12),
                      Text(
                        'Currency',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'USD', label: Text('USD')),
                      ButtonSegment(value: 'KZT', label: Text('KZT')),
                      ButtonSegment(value: 'EUR', label: Text('EUR')),
                    ],
                    selected: {currency},
                    onSelectionChanged: (selection) {
                      ref
                          .read(currencyProvider.notifier)
                          .setCurrency(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.storage_outlined),
              title: Text('Storage'),
              subtitle: Text('Expenses are saved locally with Drift.'),
            ),
          ),
        ],
      ),
    );
  }
}
