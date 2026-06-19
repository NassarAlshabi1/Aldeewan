import 'dart:async';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/data/repositories/inventory_repositories_impl.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/repositories/inventory_repositories.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';

/// Typed failures for the budget/goal flow. UIs should `switch` on the type
/// rather than string-matching `Exception` messages.
sealed class BudgetFailure {
  const BudgetFailure();
}

class InsufficientFundsFailure extends BudgetFailure {
  final double currentBalance;
  final double requested;
  const InsufficientFundsFailure(this.currentBalance, this.requested);
  @override
  String toString() =>
      'Insufficient funds. Current balance: $currentBalance, requested: $requested';
}

class InsufficientSavingsFailure extends BudgetFailure {
  final double currentSaved;
  final double requested;
  const InsufficientSavingsFailure(this.currentSaved, this.requested);
  @override
  String toString() =>
      'Insufficient savings in goal. Current: $currentSaved, requested: $requested';
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  final notifier = BudgetNotifier(repo);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier(this._repo) : super(const BudgetState()) {
    _init();
  }

  final BudgetRepository _repo;
  StreamSubscription<List<BudgetModel>>? _budgetSubscription;
  StreamSubscription<List<SavingsGoalModel>>? _goalSubscription;
  // The Transaction stream still comes from Realm directly — we only need it
  // for the "transaction added/changed → recompute spent/saved" trigger.
  // It would be cleaner to expose this via TransactionRepository, but that
  // interface currently exposes watchTransactions() returning DTOs which we
  // do not need here; we just need the change notification.
  StreamSubscription? _transactionSubscription;
  Timer? _recalculateDebounceTimer;
  Realm? _realm;

