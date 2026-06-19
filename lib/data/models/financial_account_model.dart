import 'package:realm/realm.dart';

part 'financial_account_model.realm.dart';

@RealmModel()
class _FinancialAccountModel {
  @PrimaryKey()
  late int id;

  late String name; // e.g., "Mbok Account"
  @Indexed()
  late String providerId; // e.g., "MBOK", "SYBER", "CASH"
  late String accountType; // "BANK", "WALLET", "CASH"
  late double balance;
  late String currency;

  // API Integration Fields
  String? externalAccountId; // ID from the bank's system
  DateTime? lastSyncTime;
  String? status; // "ACTIVE", "ERROR", "NEEDS_REAUTH"
  String? colorHex;
}
