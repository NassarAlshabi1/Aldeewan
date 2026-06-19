import 'package:realm/realm.dart';

part 'recurring_transaction_model.realm.dart';

/// Frequency at which a recurring transaction fires.
enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

/// A standing instruction that generates a [TransactionModel] automatically
/// on a fixed schedule (e.g. monthly rent, weekly salary, daily coffee budget).
///
/// The scheduler (see `RecurringTransactionService`) runs on app start and
/// whenever the foregrounded app's lifecycle resumes. It compares
/// [nextRunDate] to `DateTime.now()` and creates the due transaction(s).
@RealmModel()
class _RecurringTransactionModel {
  @PrimaryKey()
  late String id;

  /// Mirror of [TransactionModel.type] — the type of transaction to create.
  late String type;

  late double amount;
  String? personId;
  String? category;
  String? note;
  String? currencyCode;

  /// ISO 4217 currency code inherited from person or app default.

  /// How often the transaction should be created.
  late String frequency; // RecurringFrequency.name

  /// When the recurring rule starts. The first occurrence fires on this date.
  late DateTime startDate;

  /// Optional end date. If null, the rule runs indefinitely.
  DateTime? endDate;

  /// When the next occurrence should fire. Computed by the scheduler after
  /// each successful generation. Set to [startDate] initially.
  late DateTime nextRunDate;

  /// How many times this rule has actually fired. Incremented by the
  /// scheduler each time a transaction is created.
  late int occurrencesGenerated = 0;

  /// Whether the rule is paused (skipped by the scheduler) without being
  /// deleted. Useful for seasonal subscriptions.
  late bool isPaused = false;

  late DateTime createdAt;
  DateTime? updatedAt;
}
