import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';

import 'package:aldeewan_mobile/data/models/recurring_transaction_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/database_provider.dart';

/// Provider exposing the singleton [RecurringTransactionService].
final recurringTransactionServiceProvider =
    Provider<RecurringTransactionService>((ref) {
  final realmFuture = ref.watch(realmProvider.future);
  return RecurringTransactionService(realmFuture);
});

/// Service that materialises due recurring transactions into actual
/// [TransactionModel] rows.
///
/// Call [runDue] on app start and on `AppLifecycleState.resumed` so missed
/// occurrences are generated (capped at 30 catch-up events per rule to
/// protect against an offline device generating thousands of historical
/// transactions after a long absence).
class RecurringTransactionService {
  RecurringTransactionService(this._realmFuture);

  final Future<Realm> _realmFuture;

  static const int _maxCatchUpOccurrences = 30;

  /// Process all rules whose [RecurringTransactionModel.nextRunDate] is due.
  /// Returns the number of transactions actually generated.
  Future<int> runDue({DateTime? now}) async {
    final realm = await _realmFuture;
    final currentTime = now ?? DateTime.now();
    int generated = 0;

    final dueRules = realm
        .query<RecurringTransactionModel>(
          'isPaused == false AND nextRunDate <= \$0',
          [currentTime],
        )
        .toList();

    if (dueRules.isEmpty) return 0;

    for (final rule in dueRules) {
      // Honour optional end date.
      if (rule.endDate != null && rule.endDate!.isBefore(currentTime)) {
        continue;
      }

      final txType = TransactionType.values.firstWhere(
        (e) => e.name == rule.type,
        orElse: () => TransactionType.cashExpense,
      );

      int catchUp = 0;
      while (rule.nextRunDate.isBefore(currentTime) &&
          catchUp < _maxCatchUpOccurrences) {
        if (rule.endDate != null &&
            rule.nextRunDate.isAfter(rule.endDate!)) {
          break;
        }

        final txn = TransactionModel(
          const Uuid().v4(),
          txType.name,
          rule.amount,
          rule.nextRunDate,
          personId: rule.personId,
          category: rule.category,
          note: rule.note ?? 'Recurring: ${rule.frequency}',
          currencyCode: rule.currencyCode,
          status: 'POSTED',
        );

        realm.write(() {
          realm.add(txn);
          rule.occurrencesGenerated += 1;
          rule.nextRunDate = _advance(rule.nextRunDate, rule.frequency);
          rule.updatedAt = DateTime.now();
        });
        generated++;
        catchUp++;
      }

      if (catchUp == _maxCatchUpOccurrences && kDebugMode) {
        debugPrint(
            'RecurringTransactionService: capped rule ${rule.id} at $_maxCatchUpOccurrences occurrences');
      }
    }

    return generated;
  }

  /// Compute the next occurrence date after [from] for the given [frequency].
  static DateTime _advance(DateTime from, String frequency) {
    final f = RecurringFrequency.values.firstWhere(
      (e) => e.name == frequency,
      orElse: () => RecurringFrequency.monthly,
    );
    switch (f) {
      case RecurringFrequency.daily:
        return from.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return from.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case RecurringFrequency.yearly:
        return DateTime(from.year + 1, from.month, from.day);
    }
  }

  /// Pause a rule (skip future occurrences until resumed).
  Future<void> pauseRule(String id) async {
    final realm = await _realmFuture;
    final rule = realm.find<RecurringTransactionModel>(id);
    if (rule != null) {
      realm.write(() {
        rule.isPaused = true;
        rule.updatedAt = DateTime.now();
      });
    }
  }

  /// Resume a paused rule. The next-run date is recomputed to "now" so the
  /// user is not flooded with catch-up transactions for the paused period.
  Future<void> resumeRule(String id) async {
    final realm = await _realmFuture;
    final rule = realm.find<RecurringTransactionModel>(id);
    if (rule != null) {
      realm.write(() {
        rule.isPaused = false;
        rule.nextRunDate = _advance(DateTime.now(), rule.frequency);
        rule.updatedAt = DateTime.now();
      });
    }
  }

  /// Create a new recurring rule.
  Future<RecurringTransactionModel> createRule({
    required TransactionType type,
    required double amount,
    required RecurringFrequency frequency,
    required DateTime startDate,
    String? personId,
    String? category,
    String? note,
    String? currencyCode,
    DateTime? endDate,
  }) async {
    final realm = await _realmFuture;
    final rule = RecurringTransactionModel(
      const Uuid().v4(),
      type.name,
      amount,
      frequency.name,
      startDate,
      startDate, // nextRunDate starts at startDate
      DateTime.now(),
      personId: personId,
      category: category,
      note: note,
      currencyCode: currencyCode,
      endDate: endDate,
    );
    realm.write(() => realm.add(rule));
    return rule;
  }

  /// Update an existing rule.
  Future<void> updateRule(
    String id, {
    double? amount,
    String? note,
    String? category,
    RecurringFrequency? frequency,
    DateTime? endDate,
    bool? isPaused,
  }) async {
    final realm = await _realmFuture;
    final rule = realm.find<RecurringTransactionModel>(id);
    if (rule == null) return;
    realm.write(() {
      if (amount != null) rule.amount = amount;
      if (note != null) rule.note = note;
      if (category != null) rule.category = category;
      if (frequency != null) rule.frequency = frequency.name;
      if (endDate != null) rule.endDate = endDate;
      if (isPaused != null) rule.isPaused = isPaused;
      rule.updatedAt = DateTime.now();
    });
  }

  /// Delete a rule permanently.
  Future<void> deleteRule(String id) async {
    final realm = await _realmFuture;
    final rule = realm.find<RecurringTransactionModel>(id);
    if (rule != null) {
      realm.write(() => realm.delete(rule));
    }
  }

  /// List all rules.
  Future<List<RecurringTransactionModel>> getAllRules() async {
    final realm = await _realmFuture;
    return realm
        .query<RecurringTransactionModel>('TRUEPREDICATE SORT(nextRunDate ASC)')
        .toList();
  }

  /// Watch rules for reactive UI.
  Stream<List<RecurringTransactionModel>> watchRules() async* {
    final realm = await _realmFuture;
    yield* realm
        .query<RecurringTransactionModel>('TRUEPREDICATE SORT(nextRunDate ASC)')
        .changes
        .map((c) => c.results.toList());
  }
}
