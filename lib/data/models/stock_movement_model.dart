import 'package:realm/realm.dart' hide Transaction;
import 'package:aldeewan_mobile/domain/entities/product.dart';
import 'package:aldeewan_mobile/data/models/product_model.dart';

/// Realm model for a stock movement.
///
/// Defined in its own file so the [StockMovementModelMapper] extension below
/// survives `build_runner --delete-conflicting-outputs` (which regenerates
/// only `*.realm.dart` files, not this one).
@RealmModel()
class _StockMovementModel {
  @PrimaryKey()
  late String id;

  @Indexed()
  late String productId;

  /// Stored as the enum name (inbound / outbound / adjustmentIn / adjustmentOut).
  late String type;

  late double quantity;
  double? unitCost;
  String? personId;
  String? transactionId;
  late DateTime date;
  String? note;
  late DateTime createdAt;
}

/// Mapper for [StockMovementModel] ↔ [StockMovement].
///
/// Lives in this file (not the generated `.realm.dart`) so it survives
/// `build_runner` regeneration.
extension StockMovementModelMapper on StockMovementModel {
  StockMovement toEntity() {
    return StockMovement(
      id: id,
      productId: productId,
      type: StockMovementType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => StockMovementType.inbound,
      ),
      quantity: quantity,
      unitCost: unitCost,
      personId: personId,
      transactionId: transactionId,
      date: date,
      note: note,
      createdAt: createdAt,
    );
  }
}

StockMovementModel stockMovementModelFromEntity(StockMovement movement) {
  return StockMovementModel(
    movement.id,
    movement.productId,
    movement.type.name,
    movement.quantity,
    movement.date,
    movement.createdAt,
    unitCost: movement.unitCost,
    personId: movement.personId,
    transactionId: movement.transactionId,
    note: movement.note,
  );
}

/// Mapper for [ProductModel] ↔ [Product].
///
/// Lives in this file (not the generated `.realm.dart`) so it survives
/// `build_runner` regeneration.
extension ProductModelMapper on ProductModel {
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      sku: sku,
      category: category,
      unit: unit,
      costPrice: costPrice,
      salePrice: salePrice,
      currencyCode: currencyCode,
      lowStockThreshold: lowStockThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
    );
  }
}

ProductModel productModelFromEntity(Product product) {
  return ProductModel(
    product.id,
    product.name,
    product.createdAt,
    product.updatedAt,
    isArchived: product.isArchived,
    sku: product.sku,
    category: product.category,
    unit: product.unit,
    costPrice: product.costPrice,
    salePrice: product.salePrice,
    currencyCode: product.currencyCode,
    lowStockThreshold: product.lowStockThreshold,
  );
}
