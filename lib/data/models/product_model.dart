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
