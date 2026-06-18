import 'package:realm/realm.dart' hide Transaction;
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

part 'transaction_model.realm.dart';

@RealmModel()
class _TransactionModel {
  @PrimaryKey()
  late String uuid;

  late String type; // Enum as String

  @Indexed()
  String? personId;

  late double amount;
  late DateTime date;
  String? category;
  String? note;
  DateTime? dueDate;

  @Indexed()
  String? externalId;
  String? status;
  int? accountId;

  @Indexed()
  String? goalId; // Links transaction to a savings goal

  bool isOpeningBalance = false; // Default to false

  /// Currency code (ISO 4217). Inherited from the person at creation time.
  /// Null = use global app currency (backward compatibility with old data).
  @Indexed()
  String? currencyCode;
}

extension TransactionModelMapper on TransactionModel {
  Transaction toEntity() {
    return Transaction(
      id: uuid,
      type: TransactionType.values.firstWhere((e) => e.name == type, orElse: () => TransactionType.cashExpense),
      personId: personId,
      amount: amount,
      date: date,
      category: category,
      note: note,
      dueDate: dueDate,
      externalId: externalId,
      status: status,
      accountId: accountId,
      goalId: goalId,
      isOpeningBalance: isOpeningBalance,
      currencyCode: currencyCode,
    );
  }

  static TransactionModel fromEntity(Transaction transaction) {
    return TransactionModel(
      transaction.id,
      transaction.type.name,
      transaction.amount,
      transaction.date,
      personId: transaction.personId,
      category: transaction.category,
      note: transaction.note,
      dueDate: transaction.dueDate,
      externalId: transaction.externalId,
      status: transaction.status,
      accountId: transaction.accountId,
      goalId: transaction.goalId,
      isOpeningBalance: transaction.isOpeningBalance,
      currencyCode: transaction.currencyCode,
    );
  }
}

