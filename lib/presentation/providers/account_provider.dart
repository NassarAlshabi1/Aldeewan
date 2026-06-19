import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/datasources/mock_bank_provider.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:uuid/uuid.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, List<FinancialAccountModel>>((ref) {
  final realmAsync = ref.watch(realmProvider);
  return realmAsync.when(
    data: (realm) => AccountNotifier(realm),
    loading: () => AccountNotifier(null), // Handle loading state if needed
    error: (e, s) => AccountNotifier(null),
  );
});

class AccountNotifier extends StateNotifier<List<FinancialAccountModel>> {
  final Realm? _realm;
  StreamSubscription<RealmResultsChanges<FinancialAccountModel>>? _accountsSubscription;

  AccountNotifier(this._realm) : super([]) {
    if (_realm != null) {
      loadAccounts();
    }
  }

  void loadAccounts() {
    if (_realm == null) return;
    final accounts = _realm.all<FinancialAccountModel>();
    state = accounts.toList();

    // Listen for changes — subscription MUST be cancelled in dispose.
    _accountsSubscription = accounts.changes.listen((changes) {
      if (!mounted) return;
      state = changes.results.toList();
    });
  }

  Future<void> linkAccount(
    String providerId,
    String username,
    String password, {
    String? displayName,
  }) async {
    if (_realm == null) return;

    try {
      BankProviderInterface provider;
      switch (providerId) {
        case 'MOCK_BANK':
          provider = MockBankProvider();
          break;
        default:
          throw UnsupportedProviderException(providerId);
      }

      final isAuthenticated = await provider.authenticate(username, password);

      if (isAuthenticated) {
        // In a real app, we would get a token and account ID from the provider.
        // For mock, we generate a unique external ID per link to avoid PK collisions.
        final externalAccountId = 'ACC_${const Uuid().v4()}';
        final initialBalance = await provider.getBalance(externalAccountId);

        final newAccount = FinancialAccountModel(
          DateTime.now().millisecondsSinceEpoch,
          displayName ?? provider.displayName,
          providerId,
          'BANK',
          initialBalance,
          'SDG',
          externalAccountId: externalAccountId,
          lastSyncTime: DateTime.now(),
          status: 'ACTIVE',
        );

        _realm.write(() {
          _realm.add(newAccount, update: true);
        });
      } else {
        throw const AccountLinkException('Authentication failed');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error linking account: $e');
      rethrow;
    }
  }

  Future<void> unlinkAccount(int accountId) async {
    if (_realm == null) return;
    _realm.write(() {
      final account = _realm.find<FinancialAccountModel>(accountId);
      if (account != null) {
        _realm.delete<FinancialAccountModel>(account);
      }
    });
  }

  @override
  void dispose() {
    _accountsSubscription?.cancel();
    super.dispose();
  }
}

/// Typed failures for the account-linking flow (instead of bare Exception
/// strings that the UI string-matches on).
class UnsupportedProviderException implements Exception {
  final String providerId;
  const UnsupportedProviderException(this.providerId);
  @override
  String toString() => 'Unsupported bank provider: $providerId';
}

class AccountLinkException implements Exception {
  final String message;
  const AccountLinkException(this.message);
  @override
  String toString() => message;
}
