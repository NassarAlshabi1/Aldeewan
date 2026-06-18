/// Type of stock movement — determines the effect on quantity on hand.
enum StockMovementType {
  /// Stock added to inventory (purchasing from supplier, returns, etc.).
  /// Increases quantity.
  inbound,

  /// Stock removed from inventory (sales, damages, transfers out).
  /// Decreases quantity.
  outbound,

  /// Positive correction (e.g. found extra units during stocktaking).
  /// Increases quantity without affecting accounting.
  adjustmentIn,

  /// Negative correction (e.g. lost units, theft, breakage).
  /// Decreases quantity without affecting accounting.
  adjustmentOut,
}

/// A product / SKU tracked in the inventory.
///
/// Quantity-on-hand is computed from the sum of [StockMovement]s for this
/// product. The [lowStockThreshold] drives low-stock alerts.
class Product {
  final String id;
  final String name;
  final String? sku;
  final String? category;
  final String? unit; // e.g. 'kg', 'piece', 'box'
  /// Cost price per unit (in the product's currency). Used for valuation.
  final double? costPrice;
  /// Sale price per unit (in the product's currency).
  final double? salePrice;
  /// Currency code (ISO 4217). Null = use app default currency.
  final String? currencyCode;
  /// Threshold below which a low-stock notification is raised.
  /// Null disables alerts for this product.
  final double? lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  Product({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    this.unit,
    this.costPrice,
    this.salePrice,
    this.currencyCode,
    this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    String? unit,
    double? costPrice,
    double? salePrice,
    String? currencyCode,
    double? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      currencyCode: currencyCode ?? this.currencyCode,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

/// A single stock movement (inbound, outbound, or adjustment).
///
/// Movements are immutable records. Editing a movement means creating a
/// compensating movement rather than mutating history.
class StockMovement {
  final String id;
  final String productId;
  final StockMovementType type;
  /// Absolute quantity (always > 0). The sign is derived from [type].
  final double quantity;
  /// Unit cost at the time of the movement (optional).
  final double? unitCost;
  /// Optional link to a person (supplier for inbound, customer for outbound).
  final String? personId;
  /// Optional link to a financial transaction (e.g. a sale that caused this movement).
  final String? transactionId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.unitCost,
    this.personId,
    this.transactionId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Signed effect on quantity on hand.
  /// Inbound / adjustmentIn → +quantity
  /// Outbound / adjustmentOut → -quantity
  double get signedQuantity {
    switch (type) {
      case StockMovementType.inbound:
      case StockMovementType.adjustmentIn:
        return quantity;
      case StockMovementType.outbound:
      case StockMovementType.adjustmentOut:
        return -quantity;
    }
  }
}
