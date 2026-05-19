import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';

import '../../../../shared/services/firestore_service.dart';

final databaseProvider =
    Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final repositoryProvider =
    Provider<ExpenseRepository>((ref) {

  final database =
      ref.watch(databaseProvider);

  return ExpenseRepositoryImpl(database);
});

final expenseProvider =
    StateNotifierProvider<
        ExpenseNotifier,
        List<Expense>>(
  (ref) {

    final repository =
        ref.watch(repositoryProvider);

    return ExpenseNotifier(repository);
  },
);

class ExpenseNotifier
    extends StateNotifier<List<Expense>> {

  bool isLoading = false;

  final ExpenseRepository repository;

  final FirestoreService
      firestoreService =
          FirestoreService();

  ExpenseNotifier(
    this.repository,
  ) : super([]) {

    loadExpenses();
  }

  Future<void> loadExpenses() async {

    isLoading = true;

    final expenses =
        await repository.getExpenses();

    state = expenses;

    isLoading = false;
  }

  Future<void> addExpense({

    required String title,

    required double amount,

    required String category,

  }) async {

    // SQLITE
    await repository.addExpense(
      title: title,
      amount: amount,
      category: category,
    );

    // FIREBASE
    await firestoreService
        .addSharedExpense(
      title: title,
      amount: amount,
      category: category,
    );

    await loadExpenses();
  }

  Future<void> deleteExpense(
    int id,
  ) async {

    await repository.deleteExpense(id);

    await loadExpenses();
  }

  Future<void> updateExpense({

    required int id,

    required String title,

    required double amount,

    required String category,

  }) async {

    await repository.updateExpense(
      id: id,
      title: title,
      amount: amount,
      category: category,
    );

    await loadExpenses();
  }

  double getTotalBalance() {

    double total = 0;

    for (final expense in state) {
      total += expense.amount;
    }

    return total;
  }
}