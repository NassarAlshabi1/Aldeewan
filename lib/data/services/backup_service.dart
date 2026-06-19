import 'dart:convert';

import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/notification_item_model.dart';
import 'package:aldeewan_mobile/data/models/person_model.dart';
import 'package:aldeewan_mobile/data/models/product_model.dart';
import 'package:aldeewan_mobile/data/models/recurring_transaction_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/stock_movement_model.dart';
import 'package:aldeewan_mobile/data/models/transaction_model.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';

enum RestoreStrategy {
  /// Wipe all local data and replace with the backup contents.
  replace,

  /// Safe-merge: insert only entities whose primary key does not already exist
  /// locally. Conflicting IDs are remapped to fresh UUIDs and all referencing
  /// rows (transactions, stock movements, etc.) are rewritten to follow.
  merge,
}

/// Thrown when a backup file cannot be parsed or decrypted.
class BackupFormatException implements Exception {
  final String message;
  const BackupFormatException(this.message);
  @override
  String toString() => message;
}

/// Thrown when a password is missing or wrong during restore.
class BackupPasswordException implements Exception {
  final String message;
  const BackupPasswordException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  final LocalDatabaseSource _dataSource;

  // Key derivation constants
  static const int _saltLength = 16;
  static const int _ivLength = 16;
  static const int _keyLength = 32;
  static const int _iterationCount = 1000;

  /// Current schema version this code knows how to read & write.
  /// Mirrors [LocalDatabaseSource.schemaVersion] (kept in sync manually).
  static const int currentSchemaVersion = 9;

  /// Current app version, stamped on every backup.
  /// Mirrors pubspec.yaml `version:` (kept in sync manually).
  static const String currentAppVersion = '2.2.0+5';

  BackupService(this._dataSource);

  /// Creates a full backup of the database, including inventory.
  /// If [password] is provided, the backup will be encrypted.
  /// Returns the JSON string (potentially encrypted).
  Future<String> createBackup({String? password}) async {
    final realm = await _dataSource.db;

    // 1. Gather all data — INCLUDING inventory (Product + StockMovement)
    // and recurring-transaction rules.
    final persons = realm.all<PersonModel>().toList();
    final transactions = realm.all<TransactionModel>().toList();
    final accounts = realm.all<FinancialAccountModel>().toList();
    final budgets = realm.all<BudgetModel>().toList();
    final goals = realm.all<SavingsGoalModel>().toList();
    final categories = realm.all<CategoryModel>().toList();
    final notifications = realm.all<NotificationItemModel>().toList();
    final products = realm.all<ProductModel>().toList();
    final stockMovements = realm.all<StockMovementModel>().toList();
    final recurring = realm.all<RecurringTransactionModel>().toList();

    // 2. Serialize to Map
    final data = {
      'schemaVersion': currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': currentAppVersion,
      'data': {
        'persons': persons.map(_serializePerson).toList(),
        'transactions': transactions.map(_serializeTransaction).toList(),
        'accounts': accounts.map(_serializeAccount).toList(),
        'budgets': budgets.map(_serializeBudget).toList(),
        'goals': goals.map(_serializeGoal).toList(),
        'categories': categories.map(_serializeCategory).toList(),
        'notifications': notifications.map(_serializeNotification).toList(),
        'products': products.map(_serializeProduct).toList(),
        'stockMovements': stockMovements.map(_serializeStockMovement).toList(),
        'recurringTransactions': recurring.map(_serializeRecurring).toList(),
      }
    };

    final jsonString = jsonEncode(data);

    // 3. Encrypt if password provided
    if (password != null && password.isNotEmpty) {
      return await compute(_encryptData, _EncryptionParams(jsonString, password));
    }

    return jsonString;
  }

