import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/data/models/person_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/data/models/notification_item_model.dart';
import 'package:aldeewan_mobile/data/models/product_model.dart';
import 'package:aldeewan_mobile/data/models/stock_movement_model.dart';
import 'package:aldeewan_mobile/data/models/recurring_transaction_model.dart';

class LocalDatabaseSource {
  late Future<Realm> db;
  final _storage = const FlutterSecureStorage();

  LocalDatabaseSource() {
    db = _initDb();
  }

  Future<Realm> _initDb() async {
    final key = await _getEncryptionKey();

    final config = Configuration.local(
      [
        PersonModel.schema,
        TransactionModel.schema,
        FinancialAccountModel.schema,
        BudgetModel.schema,
        SavingsGoalModel.schema,
        CategoryModel.schema,
        NotificationItemModel.schema,
        ProductModel.schema,
        StockMovementModel.schema,
        RecurringTransactionModel.schema,
      ],
      encryptionKey: key,
      schemaVersion: 9, // v9: Added RecurringTransactionModel for the new recurring-transactions feature.
      migrationCallback: (migration, oldSchemaVersion) {
        const targetVersion = 9;
        if (kDebugMode) {
          debugPrint('🔄 Realm migration: v$oldSchemaVersion -> v$targetVersion');
        }

        if (oldSchemaVersion < 2) {
          if (kDebugMode) debugPrint('  📦 Migrating v1 -> v2');
        }
        if (oldSchemaVersion < 3) {
          if (kDebugMode) debugPrint('  📦 Migrating v2 -> v3: Added budgets and goals');
        }
        if (oldSchemaVersion < 4) {
          if (kDebugMode) debugPrint('  📦 Migrating v3 -> v4: Added goalId to transactions');
        }
        if (oldSchemaVersion < 5) {
          if (kDebugMode) debugPrint('  📦 Migrating v4 -> v5: Added isArchived to Person');
        }
        if (oldSchemaVersion < 6) {
          if (kDebugMode) debugPrint('  📦 Migrating v5 -> v6: Added isOpeningBalance to Transaction');
        }
        if (oldSchemaVersion < 7) {
          if (kDebugMode) debugPrint('  📦 Migrating v6 -> v7: Added currencyCode to Person & Transaction, Product & StockMovement collections');
        }
        if (oldSchemaVersion < 8) {
          if (kDebugMode) {
            debugPrint('  📦 Migrating v7 -> v8: Backfill currencyCode on legacy transactions from their person');
          }
          // Realm's MigrationRealm API does not expose typed query<T>() on
          // the old realm — backfilling must be done lazily at read time
          // via the CurrencyAggregatesUseCase fallback to the global
          // default currency when currencyCode is null. This keeps the
          // migration cheap and crash-free.
        }
        if (oldSchemaVersion < 9) {
          if (kDebugMode) {
            debugPrint('  📦 Migrating v8 -> v9: Added RecurringTransactionModel (new collection, no data migration)');
          }
        }

        if (kDebugMode) debugPrint('✅ Migration completed successfully');
      },
    );

    return Realm(config);
  }

  Future<List<int>> _getEncryptionKey() async {
    // 1. Check Secure Storage first (Runtime/Previous key)
    String? keyString = await _storage.read(key: 'realm_db_key');
    
    if (keyString != null) {
      try {
        return base64Url.decode(keyString);
      } catch (_) {
        // failed to decode, ignore and re-generate/read from env
      }
    }

    // 2. Check .env (Pre-provisioned key)
    final envKey = dotenv.env['REALM_ENCRYPTION_KEY'];
    List<int> key;

    if (envKey != null && envKey.length == 128) { // 64 bytes hex = 128 chars
       try {
         // Hex decode
         key = List<int>.generate(64, (i) => int.parse(envKey.substring(i * 2, i * 2 + 2), radix: 16));
         // Persist normalized base64 for consistency with reading logic above
         await _storage.write(key: 'realm_db_key', value: base64Url.encode(key));
         return key;
       } catch (e) {
         // Invalid hex in env, fallthrough to random
       }
    }

    // 3. Fallback: Generate Random Key
    key = List<int>.generate(64, (i) => Random.secure().nextInt(256));
    await _storage.write(key: 'realm_db_key', value: base64Url.encode(key));
    return key;
  }

