import 'package:aldeewan_mobile/data/models/transaction_model.dart';

abstract class BankProviderInterface {
  /// Stable identifier persisted in `FinancialAccountModel.providerId`
  /// (e.g. "MBOK", "MOCK_BANK").
  String get providerId;

  /// Human-readable provider name shown in the UI. Implementations should
  /// return a localised-friendly constant (the UI may further localise).
  String get displayName;

  /// Authenticate with the bank API.
  Future<bool> authenticate(String username, String password);

  /// Get current balance.
  Future<double> getBalance(String accountId);

  /// Fetch transactions since a specific date.
  Future<List<TransactionModel>> fetchTransactions(String accountId, DateTime since);

  /// Refresh the access token if needed.
  Future<void> refreshToken();
}
