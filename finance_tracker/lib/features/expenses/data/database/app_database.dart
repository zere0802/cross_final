import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  RealColumn get amount => real()();

  TextColumn get category => text()();

  DateTimeColumn get date => dateTime()();
}

@DriftDatabase(tables: [Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Expense>> getAllExpenses() =>
      select(expenses).get();

  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  Future<bool> updateExpense(Expense expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder =
        await getApplicationDocumentsDirectory();

    final file = File(
      p.join(dbFolder.path, 'expenses.sqlite'),
    );

    return NativeDatabase(file);
  });
}