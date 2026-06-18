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

class StockMovementModel extends _StockMovementModel
    with RealmEntity, RealmObjectBase, RealmObject {
  StockMovementModel(
    String id,
    String productId,
    String type,
    double quantity,
    DateTime date,
    DateTime createdAt, {
    double? unitCost,
    String? personId,
    String? transactionId,
    String? note,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'productId', productId);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'unitCost', unitCost);
    RealmObjectBase.set(this, 'personId', personId);
    RealmObjectBase.set(this, 'transactionId', transactionId);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  StockMovementModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get productId =>
      RealmObjectBase.get<String>(this, 'productId') as String;
  @override
  set productId(String value) =>
      RealmObjectBase.set(this, 'productId', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  double get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double;
  @override
  set quantity(double value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double? get unitCost =>
      RealmObjectBase.get<double>(this, 'unitCost') as double?;
  @override
  set unitCost(double? value) =>
      RealmObjectBase.set(this, 'unitCost', value);

  @override
  String? get personId =>
      RealmObjectBase.get<String>(this, 'personId') as String?;
  @override
  set personId(String? value) =>
      RealmObjectBase.set(this, 'personId', value);

  @override
  String? get transactionId =>
      RealmObjectBase.get<String>(this, 'transactionId') as String?;
  @override
  set transactionId(String? value) =>
      RealmObjectBase.set(this, 'transactionId', value);

  @override
  DateTime get date =>
      RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  Stream<RealmObjectChanges<StockMovementModel>> get changes =>
      RealmObjectBase.getChanges<StockMovementModel>(this);

  @override
  Stream<RealmObjectChanges<StockMovementModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<StockMovementModel>(this, keyPaths);

  @override
  StockMovementModel freeze() =>
      RealmObjectBase.freezeObject<StockMovementModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'productId': productId.toEJson(),
      'type': type.toEJson(),
      'quantity': quantity.toEJson(),
      'unitCost': unitCost.toEJson(),
      'personId': personId.toEJson(),
      'transactionId': transactionId.toEJson(),
      'date': date.toEJson(),
      'note': note.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(StockMovementModel value) => value.toEJson();
  static StockMovementModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'productId': EJsonValue productId,
        'type': EJsonValue type,
        'quantity': EJsonValue quantity,
        'date': EJsonValue date,
        'createdAt': EJsonValue createdAt,
      } =>
        StockMovementModel(
          fromEJson(id),
          fromEJson(productId),
          fromEJson(type),
          fromEJson(quantity),
          fromEJson(date),
          fromEJson(createdAt),
          unitCost: fromEJson(ejson['unitCost']),
          personId: fromEJson(ejson['personId']),
          transactionId: fromEJson(ejson['transactionId']),
          note: fromEJson(ejson['note']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StockMovementModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      StockMovementModel,
      'StockMovementModel',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('productId', RealmPropertyType.string,
            indexType: RealmIndexType.regular),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('quantity', RealmPropertyType.double),
        SchemaProperty('unitCost', RealmPropertyType.double, optional: true),
        SchemaProperty('personId', RealmPropertyType.string, optional: true),
        SchemaProperty('transactionId', RealmPropertyType.string, optional: true),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
