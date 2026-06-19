import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_state.dart';
import 'package:aldeewan_mobile/data/services/balance_calculator_service.dart';

/// Result of attempting to delete a person
enum PersonDeletionStatus {
  /// Person can be deleted permanently (no transactions, zero balance)
  canDelete,
  /// Person has transactions but zero balance - can archive or cascade delete
  hasTransactions,
  /// Person has non-zero balance - can only archive
  hasBalance,
}

class PersonDeletionResult {
  final PersonDeletionStatus status;
  final int transactionCount;
  final double balance;

  const PersonDeletionResult({
    required this.status,
    required this.transactionCount,
    required this.balance,
  });
}

class LedgerNotifier extends StateNotifier<AsyncValue<LedgerState>> {
  final Ref ref;
  List<Person>? _persons;
  List<Transaction>? _transactions;
  StreamSubscription? _personSubscription;
  StreamSubscription? _transactionSubscription;

  LedgerNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initStreams();
  }

  void _initStreams() {
    _personSubscription = ref.read(personRepositoryProvider).watchPeople().listen(
      (persons) {
        _persons = persons;
        _updateState();
      },
      onError: (e, s) {
        state = AsyncValue.error(e, s);
      },
    );

    _transactionSubscription = ref.read(transactionRepositoryProvider).watchTransactions().listen(
      (transactions) {
        _transactions = transactions;
        _updateState();
      },
      onError: (e, s) {
        state = AsyncValue.error(e, s);
      },
    );
  }

  @override
  void dispose() {
    _personSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateState() async {
    if (_persons != null && _transactions != null) {
      try {
        final calculator = ref.read(balanceCalculatorProvider);
        final balances = await calculator.calculate(_persons!, _transactions!);
        
        if (mounted) {
          state = AsyncValue.data(LedgerState(
            persons: _persons!,
            transactions: _transactions!,
            balances: balances,
          ));
        }
      } catch (e, s) {
        if (mounted) {
          state = AsyncValue.error(e, s);
        }
      }
    }
  }

  Future<void> addPerson(Person person) async {
    await ref.read(personRepositoryProvider).addPerson(person);
  }

  /// Check if a person can be deleted and get relevant info
  Future<PersonDeletionResult> checkPersonDeletion(String id) async {
    final repo = ref.read(personRepositoryProvider);
    final transactionCount = await repo.getTransactionCount(id);
    final balance = state.value?.balances[id] ?? 0.0;

    PersonDeletionStatus status;
    if (balance != 0) {
      status = PersonDeletionStatus.hasBalance;
    } else if (transactionCount > 0) {
      status = PersonDeletionStatus.hasTransactions;
    } else {
      status = PersonDeletionStatus.canDelete;
    }

    return PersonDeletionResult(
      status: status,
      transactionCount: transactionCount,
      balance: balance,
    );
  }

  /// Archive a person (soft delete)
  Future<void> archivePerson(String id) async {
    await ref.read(personRepositoryProvider).archivePerson(id);
  }

  /// Delete person only (leaves orphan transactions - use with caution)
  Future<void> deletePerson(String id) async {
    await ref.read(personRepositoryProvider).deletePerson(id);
  }

  /// Delete person and all their transactions
  Future<void> deletePersonWithTransactions(String id) async {
    await ref.read(personRepositoryProvider).deletePersonWithTransactions(id);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await ref.read(transactionRepositoryProvider).addTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await ref.read(transactionRepositoryProvider).updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).deleteTransaction(id);
  }

  // --- Calculations ---

  double calculatePersonBalance(Person person) {
    return state.value?.balances[person.id] ?? 0.0;
  }

  double get totalReceivable {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getTotalReceivablesUseCaseProvider)(s.persons, s.balances);
  }

  double get totalPayable {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getTotalPayablesUseCaseProvider)(s.persons, s.balances);
  }

  double get monthlyIncome {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getMonthlyIncomeUseCaseProvider)(s.transactions);
  }

  double get monthlyExpense {
    final s = state.value;
    if (s == null) return 0.0;
    return ref.read(getMonthlyExpenseUseCaseProvider)(s.transactions);
  }
}

final ledgerProvider = StateNotifierProvider<LedgerNotifier, AsyncValue<LedgerState>>((ref) {
  return LedgerNotifier(ref);
});

/// Search query provider for ledger person filtering.
/// AutoDispose so the filter resets when the user leaves the screen.
final ledgerSearchProvider =
    StateProvider.autoDispose<String>((ref) => '');

// Filter: 'owes' = only show persons with outstanding balance, 'all' = show all
final ledgerBalanceFilterProvider =
    StateProvider.autoDispose<String>((ref) => 'all');

/// Toggle to show/hide archived persons
final showArchivedProvider =
    StateProvider.autoDispose<bool>((ref) => false);
