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
