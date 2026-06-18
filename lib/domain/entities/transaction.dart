enum TransactionType {
  // Person-related transactions
  saleOnCredit, // Customer owes you. (Increases receivable)
  paymentReceived, // Customer pays off debt. (Decreases receivable, increases cash)
  purchaseOnCredit, // You owe supplier. (Increases payable)
  paymentMade, // You pay off debt to supplier. (Decreases payable, decreases cash)
  
  debtGiven, // You lent money. (Increases receivable)
  debtTaken, // You borrowed money. (Increases payable)

  // Cash-only transactions
  cashSale, // Customer pays immediately. (Income)
  cashIncome, // Other income not from sales.
  cashExpense, // General expense.
}

class Transaction {
  final String id;
  final TransactionType type;
  final String? personId;
  final double amount;
  final DateTime date;
  final String? category;
  final String? note;
  final DateTime? dueDate;

  // New Fields for V1.2
  final String? externalId;
  final String? status;
  final int? accountId;

  // Goal tracking - links transaction to a savings goal
  final String? goalId;

  // V1.2.1: Old Debt / Opening Balance support
  // If true, this transaction does not affect the cash/bank balance.
  final bool isOpeningBalance;

  /// Currency code (ISO 4217) — inherited from the person at creation time.
  /// For cash-only transactions (no personId), falls back to the global app currency.
  /// Used so reports/dashboard can group balances by currency.
  final String? currencyCode;

  Transaction({
    required this.id,
    required this.type,
    this.personId,
    required this.amount,
    required this.date,
    this.category,
    this.note,
    this.dueDate,
    this.externalId,
    this.status,
    this.accountId,
    this.goalId,
    this.isOpeningBalance = false,
    this.currencyCode,
  });
}

