import 'package:realm/realm.dart';
import 'package:aldeewan_mobile/domain/entities/product.dart';

part 'product_model.realm.dart';

@RealmModel()
class _ProductModel {
  @PrimaryKey()
  late String id;

  late String name;
  String? sku;
  String? category;
  String? unit;
  double? costPrice;
  double? salePrice;
  /// ISO 4217 currency code. Null = use app default.
  String? currencyCode;
  /// Threshold below which a low-stock alert fires. Null = no alerts.
  double? lowStockThreshold;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isArchived = false;
}

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

  static ProductModel fromEntity(Product product) {
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
}

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

  static StockMovementModel fromEntity(StockMovement movement) {
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
}
