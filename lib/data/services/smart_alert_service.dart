import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';

/// Provider exposing the singleton [SmartAlertService].
final smartAlertServiceProvider = Provider<SmartAlertService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SmartAlertService(ref, prefs);
});

/// Generates rule-based "smart" notifications on app start and on resume.
///
/// Rules evaluated (each deduped by a per-rule+period key persisted in
/// SharedPreferences so we don't fire the same alert twice for the same
/// month):
///
///  - Budget overrun: any budget whose `currentSpent / amountLimit >= 0.8`
///    fires once per (budget, month).
///  - Idle user: if no transaction has been logged in the last 72 hours,
///    fire once per day.
///  - Overdue receivable: any customer with a positive balance older than
///    30 days (no `paymentReceived` from them in 30 days while balance > 0)
///    fires once per (person, month).
class SmartAlertService {
  SmartAlertService(this._ref, this._prefs);

  final Ref _ref;
  final SharedPreferences _prefs;

  static const _kBudgetPrefix = 'smart_alert_budget_';
  static const _kIdleKey = 'smart_alert_idle_last_run';
  static const _kOverduePrefix = 'smart_alert_overdue_';

  /// Run all smart-alert rules. Returns the number of notifications fired.
  Future<int> runAll({DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    int fired = 0;
    fired += await _checkBudgetOverruns(currentTime);
    fired += await _checkIdleUser(currentTime);
    fired += await _checkOverdueReceivables(currentTime);
    return fired;
  }

  Future<int> _checkBudgetOverruns(DateTime now) async {
    int fired = 0;
    final budgetState = _ref.read(budgetProvider);
    final notifier = _ref.read(notificationHistoryProvider.notifier);

    final periodKey = '${now.year}-${now.month}';
    for (final b in budgetState.budgets) {
      if (b.amountLimit <= 0) continue;
      final ratio = b.currentSpent / b.amountLimit;
      if (ratio < 0.8) continue;

      final key = '$_kBudgetPrefix${b.id}_$periodKey';
      if (_prefs.getBool(key) == true) continue;

      final percent = (ratio * 100).round();
      await notifier.addNotification(
        title: 'Budget alert: ${b.category}',
        body: 'You have used $percent% of your budget for "${b.category}" '
            '(${b.currentSpent.toStringAsFixed(2)} / ${b.amountLimit.toStringAsFixed(2)}).',
        type: 'warning',
      );
      await _prefs.setBool(key, true);
      fired++;
    }
    return fired;
  }

  Future<int> _checkIdleUser(DateTime now) async {
    final ledgerAsync = _ref.read(ledgerProvider);
    final ledger = ledgerAsync.valueOrNull;
    if (ledger == null || ledger.transactions.isEmpty) return 0;

    final lastTx = ledger.transactions.reduce(
        (a, b) => a.date.isAfter(b.date) ? a : b);
    final idleHours = now.difference(lastTx.date).inHours;
    if (idleHours < 72) return 0;

    // Fire at most once per day.
    final todayKey = '${now.year}-${now.month}-${now.day}';
    if (_prefs.getString('$_kIdleKey-$todayKey') != null) return 0;

    final notifier = _ref.read(notificationHistoryProvider.notifier);
    await notifier.addNotification(
      title: 'Stay on top of your finances',
      body: "You haven't logged a transaction in the last "
          '${(idleHours / 24).floor()} days. '
          'Don\'t forget to record today\'s activity!',
      type: 'info',
    );
    await _prefs.setString('$_kIdleKey-$todayKey', now.toIso8601String());
    return 1;
  }

  Future<int> _checkOverdueReceivables(DateTime now) async {
    final ledgerAsync = _ref.read(ledgerProvider);
    final ledger = ledgerAsync.valueOrNull;
    if (ledger == null) return 0;

    final notifier = _ref.read(notificationHistoryProvider.notifier);
    final balances = ledger.balances; // Map<String, double> personId -> balance
    int fired = 0;
    final periodKey = '${now.year}-${now.month}';

    for (final person in ledger.persons) {
      final balance = balances[person.id] ?? 0;
      if (balance <= 0) continue; // not owed money

      // Has the customer paid in the last 30 days?
      final lastPayment = ledger.transactions
          .where((t) =>
              t.personId == person.id &&
              (t.type == TransactionType.paymentReceived ||
                  t.type == TransactionType.cashSale))
          .fold<DateTime?>(null, (latest, t) {
        if (latest == null) return t.date;
        return t.date.isAfter(latest) ? t.date : latest;
      });

      final cutoff = now.subtract(const Duration(days: 30));
      if (lastPayment != null && lastPayment.isAfter(cutoff)) continue;

      final key = '$_kOverduePrefix${person.id}_$periodKey';
      if (_prefs.getBool(key) == true) continue;

      await notifier.addNotification(
        title: 'Overdue receivable: ${person.name}',
        body: '${person.name} owes you ${balance.toStringAsFixed(2)} '
            'and hasn\'t made a payment in over 30 days. '
            'Consider sending a reminder.',
        type: 'warning',
      );
      await _prefs.setBool(key, true);
      fired++;
    }
    return fired;
  }

  /// Clear all dedup state. Useful when the user clears all notifications.
  Future<void> reset() async {
    final keys = _prefs
        .getKeys()
        .where((k) =>
            k.startsWith(_kBudgetPrefix) ||
            k.startsWith(_kIdleKey) ||
            k.startsWith(_kOverduePrefix))
        .toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
