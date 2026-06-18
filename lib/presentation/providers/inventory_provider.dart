import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:aldeewan_mobile/data/datasources/local_database_source.dart';
import 'package:aldeewan_mobile/data/models/product_model.dart';
import 'package:aldeewan_mobile/data/models/stock_movement_model.dart';
import 'package:aldeewan_mobile/domain/entities/product.dart';
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
  InventoryNotifier(this._dataSource) : super(const InventoryState()) {
    _subscribe();
  }

  final LocalDatabaseSource _dataSource;
  Stream<List<ProductModel>>? _productStream;
  Stream<List<StockMovementModel>>? _movementStream;

  void _subscribe() {
    _productStream = _dataSource.watchProducts();
    _movementStream = _dataSource.watchStockMovements();

    _productStream!.listen(
      (_) => _recompute(),
      onError: (e, s) {
        debugPrint('❌ InventoryNotifier product stream error: $e');
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );

    _movementStream!.listen(
      (_) => _recompute(),
      onError: (e, s) {
        debugPrint('❌ InventoryNotifier movement stream error: $e');
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  Future<void> _recompute() async {
    try {
      final products = await _dataSource.getProducts();
      final movements = await _dataSource.getStockMovements();

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
    } catch (e, s) {
      debugPrint('❌ InventoryNotifier recompute error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // --- Mutations ---

  Future<void> addProduct(Product product) async {
    final model = productModelFromEntity(product);
    await _dataSource.putProduct(model);
  }

  Future<void> updateProduct(Product product) async {
    final updated = product.copyWith(updatedAt: DateTime.now());
    await _dataSource.putProduct(productModelFromEntity(updated));
  }

  Future<void> archiveProduct(String productId) async {
    await _dataSource.archiveProduct(productId);
  }

  Future<void> deleteProduct(String productId) async {
    await _dataSource.deleteProduct(productId);
  }

  Future<void> addStockMovement(StockMovement movement) async {
    await _dataSource.putStockMovement(stockMovementModelFromEntity(movement));
  }

  Future<void> deleteStockMovement(String movementId) async {
    await _dataSource.deleteStockMovement(movementId);
  }

  @override
  void dispose() {
    _productStream = null;
    _movementStream = null;
    super.dispose();
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final dataSource = ref.watch(localDatabaseSourceProvider);
  return InventoryNotifier(dataSource);
});

// ============================================================
// Helpers
// ============================================================

/// Generates a UUIDv4 suitable for new Product / StockMovement ids.
String generateInventoryId() => const Uuid().v4();
