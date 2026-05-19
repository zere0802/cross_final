import 'package:finance_tracker/core/constants/app_routes.dart';
import 'package:finance_tracker/features/expenses/data/database/app_database.dart';
import 'package:finance_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:finance_tracker/features/expenses/presentation/screens/home_screen.dart';
import 'package:finance_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:finance_tracker/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:finance_tracker/shared/widgets/app_shell.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(location: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.addExpense,
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: AddExpenseScreen(expense: state.extra as Expense?),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.statistics,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatisticsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
