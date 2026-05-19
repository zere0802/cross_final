import '../../data/database/app_database.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
  });

  Future<void> deleteExpense(int id);

  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String category,
  });
}