  void _init() async {
    state = state.copyWith(isLoading: true);
    await _checkRecurringBudgets();
    await _recalculateAllBudgets();
    await _recalculateAllGoals();
    _updateStateFromRepo();

    _budgetSubscription = _repo.watchBudgets().listen((_) {
      _updateStateFromRepo();
    });
    _goalSubscription = _repo.watchGoals().listen((_) {
      _updateStateFromRepo();
    });

    // For the transaction trigger, we read the underlying Realm via the
    // data source's exposed stream (kept internal to the data layer).
    // This is the only Realm reference left in this notifier — and only
    // because the TransactionRepository interface returns DTOs, not the
    // raw change events we need here.
    _realm = await (_repo as BudgetRepositoryImpl).dataSource.db;
    _transactionSubscription =
        _realm!.all<TransactionModel>().changes.listen((_) {
      _recalculateDebounceTimer?.cancel();
      _recalculateDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        _recalculateAllBudgets();
        _recalculateAllGoals();
      });
    });
  }

  @override
  void dispose() {
    _recalculateDebounceTimer?.cancel();
    _transactionSubscription?.cancel();
    _budgetSubscription?.cancel();
    _goalSubscription?.cancel();
    super.dispose();
  }

  void _updateStateFromRepo() async {
    final budgets = await _repo.getBudgets();
    final goals = await _repo.getGoals();
    if (!mounted) return;
    state = state.copyWith(
      budgets: budgets,
      goals: goals,
      isLoading: false,
    );
  }

  Future<void> _recalculateAllBudgets() async {
    final budgets = await _repo.getBudgets();
    for (final budget in budgets) {
      final spent = _calculateSpent(budget);
      if (budget.currentSpent != spent) {
        budget.currentSpent = spent;
        await _repo.upsertBudget(budget);
      }
    }
  }

  Future<void> _recalculateAllGoals() async {
    final goals = await _repo.getGoals();
    for (final goal in goals) {
      final saved = _calculateSaved(goal);
      if (goal.currentSaved != saved) {
        goal.currentSaved = saved;
        await _repo.upsertGoal(goal);
      }
    }
  }

  double _calculateSaved(SavingsGoalModel goal) {
    final realm = _realm;
    if (realm == null) return 0.0;
    final transactions = realm.all<TransactionModel>().query(
      'goalId == \$0',
      [goal.id.toString()],
    );
    double total = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.cashExpense.name) {
        total += t.amount;
      } else if (t.type == TransactionType.cashIncome.name) {
        total -= t.amount;
      }
    }
    return total < 0 ? 0 : total;
  }

  Future<void> _checkRecurringBudgets() async {
    final now = DateTime.now();
    final budgets = await _repo.getBudgets();
    final newBudgets = <BudgetModel>[];
    for (final budget in budgets) {
      if (budget.isRecurring && budget.endDate.isBefore(now)) {
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        final newBudget = BudgetModel(
          ObjectId(),
          budget.category,
          budget.amountLimit,
          0.0,
          startOfMonth,
          endOfMonth,
          isRecurring: true,
        );
        newBudgets.add(newBudget);
        budget.isRecurring = false;
        await _repo.upsertBudget(budget);
      }
    }
    for (final b in newBudgets) {
      await _repo.upsertBudget(b);
    }
  }

  double _calculateSpent(BudgetModel budget) {
    final realm = _realm;
    if (realm == null) return 0;
    final transactions = realm
        .query<TransactionModel>(
          'date >= \$0 AND date <= \$1 AND category == \$2',
          [budget.startDate, budget.endDate, budget.category],
        )
        .toList();
    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.cashExpense.name ||
          t.type == TransactionType.paymentMade.name) {
        total += t.amount;
      }
    }
    return total;
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _repo.upsertBudget(budget);
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await _repo.upsertGoal(goal);
  }

  Future<void> deleteBudget(ObjectId id) async {
    await _repo.deleteBudget(id);
  }

  Future<void> deleteGoal(ObjectId id) async {
    await _repo.deleteGoal(id);
  }

  Future<void> editGoal(
    SavingsGoalModel goal, {
    String? name,
    double? targetAmount,
    String? icon,
    DateTime? deadline,
  }) async {
    if (name != null) goal.name = name;
    if (targetAmount != null) goal.targetAmount = targetAmount;
    if (icon != null) goal.icon = icon;
    if (deadline != null) goal.deadline = deadline;
    await _repo.upsertGoal(goal);
  }

  Future<void> editBudget(
    BudgetModel budget, {
    double? amountLimit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (amountLimit != null) budget.amountLimit = amountLimit;
    if (startDate != null) budget.startDate = startDate;
    if (endDate != null) budget.endDate = endDate;
    await _repo.upsertBudget(budget);
  }

  Future<void> updateGoalAmount(ObjectId id, double newAmount) async {
    final goals = await _repo.getGoals();
    final goal = goals.firstWhere((g) => g.id == id);
    goal.currentSaved = newAmount;
    await _repo.upsertGoal(goal);
  }

  /// Adds funds to a goal and records a corresponding expense transaction.
  /// Throws [InsufficientFundsFailure] if funds are insufficient.
  Future<void> updateGoal(SavingsGoalModel goal, double amountAdded) async {
    final currentBalance = _calculateCurrentBalance();
    if (currentBalance < amountAdded) {
      throw InsufficientFundsFailure(currentBalance, amountAdded);
    }

    goal.currentSaved += amountAdded;
    await _repo.upsertGoal(goal);

    final realm = _realm;
    if (realm == null) return;
    final transaction = TransactionModel(
      const Uuid().v4(),
      TransactionType.cashExpense.name,
      amountAdded,
      DateTime.now(),
      category: 'Savings',
      note: 'Contribution to goal: ${goal.name}',
      goalId: goal.id.toString(),
    );
    realm.write(() => realm.add(transaction));
  }

  Future<void> withdrawFromGoal(
      SavingsGoalModel goal, double amountWithdrawn) async {
    if (goal.currentSaved < amountWithdrawn) {
      throw InsufficientSavingsFailure(goal.currentSaved, amountWithdrawn);
    }

    goal.currentSaved -= amountWithdrawn;
    await _repo.upsertGoal(goal);

    final realm = _realm;
    if (realm == null) return;
    final transaction = TransactionModel(
      const Uuid().v4(),
      TransactionType.cashIncome.name,
      amountWithdrawn,
      DateTime.now(),
      category: 'Savings',
      note: 'Withdrawal from goal: ${goal.name}',
      goalId: goal.id.toString(),
    );
    realm.write(() => realm.add(transaction));
  }

  double _calculateCurrentBalance() {
    final realm = _realm;
    if (realm == null) return 0;
    final transactions = realm.all<TransactionModel>();
    double balance = 0;
    for (final t in transactions) {
      final type = t.type;
      if (type == TransactionType.paymentReceived.name ||
          type == TransactionType.cashSale.name ||
          type == TransactionType.cashIncome.name) {
        balance += t.amount;
      } else if (type == TransactionType.paymentMade.name ||
          type == TransactionType.cashExpense.name) {
        balance -= t.amount;
      }
    }
    return balance;
  }
}