  // --- Person Operations ---
  Stream<List<PersonModel>> watchPeople() async* {
    final realm = await db;
    yield* realm.all<PersonModel>().changes.map((results) => results.results.toList());
  }

  Future<List<PersonModel>> getPeople() async {
    final realm = await db;
    return realm.all<PersonModel>().toList();
  }

  /// Retrieves a single person by their unique identifier.
  ///
  /// - [personId]: The unique ID of the person to retrieve.
  /// - Returns: The [PersonModel] if found, or `null` if not found.
  Future<PersonModel?> getPerson(String personId) async {
    final realm = await db;
    return realm.find<PersonModel>(personId);
  }

  Future<void> putPerson(PersonModel person) async {
    final realm = await db;
    realm.write(() {
      realm.add(person, update: true);
    });
  }

  /// Archives a person (soft delete) instead of permanently removing them.
  ///
  /// - [personId]: The unique ID of the person to archive.
  Future<void> archivePerson(String personId) async {
    final realm = await db;
    final person = realm.find<PersonModel>(personId);
    if (person != null) {
      realm.write(() {
        person.isArchived = true;
      });
    }
  }

  /// Permanently deletes a person from the database.
  ///
  /// - [personId]: The unique ID of the person to delete.
  /// - Note: This does NOT delete associated transactions. Use [deletePersonWithTransactions] for that.
  Future<void> deletePerson(String personId) async {
    final realm = await db;
    final person = realm.find<PersonModel>(personId);
    if (person != null) {
      realm.write(() {
        realm.delete(person);
      });
    }
  }

  /// Permanently deletes a person AND all their associated transactions.
  ///
  /// - [personId]: The unique ID of the person to delete.
  /// - Warning: This is a destructive operation and cannot be undone.
  Future<void> deletePersonWithTransactions(String personId) async {
    final realm = await db;
    realm.write(() {
      // Delete all transactions for this person first
      final transactions = realm.query<TransactionModel>("personId == \$0", [personId]);
      realm.deleteMany(transactions);
      
      // Then delete the person
      final person = realm.find<PersonModel>(personId);
      if (person != null) {
        realm.delete(person);
      }
    });
  }

  Future<int> getTransactionCountByPerson(String personId) async {
    final realm = await db;
    return realm.query<TransactionModel>("personId == \$0", [personId]).length;
  }

  // --- Transaction Operations ---
  Stream<List<TransactionModel>> watchTransactions() async* {
    final realm = await db;
    yield* realm.query<TransactionModel>("TRUEPREDICATE SORT(date DESC)").changes.map((results) => results.results.toList());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final realm = await db;
    // Sort by date desc. Realm query syntax: "TRUEPREDICATE SORT(date DESC)"
    return realm.query<TransactionModel>("TRUEPREDICATE SORT(date DESC)").toList();
  }

  Future<List<TransactionModel>> getTransactionsByPerson(String personId) async {
    final realm = await db;
    return realm.query<TransactionModel>("personId == \$0 SORT(date DESC)", [personId]).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final realm = await db;
    return realm.query<TransactionModel>("date >= \$0 AND date <= \$1 SORT(date DESC)", [start, end]).toList();
  }

  Future<void> putTransaction(TransactionModel transaction) async {
    final realm = await db;
    realm.write(() {
      realm.add(transaction, update: true);
    });
  }

  /// Permanently deletes a transaction from the database.
  ///
  /// - [transactionId]: The unique ID of the transaction to delete.
  Future<void> deleteTransaction(String transactionId) async {
    final realm = await db;
    final transaction = realm.find<TransactionModel>(transactionId);
    if (transaction != null) {
      realm.write(() {
        realm.delete(transaction);
      });
    }
  }
  
