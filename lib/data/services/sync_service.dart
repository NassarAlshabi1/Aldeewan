import 'package:flutter/foundation.dart';
import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/datasources/mock_bank_provider.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/repositories/inventory_repositories.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final accountRepo = ref.watch(accountRepositoryProvider);
  final realmFuture = ref.watch(realmProvider.future);
  return SyncService(accountRepo, realmFuture);
});

/// Result of a single sync run — exposed so the UI can show a meaningful
/// "N new transactions synced" toast instead of swallowing errors silently.
class SyncResult {
  final int accountsSynced;
  final int transactionsAdded;
  final List<String> errors;
  const SyncResult({
    this.accountsSynced = 0,
    this.transactionsAdded = 0,
    this.errors = const [],
  });
  bool get isSuccess => errors.isEmpty;
}

class SyncService {
  SyncService(this._accountRepo, this._realmFuture);

  final AccountRepository _accountRepo;
  final Future<Realm> _realmFuture;

  /// Sync all linked accounts. Returns a [SyncResult] summarising the run.
  Future<SyncResult> syncAllAccounts() async {
    final accounts = await _accountRepo.getAccounts();
    int accountsSynced = 0;
    int transactionsAdded = 0;
    final errors = <String>[];

    for (final account in accounts) {
      if (account.providerId.isEmpty) continue;
      final result = await _syncAccount(account);
      accountsSynced += 1;
      transactionsAdded += result.transactionsAdded;
      if (result.error != null) errors.add(result.error!);
    }
    return SyncResult(
      accountsSynced: accountsSynced,
      transactionsAdded: transactionsAdded,
      errors: errors,
    );
  }

  Future<_AccountSyncResult> _syncAccount(
      FinancialAccountModel account) async {
    BankProviderInterface provider;
    switch (account.providerId) {
      case 'MOCK_BANK':
        provider = MockBankProvider();
        break;
      default:
        return _AccountSyncResult(
          error: 'Unsupported provider: ${account.providerId}',
        );
    }

    try {
      final realm = await _realmFuture;
      // Fetch transactions since last sync or last 30 days.
      final lastSync = account.lastSyncTime ??
          DateTime.now().subtract(const Duration(days: 30));
      final transactions = await provider.fetchTransactions(
          account.externalAccountId ?? '', lastSync);

      if (transactions.isEmpty) {
        // Still update the sync timestamp so the next run starts from now.
        final newBalance =
            await provider.getBalance(account.externalAccountId ?? '');
        account.balance = newBalance;
        account.lastSyncTime = DateTime.now();
        await _accountRepo.upsertAccount(account);
        return const _AccountSyncResult();
      }

      // Pre-load existing external IDs in a single query (one pass, no N+1).
      final existingExternalIds = realm
          .query<TransactionModel>('externalId != nil')
          .map((t) => t.externalId)
          .toSet();

      int added = 0;
      // Bulk write all new transactions in a single transaction.
      realm.write(() {
        for (final txn in transactions) {
          if (txn.externalId == null) continue;
          if (existingExternalIds.contains(txn.externalId)) continue;
          txn.accountId = account.id;
          realm.add(txn);
          added++;
        }
      });

      // Fetch balance and update the account.
      final newBalance =
          await provider.getBalance(account.externalAccountId ?? '');
      account.balance = newBalance;
      account.lastSyncTime = DateTime.now();
      await _accountRepo.upsertAccount(account);

      return _AccountSyncResult(transactionsAdded: added);
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('Error syncing account ${account.id}: $e\n$s');
      }
      return _AccountSyncResult(error: e.toString());
    }
  }
}

class _AccountSyncResult {
  final int transactionsAdded;
  final String? error;
  const _AccountSyncResult({this.transactionsAdded = 0, this.error});
}
