import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/notification_item_model.dart';
import 'package:aldeewan_mobile/data/models/product_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/data/models/stock_movement_model.dart';
import 'package:aldeewan_mobile/domain/repositories/inventory_repositories.dart';
import 'package:realm/realm.dart';

/// Implementation of [BudgetRepository] backed by [LocalDatabaseSource].
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._dataSource);
  final LocalDatabaseSource _dataSource;

  /// Exposed for legacy notifiers that still need raw Realm access
  /// (e.g. subscribing to TransactionModel changes for recompute triggers).
  LocalDatabaseSource get dataSource => _dataSource;

  @override
  Stream<List<BudgetModel>> watchBudgets() async* {
    final realm = await _dataSource.db;
    yield* realm.all<BudgetModel>().changes.map((c) => c.results.toList());
  }

  @override
  Stream<List<SavingsGoalModel>> watchGoals() async* {
    final realm = await _dataSource.db;
    yield* realm.all<SavingsGoalModel>().changes.map((c) => c.results.toList());
  }

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final realm = await _dataSource.db;
    return realm.all<BudgetModel>().toList();
  }

  @override
  Future<List<SavingsGoalModel>> getGoals() async {
    final realm = await _dataSource.db;
    return realm.all<SavingsGoalModel>().toList();
  }

  @override
  Future<void> upsertBudget(BudgetModel budget) async {
    final realm = await _dataSource.db;
    realm.write(() => realm.add(budget, update: true));
  }

  @override
  Future<void> deleteBudget(ObjectId id) async {
    final realm = await _dataSource.db;
    final item = realm.find<BudgetModel>(id);
    if (item != null) {
      realm.write(() => realm.delete(item));
    }
  }

  @override
  Future<void> upsertGoal(SavingsGoalModel goal) async {
    final realm = await _dataSource.db;
    realm.write(() => realm.add(goal, update: true));
  }

  @override
  Future<void> deleteGoal(ObjectId id) async {
    final realm = await _dataSource.db;
    final item = realm.find<SavingsGoalModel>(id);
    if (item != null) {
      realm.write(() => realm.delete(item));
    }
  }
}

/// Implementation of [CategoryRepository] backed by [LocalDatabaseSource].
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);
  final LocalDatabaseSource _dataSource;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final realm = await _dataSource.db;
    return realm.all<CategoryModel>().toList();
  }

  @override
  Stream<List<CategoryModel>> watchCategories() async* {
    final realm = await _dataSource.db;
    yield* realm.all<CategoryModel>().changes.map((c) => c.results.toList());
  }

  @override
  Future<void> upsertCategory(CategoryModel category) async {
    final realm = await _dataSource.db;
    realm.write(() => realm.add(category, update: true));
  }

  @override
  Future<void> deleteCategory(ObjectId id) async {
    final realm = await _dataSource.db;
    final item = realm.find<CategoryModel>(id);
    if (item != null) {
      realm.write(() => realm.delete(item));
    }
  }
}

/// Implementation of [AccountRepository] backed by [LocalDatabaseSource].
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._dataSource);
  final LocalDatabaseSource _dataSource;

  @override
  Future<List<FinancialAccountModel>> getAccounts() async {
    final realm = await _dataSource.db;
    return realm.all<FinancialAccountModel>().toList();
  }

  @override
  Stream<List<FinancialAccountModel>> watchAccounts() async* {
    final realm = await _dataSource.db;
    yield* realm
        .all<FinancialAccountModel>()
        .changes
        .map((c) => c.results.toList());
  }

  @override
  Future<void> upsertAccount(FinancialAccountModel account) async {
    final realm = await _dataSource.db;
    realm.write(() => realm.add(account, update: true));
  }

  @override
  Future<void> deleteAccount(int id) async {
    final realm = await _dataSource.db;
    final item = realm.find<FinancialAccountModel>(id);
    if (item != null) {
      realm.write(() => realm.delete(item));
    }
  }
}

/// Implementation of [NotificationRepository] backed by [LocalDatabaseSource].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dataSource);
  final LocalDatabaseSource _dataSource;

  @override
  Future<List<NotificationItemModel>> getNotifications() async {
    final realm = await _dataSource.db;
    return realm
        .query<NotificationItemModel>("TRUEPREDICATE SORT(date DESC)")
        .toList();
  }

  @override
  Stream<List<NotificationItemModel>> watchNotifications() async* {
    final realm = await _dataSource.db;
    yield* realm
        .query<NotificationItemModel>("TRUEPREDICATE SORT(date DESC)")
        .changes
        .map((c) => c.results.toList());
  }

  @override
  Future<void> addNotification(NotificationItemModel notification) async {
    final realm = await _dataSource.db;
    realm.write(() => realm.add(notification, update: true));
  }

  @override
  Future<void> markAsRead(String id) async {
    final realm = await _dataSource.db;
    final item = realm.find<NotificationItemModel>(id);
    if (item != null) {
      realm.write(() => item.isRead = true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final realm = await _dataSource.db;
    final unread =
        realm.query<NotificationItemModel>("isRead == false");
    realm.write(() {
      for (final n in unread) {
        n.isRead = true;
      }
    });
  }

  @override
  Future<void> deleteNotification(String id) async {
    final realm = await _dataSource.db;
    final item = realm.find<NotificationItemModel>(id);
    if (item != null) {
      realm.write(() => realm.delete(item));
    }
  }
}

/// Implementation of [InventoryRepository] backed by [LocalDatabaseSource].
class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._dataSource);
  final LocalDatabaseSource _dataSource;

  @override
  Stream<List<ProductModel>> watchProducts() =>
      _dataSource.watchProducts();

  @override
  Stream<List<StockMovementModel>> watchStockMovements() =>
      _dataSource.watchStockMovements();

  @override
  Future<List<ProductModel>> getProducts() => _dataSource.getProducts();

  @override
  Future<List<StockMovementModel>> getStockMovements() =>
      _dataSource.getStockMovements();

  @override
  Future<void> upsertProduct(ProductModel product) =>
      _dataSource.putProduct(product);

  @override
  Future<void> archiveProduct(String id) => _dataSource.archiveProduct(id);

  @override
  Future<void> deleteProduct(String id) => _dataSource.deleteProduct(id);

  @override
  Future<void> upsertStockMovement(StockMovementModel movement) =>
      _dataSource.putStockMovement(movement);

  @override
  Future<void> deleteStockMovement(String id) =>
      _dataSource.deleteStockMovement(id);

  @override
  Future<double> getQuantityOnHand(String productId) =>
      _dataSource.getQuantityOnHand(productId);
}
