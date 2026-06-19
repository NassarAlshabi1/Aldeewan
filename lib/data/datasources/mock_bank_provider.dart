import 'package:aldeewan_mobile/data/datasources/bank_provider_interface.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockBankProvider implements BankProviderInterface {
  @override
  String get providerId => 'MOCK_BANK';

  @override
  String get displayName => 'Mock Bank (Demo)';

  @override
  Future<bool> authenticate(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    // Mock authentication logic
    final mockUser = dotenv.env['MOCK_USER'] ?? 'user';
    final mockPass = dotenv.env['MOCK_PASSWORD'] ?? 'password';
    return username == mockUser && password == mockPass;
  }

  @override
  Future<void> refreshToken() async {
    // Mock refresh token logic
    await Future.delayed(const Duration(seconds: 1));
  }


  @override
  Future<double> getBalance(String accountId) async {
    await Future.delayed(const Duration(seconds: 1));
    return 150000.0; // Mock balance: 150,000 SDG
  }

  @override
  Future<List<TransactionModel>> fetchTransactions(String accountId, DateTime since) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate some mock transactions
    return [
      TransactionModel(
        const Uuid().v4(),
        TransactionType.paymentReceived.name,
        5000.0,
        DateTime.now().subtract(const Duration(days: 1)),
        category: 'Salary',
        note: 'Monthly Salary',
        externalId: 'MOCK_TXN_001',
        status: 'POSTED',
        accountId: int.tryParse(accountId),
      ),
      TransactionModel(
        const Uuid().v4(),
        TransactionType.cashExpense.name,
        2500.0,
        DateTime.now().subtract(const Duration(days: 2)),
        category: 'Groceries',
        note: 'Supermarket',
        externalId: 'MOCK_TXN_002',
        status: 'POSTED',
        accountId: int.tryParse(accountId),
      ),
    ];
  }
}