  // --- Backup/Restore ---
  Future<void> clearAll() async {
      final realm = await db;
      realm.write(() {
          realm.deleteAll<PersonModel>();
          realm.deleteAll<TransactionModel>();
          realm.deleteAll<FinancialAccountModel>();
          realm.deleteAll<BudgetModel>();
          realm.deleteAll<SavingsGoalModel>();
          realm.deleteAll<CategoryModel>();
          realm.deleteAll<NotificationItemModel>();
          realm.deleteAll<ProductModel>();
          realm.deleteAll<StockMovementModel>();
      });
  }

  // ============================================================
  // Product Operations (Inventory System)
  // ============================================================

  Stream<List<ProductModel>> watchProducts() async* {
    final realm = await db;
    yield* realm
        .query<ProductModel>("TRUEPREDICATE SORT(name ASC)")
        .changes
        .map((results) => results.results.toList());
  }

  Future<List<ProductModel>> getProducts() async {
    final realm = await db;
    return realm.query<ProductModel>("TRUEPREDICATE SORT(name ASC)").toList();
  }

  Future<ProductModel?> getProduct(String productId) async {
    final realm = await db;
    return realm.find<ProductModel>(productId);
  }

  Future<void> putProduct(ProductModel product) async {
    final realm = await db;
    realm.write(() {
      realm.add(product, update: true);
    });
  }

  Future<void> archiveProduct(String productId) async {
    final realm = await db;
    final product = realm.find<ProductModel>(productId);
    if (product != null) {
      realm.write(() {
        product.isArchived = true;
        product.updatedAt = DateTime.now();
      });
    }
  }

  Future<void> deleteProduct(String productId) async {
    final realm = await db;
    realm.write(() {
      // Delete all stock movements for this product first
      final movements = realm.query<StockMovementModel>(
        "productId == \$0",
        [productId],
      );
      realm.deleteMany(movements);

      // Then delete the product
      final product = realm.find<ProductModel>(productId);
      if (product != null) {
        realm.delete(product);
      }
    });
  }

  // ============================================================
  // Stock Movement Operations (Inventory System)
  // ============================================================

  Stream<List<StockMovementModel>> watchStockMovements() async* {
    final realm = await db;
    yield* realm
        .query<StockMovementModel>("TRUEPREDICATE SORT(date DESC)")
        .changes
        .map((results) => results.results.toList());
  }

  /// Returns ALL stock movements (sorted by date desc). Used by the
  /// InventoryProvider to pre-aggregate quantities on hand in a single pass.
  Future<List<StockMovementModel>> getStockMovements() async {
    final realm = await db;
    return realm
        .query<StockMovementModel>("TRUEPREDICATE SORT(date DESC)")
        .toList();
  }

  Future<List<StockMovementModel>> getStockMovementsByProduct(
    String productId,
  ) async {
    final realm = await db;
    return realm
        .query<StockMovementModel>(
          "productId == \$0 SORT(date DESC)",
          [productId],
        )
        .toList();
  }

  Future<List<StockMovementModel>> getStockMovementsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final realm = await db;
    return realm
        .query<StockMovementModel>(
          "date >= \$0 AND date <= \$1 SORT(date DESC)",
          [start, end],
        )
        .toList();
  }

  Future<void> putStockMovement(StockMovementModel movement) async {
    final realm = await db;
    realm.write(() {
      realm.add(movement, update: true);
    });
  }

  Future<void> deleteStockMovement(String movementId) async {
    final realm = await db;
    final movement = realm.find<StockMovementModel>(movementId);
    if (movement != null) {
      realm.write(() {
        realm.delete(movement);
      });
    }
  }

  /// Computes the current quantity on hand for a product by summing all
  /// movements (inbound positive, outbound negative).
  Future<double> getQuantityOnHand(String productId) async {
    final realm = await db;
    final movements = realm
        .query<StockMovementModel>("productId == \$0", [productId])
        .toList();
    double sum = 0;
    for (final m in movements) {
      // Local string compare avoids importing the enum (which would
      // create a circular dependency with the entity layer).
      final isInbound = m.type == 'inbound' || m.type == 'adjustmentIn';
      sum += isInbound ? m.quantity : -m.quantity;
    }
    return sum;
  }
}
