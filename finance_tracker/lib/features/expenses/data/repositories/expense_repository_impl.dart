import '../../domain/repositories/expense_repository.dart';
import '../database/app_database.dart';

class ExpenseRepositoryImpl
    implements ExpenseRepository {
  final AppDatabase database;

  ExpenseRepositoryImpl(this.database);

  @override
  Future<List<Expense>> getExpenses() async {
    return await database.getAllExpenses();
  }

  @override
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
  }) async {
    await database.insertExpense(
      ExpensesCompanion.insert(
        title: title,
        amount: amount,
        category: category,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteExpense(int id) async {
    await database.deleteExpense(id);
  }

  @override
  Future<void> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String category,
  }) async {
    await database.updateExpense(
      Expense(
        id: id,
        title: title,
        amount: amount,
        category: category,
        date: DateTime.now(),
      ),
    );
  }
}