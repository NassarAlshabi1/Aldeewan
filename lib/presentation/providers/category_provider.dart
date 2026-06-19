import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/data/models/category_model.dart';
import 'package:aldeewan_mobile/domain/repositories/inventory_repositories.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/models/category.dart';
import 'package:realm/realm.dart';

/// Typed failure for category deletion.
class CategoryInUseFailure implements Exception {
  final String categoryName;
  const CategoryInUseFailure(this.categoryName);
  @override
  String toString() =>
      'Cannot delete category "$categoryName" because it is used in active budgets.';
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final notifier = CategoryNotifier(repo, budgetRepo);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier(this._repo, this._budgetRepo) : super([]) {
    _init();
  }

  final CategoryRepository _repo;
  final BudgetRepository _budgetRepo;
  StreamSubscription<List<CategoryModel>>? _subscription;

  Future<void> _init() async {
    final existing = await _repo.getCategories();
    if (existing.isEmpty) {
      await _seedDefaults();
    }
    _subscription = _repo.watchCategories().listen((models) {
      if (!mounted) return;
      state = models.map((m) => Category.fromModel(m)).toList();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _seedDefaults() async {
    final defaults = [
      _createModel('Housing', 'home', Colors.blue, 'expense'),
      _createModel('Food & Dining', 'utensils', Colors.orange, 'expense'),
      _createModel('Transportation', 'car', Colors.teal, 'expense'),
      _createModel('Health', 'heartPulse', Colors.red, 'expense'),
      _createModel('Entertainment', 'clapperboard', Colors.purple, 'expense'),
      _createModel('Shopping', 'shoppingBag', Colors.pink, 'expense'),
      _createModel('Utilities', 'lightbulb', Colors.yellow, 'expense'),
      _createModel('Income', 'wallet', Colors.green, 'income'),
    ];
    for (final model in defaults) {
      await _repo.upsertCategory(model);
    }
  }

  CategoryModel _createModel(
      String name, String icon, Color color, String type) {
    return CategoryModel(
      ObjectId(),
      name,
      icon,
      '0x${color.toARGB32().toRadixString(16).toUpperCase()}',
      type,
      false,
    );
  }

  Future<void> addCategory(
      String name, String iconName, Color color, String type) async {
    final model = CategoryModel(
      ObjectId(),
      name,
      iconName,
      '0x${color.toARGB32().toRadixString(16).toUpperCase()}',
      type,
      true,
    );
    await _repo.upsertCategory(model);
  }

  Future<void> deleteCategory(String id) async {
    final objectId = ObjectId.fromHexString(id);
    final existing = await _repo.getCategories();
    final model = existing.firstWhere(
      (c) => c.id == objectId,
      orElse: () => throw Exception('Category not found'),
    );

    // Check for active budgets using this category name.
    final budgets = await _budgetRepo.getBudgets();
    final activeBudgets =
        budgets.where((b) => b.category == model.name).toList();
    if (activeBudgets.isNotEmpty) {
      throw CategoryInUseFailure(model.name);
    }

    await _repo.deleteCategory(objectId);
  }
}
