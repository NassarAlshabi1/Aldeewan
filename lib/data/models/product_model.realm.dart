// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class ProductModel extends _ProductModel
    with RealmEntity, RealmObjectBase, RealmObject {
  ProductModel(
    String id,
    String name,
    DateTime createdAt,
    DateTime updatedAt, {
    String? sku,
    String? category,
    String? unit,
    double? costPrice,
    double? salePrice,
    String? currencyCode,
    double? lowStockThreshold,
    bool isArchived = false,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'sku', sku);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'unit', unit);
    RealmObjectBase.set(this, 'costPrice', costPrice);
    RealmObjectBase.set(this, 'salePrice', salePrice);
    RealmObjectBase.set(this, 'currencyCode', currencyCode);
    RealmObjectBase.set(this, 'lowStockThreshold', lowStockThreshold);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'isArchived', isArchived);
  }

  ProductModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get sku => RealmObjectBase.get<String>(this, 'sku') as String?;
  @override
  set sku(String? value) => RealmObjectBase.set(this, 'sku', value);

  @override
  String? get category =>
      RealmObjectBase.get<String>(this, 'category') as String?;
  @override
  set category(String? value) => RealmObjectBase.set(this, 'category', value);

  @override
  String? get unit => RealmObjectBase.get<String>(this, 'unit') as String?;
  @override
  set unit(String? value) => RealmObjectBase.set(this, 'unit', value);

  @override
  double? get costPrice =>
      RealmObjectBase.get<double>(this, 'costPrice') as double?;
  @override
  set costPrice(double? value) =>
      RealmObjectBase.set(this, 'costPrice', value);

  @override
  double? get salePrice =>
      RealmObjectBase.get<double>(this, 'salePrice') as double?;
  @override
  set salePrice(double? value) =>
      RealmObjectBase.set(this, 'salePrice', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currencyCode') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currencyCode', value);

  @override
  double? get lowStockThreshold =>
      RealmObjectBase.get<double>(this, 'lowStockThreshold') as double?;
  @override
  set lowStockThreshold(double? value) =>
      RealmObjectBase.set(this, 'lowStockThreshold', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  bool get isArchived =>
      RealmObjectBase.get<bool>(this, 'isArchived') as bool;
  @override
  set isArchived(bool value) =>
      RealmObjectBase.set(this, 'isArchived', value);

  @override
  Stream<RealmObjectChanges<ProductModel>> get changes =>
      RealmObjectBase.getChanges<ProductModel>(this);

  @override
  Stream<RealmObjectChanges<ProductModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<ProductModel>(this, keyPaths);

  @override
  ProductModel freeze() => RealmObjectBase.freezeObject<ProductModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'sku': sku.toEJson(),
      'category': category.toEJson(),
      'unit': unit.toEJson(),
      'costPrice': costPrice.toEJson(),
      'salePrice': salePrice.toEJson(),
      'currencyCode': currencyCode.toEJson(),
      'lowStockThreshold': lowStockThreshold.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
      'isArchived': isArchived.toEJson(),
    };
  }

  static EJsonValue _toEJson(ProductModel value) => value.toEJson();
  static ProductModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
      } =>
        ProductModel(
          fromEJson(id),
          fromEJson(name),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          sku: fromEJson(ejson['sku']),
          category: fromEJson(ejson['category']),
          unit: fromEJson(ejson['unit']),
          costPrice: fromEJson(ejson['costPrice']),
          salePrice: fromEJson(ejson['salePrice']),
          currencyCode: fromEJson(ejson['currencyCode']),
          lowStockThreshold: fromEJson(ejson['lowStockThreshold']),
          isArchived: fromEJson(ejson['isArchived'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ProductModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ProductModel,
      'ProductModel',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('sku', RealmPropertyType.string, optional: true),
        SchemaProperty('category', RealmPropertyType.string, optional: true),
        SchemaProperty('unit', RealmPropertyType.string, optional: true),
        SchemaProperty('costPrice', RealmPropertyType.double, optional: true),
        SchemaProperty('salePrice', RealmPropertyType.double, optional: true),
        SchemaProperty('currencyCode', RealmPropertyType.string, optional: true),
        SchemaProperty('lowStockThreshold', RealmPropertyType.double, optional: true),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty('updatedAt', RealmPropertyType.timestamp),
        SchemaProperty('isArchived', RealmPropertyType.bool),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
