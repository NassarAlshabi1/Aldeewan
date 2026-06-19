import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:aldeewan_mobile/data/models/product_model.dart';
import 'package:aldeewan_mobile/data/models/stock_movement_model.dart';
import 'package:aldeewan_mobile/domain/entities/product.dart';
import 'package:aldeewan_mobile/domain/repositories/inventory_repositories.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';

/// Read-only view of a product plus its computed quantity on hand.
class ProductWithStock {
  final Product product;
  final double quantityOnHand;
  final bool isLowStock;

  const ProductWithStock({
    required this.product,
    required this.quantityOnHand,
    required this.isLowStock,
  });
}

/// Async state exposed to the InventoryScreen.
class InventoryState {
  final List<ProductWithStock> products;
  final bool isLoading;
  final String? error;

  const InventoryState({
    this.products = const [],
    this.isLoading = true,
    this.error,
  });

  InventoryState copyWith({
    List<ProductWithStock>? products,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier(this._repo) : super(const InventoryState()) {
    _subscribe();
  }

  final InventoryRepository _repo;
  StreamSubscription<List<ProductModel>>? _productSubscription;
  StreamSubscription<List<StockMovementModel>>? _movementSubscription;
  Timer? _recomputeDebounce;

  void _subscribe() {
    final productStream = _repo.watchProducts();
    final movementStream = _repo.watchStockMovements();

    _productSubscription = productStream.listen(
      (_) => _scheduleRecompute(),
      onError: (e, s) {
        if (kDebugMode) {
          debugPrint('❌ InventoryNotifier product stream error: $e');
        }
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );

    _movementSubscription = movementStream.listen(
      (_) => _scheduleRecompute(),
      onError: (e, s) {
        if (kDebugMode) {
          debugPrint('❌ InventoryNotifier movement stream error: $e');
        }
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  /// Debounce rapid re-computes (e.g. bulk stock-take writes).
  void _scheduleRecompute() {
    _recomputeDebounce?.cancel();
    _recomputeDebounce = Timer(const Duration(milliseconds: 100), _recompute);
  }

  Future<void> _recompute() async {
    try {
      final products = await _repo.getProducts();
      final movements = await _repo.getStockMovements();

      // Pre-aggregate quantity on hand per product (single pass).
      final Map<String, double> qtyByProduct = {};
      for (final m in movements) {
        // Local string compare (no enum import).
        final isInbound = m.type == 'inbound' || m.type == 'adjustmentIn';
        final delta = isInbound ? m.quantity : -m.quantity;
        qtyByProduct[m.productId] = (qtyByProduct[m.productId] ?? 0) + delta;
      }

      final result = products.map((p) {
        final qty = qtyByProduct[p.id] ?? 0;
        final threshold = p.lowStockThreshold;
        final isLow = threshold != null && qty <= threshold;
        return ProductWithStock(
          product: p.toEntity(),
          quantityOnHand: qty,
          isLowStock: isLow,
        );
      }).toList();

      state = InventoryState(products: result, isLoading: false);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ InventoryNotifier recompute error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // --- Mutations ---

  Future<void> addProduct(Product product) async {
    final model = productModelFromEntity(product);
    await _repo.upsertProduct(model);
  }

  Future<void> updateProduct(Product product) async {
    final updated = product.copyWith(updatedAt: DateTime.now());
    await _repo.upsertProduct(productModelFromEntity(updated));
  }

  Future<void> archiveProduct(String productId) async {
    await _repo.archiveProduct(productId);
  }

  Future<void> deleteProduct(String productId) async {
    await _repo.deleteProduct(productId);
  }

  Future<void> addStockMovement(StockMovement movement) async {
    await _repo.upsertStockMovement(stockMovementModelFromEntity(movement));
  }

  Future<void> deleteStockMovement(String movementId) async {
    await _repo.deleteStockMovement(movementId);
  }

  @override
  void dispose() {
    _recomputeDebounce?.cancel();
    _productSubscription?.cancel();
    _movementSubscription?.cancel();
    super.dispose();
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repo);
});

// ============================================================
// Helpers
// ============================================================

/// Generates a UUIDv4 suitable for new Product / StockMovement ids.
String generateInventoryId() => const Uuid().v4();
