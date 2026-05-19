import 'package:finance_tracker/features/expenses/data/database/app_database.dart';
import 'package:finance_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:finance_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:finance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Finance Tracker opens home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(_FakeExpenseRepository()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Finance Tracker'), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}

class _FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
  }) async {}

  @override
  Future<void> deleteExpense(int id) async {}

  @override
  Future<List<Expense>> getExpenses() async => [];

  @override
  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String category,
  }) async {}
}
