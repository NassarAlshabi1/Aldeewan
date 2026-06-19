import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/data/models/financial_account_model.dart';
import 'package:aldeewan_mobile/data/models/notification_item_model.dart';
import 'package:aldeewan_mobile/data/models/product_model.dart';
import 'package:aldeewan_mobile/data/models/stock_movement_model.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';

/// Contract for the Budget repository.
abstract class BudgetRepository {
  Stream<List<BudgetModel>> watchBudgets();
  Stream<List<SavingsGoalModel>> watchGoals();
  Future<List<BudgetModel>> getBudgets();
  Future<List<SavingsGoalModel>> getGoals();
  Future<void> upsertBudget(BudgetModel budget);
  Future<void> deleteBudget(ObjectId id);
  Future<void> upsertGoal(SavingsGoalModel goal);
  Future<void> deleteGoal(ObjectId id);
}

/// Contract for the Category repository.
abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Stream<List<CategoryModel>> watchCategories();
  Future<void> upsertCategory(CategoryModel category);
  Future<void> deleteCategory(ObjectId id);
}

/// Contract for the Financial Account repository.
abstract class AccountRepository {
  Future<List<FinancialAccountModel>> getAccounts();
  Stream<List<FinancialAccountModel>> watchAccounts();
  Future<void> upsertAccount(FinancialAccountModel account);
  Future<void> deleteAccount(int id);
}

/// Contract for the Notification repository.
abstract class NotificationRepository {
  Future<List<NotificationItemModel>> getNotifications();
  Stream<List<NotificationItemModel>> watchNotifications();
  Future<void> addNotification(NotificationItemModel notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

/// Contract for the Inventory repository (products + stock movements).
abstract class InventoryRepository {
  Stream<List<ProductModel>> watchProducts();
  Stream<List<StockMovementModel>> watchStockMovements();
  Future<List<ProductModel>> getProducts();
  Future<List<StockMovementModel>> getStockMovements();
  Future<void> upsertProduct(ProductModel product);
  Future<void> archiveProduct(String id);
  Future<void> deleteProduct(String id);
  Future<void> upsertStockMovement(StockMovementModel movement);
  Future<void> deleteStockMovement(String id);
  Future<double> getQuantityOnHand(String productId);
}