  /// Restores data from a backup string.
  /// [password] is required if the backup is encrypted.
  Future<void> restoreBackup(
    String fileContent, {
    required RestoreStrategy strategy,
    String? password,
  }) async {
    Map<String, dynamic> data;

    // 1. Check if encrypted and decrypt
    try {
      final decodedState = jsonDecode(fileContent);
      if (decodedState is Map<String, dynamic> &&
          decodedState['isEncrypted'] == true) {
        if (password == null || password.isEmpty) {
          throw const BackupPasswordException(
              'Password required for encrypted backup');
        }
        String decryptedJson;
        try {
          decryptedJson = await compute(
              _decryptData, _DecryptionParams(decodedState, password));
        } catch (_) {
          throw const BackupPasswordException(
              'Wrong password or corrupted backup');
        }
        data = jsonDecode(decryptedJson) as Map<String, dynamic>;
      } else {
        data = decodedState as Map<String, dynamic>;
      }
    } on BackupPasswordException {
      rethrow;
    } on BackupFormatException {
      rethrow;
    } catch (e) {
      // Plain text or legacy unstructured input.
      if (fileContent.trim().startsWith('{')) {
        try {
          data = jsonDecode(fileContent) as Map<String, dynamic>;
        } catch (_) {
          throw const BackupFormatException('Invalid backup format');
        }
      } else {
        throw const BackupFormatException('Invalid backup format');
      }
    }

    // 2. Resolve payload (supports legacy v1 layout without 'data' wrapper).
    Map<String, dynamic> payload = {};
    if (data.containsKey('data') && data['data'] is Map) {
      payload = data['data'] as Map<String, dynamic>;
    } else if (data.containsKey('persons') && data.containsKey('transactions')) {
      // Legacy v1 format directly in root.
      payload = {
        'persons': data['persons'],
        'transactions': data['transactions'],
      };
    } else {
      payload = (data['data'] as Map?)?.cast<String, dynamic>() ?? {};
    }

    // 3. Schema migration — backfill missing fields on legacy backups.
    payload = _migratePayload(payload,
        fromVersion: (data['schemaVersion'] as num?)?.toInt() ?? 1);

    final realm = await _dataSource.db;

    if (strategy == RestoreStrategy.replace) {
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
        realm.deleteAll<RecurringTransactionModel>();
        _insertData(realm, payload, merge: false);
      });
    } else {
      // Merge Strategy — true Safe-Add with ID remapping.
      realm.write(() {
        _insertData(realm, payload, merge: true);
      });
    }
  }

  /// Apply field-level migrations so older backups load cleanly on the
  /// current schema. Currently handles v1..v6 → v7 (adds currencyCode,
  /// ensures inventory collections exist).
  Map<String, dynamic> _migratePayload(
    Map<String, dynamic> payload, {
    required int fromVersion,
  }) {
    final migrated = Map<String, dynamic>.from(payload);

    // v7 added products + stockMovements collections — older backups
    // simply don't have them, so default to empty lists.
    migrated.putIfAbsent('products', () => <Map<String, dynamic>>[]);
    migrated.putIfAbsent('stockMovements', () => <Map<String, dynamic>>[]);
    // v9 added recurringTransactions collection.
    migrated.putIfAbsent(
        'recurringTransactions', () => <Map<String, dynamic>>[]);

    // v7 added currencyCode to Person & Transaction — leave null if absent,
    // the deserialisers already tolerate null currencyCode.
    if (fromVersion < 7) {
      if (kDebugMode) {
        debugPrint(
            'BackupService: migrating backup from v$fromVersion to v$currentSchemaVersion');
      }
    }
    return migrated;
  }

  void _insertData(Realm realm, Map<String, dynamic> data,
      {required bool merge}) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) mapper) {
      final list = data[key];
      if (list is List) {
        return list
            .map((e) => mapper(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    final persons = parseList('persons', _deserializePerson);
    final transactions = parseList('transactions', _deserializeTransaction);
    final accounts = parseList('accounts', _deserializeAccount);
    final budgets = parseList('budgets', _deserializeBudget);
    final goals = parseList('goals', _deserializeGoal);
    final categories = parseList('categories', _deserializeCategory);
    final notifications = parseList('notifications', _deserializeNotification);
    final products = parseList('products', _deserializeProduct);
    final stockMovements = parseList('stockMovements', _deserializeStockMovement);
    final recurring = parseList('recurringTransactions', _deserializeRecurring);

    if (merge) {
      // True Safe-Add: for every entity whose PK already exists locally,
      // allocate a fresh UUID and rewrite any referencing rows to follow.
      final personIdMap = <String, String>{};
      final productIdMap = <String, String>{};

      for (final p in persons) {
        if (realm.find<PersonModel>(p.id) != null) {
          final newId = const Uuid().v4();
          personIdMap[p.id] = newId;
          p.id = newId;
        }
      }
      for (final p in products) {
        if (realm.find<ProductModel>(p.id) != null) {
          final newId = const Uuid().v4();
          productIdMap[p.id] = newId;
          p.id = newId;
        }
      }
      // Rewrite transactions referencing remapped person IDs.
      for (final t in transactions) {
        final remapped = personIdMap[t.personId];
        if (remapped != null) {
          t.personId = remapped;
        }
      }
      // Rewrite stock movements referencing remapped products & persons.
      for (final m in stockMovements) {
        final remappedProduct = productIdMap[m.productId];
        if (remappedProduct != null) m.productId = remappedProduct;
        final remappedPerson = personIdMap[m.personId];
        if (remappedPerson != null) m.personId = remappedPerson;
      }
      // Goals & budgets reference transactions via goalId/category — those
      // are not PKs, so no remap needed.
    }

    // Insert/update order respects referential dependencies.
    for (final i in persons) {
      realm.add(i, update: true);
    }
    for (final i in accounts) {
      realm.add(i, update: true);
    }
    for (final i in categories) {
      realm.add(i, update: true);
    }
    for (final i in budgets) {
      realm.add(i, update: true);
    }
    for (final i in goals) {
      realm.add(i, update: true);
    }
    for (final i in products) {
      realm.add(i, update: true);
    }
    // Transactions & stock movements last (reference persons & products).
    for (final i in transactions) {
      realm.add(i, update: true);
    }
    for (final i in stockMovements) {
      realm.add(i, update: true);
    }
    for (final i in recurring) {
      realm.add(i, update: true);
    }
    for (final i in notifications) {
      realm.add(i, update: true);
    }
  }

  // --- Serialization Helpers (To Map) ---
  Map<String, dynamic> _serializePerson(PersonModel m) => {
        'uuid': m.id,
        'name': m.name,
        'role': m.role,
        'phone': m.phone,
        'createdAt': m.createdAt.toIso8601String(),
        'isArchived': m.isArchived,
        'currencyCode': m.currencyCode,
      };

  Map<String, dynamic> _serializeTransaction(TransactionModel m) => {
        'uuid': m.uuid,
        'type': m.type,
        'personId': m.personId,
        'amount': m.amount,
        'date': m.date.toIso8601String(),
        'category': m.category,
        'note': m.note,
        'dueDate': m.dueDate?.toIso8601String(),
        'externalId': m.externalId,
        'status': m.status,
        'accountId': m.accountId,
        'goalId': m.goalId,
        'isOpeningBalance': m.isOpeningBalance,
        'currencyCode': m.currencyCode,
      };

  Map<String, dynamic> _serializeAccount(FinancialAccountModel m) => {
        'uuid': m.id.toString(),
        'name': m.name,
        'type': m.accountType,
        'providerId': m.providerId,
        'balance': m.balance,
        'currency': m.currency,
      };

  Map<String, dynamic> _serializeBudget(BudgetModel m) => {
        'uuid': m.id.toString(),
        'category': m.category,
        'amount': m.amountLimit,
        'currentSpent': m.currentSpent,
        'startDate': m.startDate.toIso8601String(),
        'endDate': m.endDate.toIso8601String(),
        'isRecurring': m.isRecurring,
      };

  Map<String, dynamic> _serializeGoal(SavingsGoalModel m) => {
        'uuid': m.id.toString(),
        'name': m.name,
        'targetAmount': m.targetAmount,
        'currentAmount': m.currentSaved,
        'deadline': m.deadline?.toIso8601String(),
        'icon': m.icon,
        'color': m.colorHex,
      };

  Map<String, dynamic> _serializeCategory(CategoryModel m) => {
        'uuid': m.id.toString(),
        'name': m.name,
        'type': m.type,
        'icon': m.iconName,
        'color': m.colorHex,
        'isCustom': m.isCustom,
      };

  Map<String, dynamic> _serializeNotification(NotificationItemModel m) => {
        'uuid': m.id,
        'title': m.title,
        'body': m.body,
        'date': m.date.toIso8601String(),
        'isRead': m.isRead,
        'type': m.type,
      };

  Map<String, dynamic> _serializeProduct(ProductModel m) => {
        'uuid': m.id,
        'name': m.name,
        'sku': m.sku,
        'category': m.category,
        'unit': m.unit,
        'costPrice': m.costPrice,
        'salePrice': m.salePrice,
        'currencyCode': m.currencyCode,
        'lowStockThreshold': m.lowStockThreshold,
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt.toIso8601String(),
        'isArchived': m.isArchived,
      };

  Map<String, dynamic> _serializeStockMovement(StockMovementModel m) => {
        'uuid': m.id,
        'productId': m.productId,
        'type': m.type,
        'quantity': m.quantity,
        'unitCost': m.unitCost,
        'personId': m.personId,
        'transactionId': m.transactionId,
        'date': m.date.toIso8601String(),
        'note': m.note,
        'createdAt': m.createdAt.toIso8601String(),
      };

  // --- Deserialization Helpers (From Map) ---
  PersonModel _deserializePerson(Map<String, dynamic> m) => PersonModel(
        m['uuid']?.toString() ?? const Uuid().v4(),
        m['role'] ?? 'customer',
        m['name'] ?? 'Unknown',
        DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
        isArchived: m['isArchived'] ?? false,
        phone: m['phone']?.toString(),
        currencyCode: m['currencyCode']?.toString(),
      );

  TransactionModel _deserializeTransaction(Map<String, dynamic> m) =>
      TransactionModel(
        m['uuid']?.toString() ?? const Uuid().v4(),
        m['type'] ?? 'income',
        (m['amount'] as num?)?.toDouble() ?? 0.0,
        DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
        personId: m['personId']?.toString(),
        category: m['category']?.toString(),
        note: m['note']?.toString(),
        dueDate: m['dueDate'] != null ? DateTime.tryParse(m['dueDate']) : null,
        externalId: m['externalId']?.toString(),
        status: m['status']?.toString() ?? 'pending',
        accountId: m['accountId'] is int
            ? m['accountId'] as int
            : int.tryParse(m['accountId']?.toString() ?? ''),
        goalId: m['goalId']?.toString(),
        isOpeningBalance: m['isOpeningBalance'] ?? false,
        currencyCode: m['currencyCode']?.toString(),
      );

  FinancialAccountModel _deserializeAccount(Map<String, dynamic> m) {
    // Robust PK resolution: prefer backup uuid, fall back to a *fresh*
    // monotonic-ish timestamp + random suffix to avoid collisions when
    // multiple accounts have missing UUIDs.
    final uuidStr = m['uuid']?.toString();
    int pk;
    if (uuidStr != null && uuidStr.isNotEmpty) {
      pk = int.tryParse(uuidStr) ?? _safeAccountPk();
    } else {
      pk = _safeAccountPk();
    }
    return FinancialAccountModel(
      pk,
      m['name']?.toString() ?? 'Account',
      m['providerId']?.toString() ?? 'CASH',
      m['type']?.toString() ?? 'CASH',
      (m['balance'] as num?)?.toDouble() ?? 0.0,
      m['currency']?.toString() ?? 'SDG',
    );
  }

  /// Generate an account PK that won't collide with another concurrent
  /// missing-UUID restore: combines the millisecond timestamp with a
  /// pseudo-random suffix in the lower 4 digits.
  static int _safeAccountPk() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final suffix = DateTime.now().microsecond % 10000;
    return now * 10000 + suffix;
  }

  BudgetModel _deserializeBudget(Map<String, dynamic> m) => BudgetModel(
        ObjectId.fromHexString(m['uuid']?.toString() ?? ObjectId().hexString),
        m['category']?.toString() ?? 'General',
        (m['amount'] as num?)?.toDouble() ?? 0.0,
        (m['currentSpent'] as num?)?.toDouble() ?? 0.0,
        DateTime.tryParse(m['startDate'] ?? '') ?? DateTime.now(),
        DateTime.tryParse(m['endDate'] ?? '') ?? DateTime.now(),
        isRecurring: m['isRecurring'] ?? true,
      );

  SavingsGoalModel _deserializeGoal(Map<String, dynamic> m) => SavingsGoalModel(
        ObjectId.fromHexString(m['uuid']?.toString() ?? ObjectId().hexString),
        m['name']?.toString() ?? 'Goal',
        (m['targetAmount'] as num?)?.toDouble() ?? 0.0,
        (m['currentAmount'] as num?)?.toDouble() ?? 0.0,
        deadline: m['deadline'] != null ? DateTime.tryParse(m['deadline']) : null,
        icon: m['icon']?.toString() ?? 'target',
        colorHex: m['color']?.toString() ?? '0xFF000000',
      );

  CategoryModel _deserializeCategory(Map<String, dynamic> m) => CategoryModel(
        ObjectId.fromHexString(m['uuid']?.toString() ?? ObjectId().hexString),
        m['name']?.toString() ?? 'Category',
        m['icon']?.toString() ?? 'tag',
        m['color']?.toString() ?? '0xFF000000',
        m['type']?.toString() ?? 'expense',
        m['isCustom'] ?? false,
      );

  NotificationItemModel _deserializeNotification(Map<String, dynamic> m) =>
      NotificationItemModel(
        m['uuid']?.toString() ?? const Uuid().v4(),
        m['title']?.toString() ?? '',
        m['body']?.toString() ?? '',
        DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
        m['isRead'] ?? false,
        m['type']?.toString() ?? 'info',
      );

  ProductModel _deserializeProduct(Map<String, dynamic> m) => ProductModel(
        m['uuid']?.toString() ?? const Uuid().v4(),
        m['name']?.toString() ?? 'Product',
        DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
        DateTime.tryParse(m['updatedAt'] ?? '') ?? DateTime.now(),
        isArchived: m['isArchived'] ?? false,
        sku: m['sku']?.toString(),
        category: m['category']?.toString(),
        unit: m['unit']?.toString(),
        costPrice: (m['costPrice'] as num?)?.toDouble(),
        salePrice: (m['salePrice'] as num?)?.toDouble(),
        currencyCode: m['currencyCode']?.toString(),
        lowStockThreshold: (m['lowStockThreshold'] as num?)?.toDouble(),
      );

  StockMovementModel _deserializeStockMovement(Map<String, dynamic> m) =>
      StockMovementModel(
        m['uuid']?.toString() ?? const Uuid().v4(),
        m['productId']?.toString() ?? '',
        m['type']?.toString() ?? 'inbound',
        (m['quantity'] as num?)?.toDouble() ?? 0.0,
        DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
        DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
        unitCost: (m['unitCost'] as num?)?.toDouble(),
        personId: m['personId']?.toString(),
        transactionId: m['transactionId']?.toString(),
        note: m['note']?.toString(),
      );

  Map<String, dynamic> _serializeRecurring(RecurringTransactionModel m) => {
        'uuid': m.id,
        'type': m.type,
        'amount': m.amount,
        'personId': m.personId,
        'category': m.category,
        'note': m.note,
        'currencyCode': m.currencyCode,
        'frequency': m.frequency,
        'startDate': m.startDate.toIso8601String(),
        'endDate': m.endDate?.toIso8601String(),
        'nextRunDate': m.nextRunDate.toIso8601String(),
        'occurrencesGenerated': m.occurrencesGenerated,
        'isPaused': m.isPaused,
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt?.toIso8601String(),
      };

  RecurringTransactionModel _deserializeRecurring(Map<String, dynamic> m) =>
      RecurringTransactionModel(
        m['uuid']?.toString() ?? const Uuid().v4(),
        m['type']?.toString() ?? 'cashExpense',
        (m['amount'] as num?)?.toDouble() ?? 0.0,
        m['frequency']?.toString() ?? 'monthly',
        DateTime.tryParse(m['startDate'] ?? '') ?? DateTime.now(),
        DateTime.tryParse(m['nextRunDate'] ?? '') ?? DateTime.now(),
        DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
        personId: m['personId']?.toString(),
        category: m['category']?.toString(),
        note: m['note']?.toString(),
        currencyCode: m['currencyCode']?.toString(),
        endDate: m['endDate'] != null ? DateTime.tryParse(m['endDate']) : null,
        occurrencesGenerated: (m['occurrencesGenerated'] as num?)?.toInt() ?? 0,
        isPaused: m['isPaused'] ?? false,
        updatedAt: m['updatedAt'] != null ? DateTime.tryParse(m['updatedAt']) : null,
      );

  // --- Encryption Logic (Isolate) ---
  static String _encryptData(_EncryptionParams params) {
    final salt = enc.IV.fromSecureRandom(_saltLength);
    final key = enc.Key.fromUtf8(params.password).stretch(
      _keyLength,
      salt: salt.bytes,
      iterationCount: _iterationCount,
    );
    final iv = enc.IV.fromSecureRandom(_ivLength);
    final encrypter = enc.Encrypter(enc.AES(key));

    final encrypted = encrypter.encrypt(params.jsonString, iv: iv);

    final output = {
      'isEncrypted': true,
      'salt': salt.base64,
      'iv': iv.base64,
      'data': encrypted.base64,
    };
    return jsonEncode(output);
  }

  static String _decryptData(_DecryptionParams params) {
    final data = params.encryptedData;
    final salt = enc.IV.fromBase64(data['salt']);
    final iv = enc.IV.fromBase64(data['iv']);
    final encrypted = enc.Encrypted.fromBase64(data['data']);

    final key = enc.Key.fromUtf8(params.password).stretch(
      _keyLength,
      salt: salt.bytes,
      iterationCount: _iterationCount,
    );
    final encrypter = enc.Encrypter(enc.AES(key));

    return encrypter.decrypt(encrypted, iv: iv);
  }
}

class _EncryptionParams {
  final String jsonString;
  final String password;
  _EncryptionParams(this.jsonString, this.password);
}

class _DecryptionParams {
  final Map<String, dynamic> encryptedData;
  final String password;
  _DecryptionParams(this.encryptedData, this.password);
}
