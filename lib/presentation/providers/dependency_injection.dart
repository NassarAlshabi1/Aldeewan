import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/repositories/person_repository_impl.dart';
import 'package:aldeewan_mobile/data/repositories/transaction_repository_impl.dart';
import 'package:aldeewan_mobile/data/repositories/inventory_repositories_impl.dart';
import 'package:aldeewan_mobile/domain/repositories/person_repository.dart';
import 'package:aldeewan_mobile/domain/repositories/transaction_repository.dart';
import 'package:aldeewan_mobile/domain/repositories/inventory_repositories.dart';
import 'package:aldeewan_mobile/domain/usecases/calculate_balances_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_total_receivables_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_total_payables_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_monthly_income_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_monthly_expense_usecase.dart';

// ============================================================
// Shared infrastructure providers (single source of truth)
// ============================================================

/// Single shared SharedPreferences instance — all notifiers should read this
/// provider instead of calling `SharedPreferences.getInstance()` themselves.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before use.',
  );
});

// Data Source (canonical definition; do not redefine elsewhere).
final localDatabaseSourceProvider = Provider<LocalDatabaseSource>((ref) {
  return LocalDatabaseSource();
});

// ============================================================
// Repositories — Person & Transaction
// ============================================================
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return PersonRepositoryImpl(dataSource);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return TransactionRepositoryImpl(dataSource);
});

// ============================================================
// Repositories — Budget / Goal / Category / Account / Notification / Inventory
// ============================================================
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return BudgetRepositoryImpl(dataSource);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return AccountRepositoryImpl(dataSource);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return NotificationRepositoryImpl(dataSource);
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return InventoryRepositoryImpl(dataSource);
});

// ============================================================
// Use Cases
// ============================================================
final calculateBalancesUseCaseProvider = Provider<CalculateBalancesUseCase>((ref) {
  return CalculateBalancesUseCase();
});

final getTotalReceivablesUseCaseProvider = Provider<GetTotalReceivablesUseCase>((ref) {
  return GetTotalReceivablesUseCase();
});

final getTotalPayablesUseCaseProvider = Provider<GetTotalPayablesUseCase>((ref) {
  return GetTotalPayablesUseCase();
});

final getMonthlyIncomeUseCaseProvider = Provider<GetMonthlyIncomeUseCase>((ref) {
  return GetMonthlyIncomeUseCase();
});

final getMonthlyExpenseUseCaseProvider = Provider<GetMonthlyExpenseUseCase>((ref) {
  return GetMonthlyExpenseUseCase();
});
