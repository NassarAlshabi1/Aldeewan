// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
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
  set productId(String value) => RealmObjectBase.set(this, 'productId', value);

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
  set unitCost(double? value) => RealmObjectBase.set(this, 'unitCost', value);

  @override
  String? get personId =>
      RealmObjectBase.get<String>(this, 'personId') as String?;
  @override
  set personId(String? value) => RealmObjectBase.set(this, 'personId', value);

  @override
  String? get transactionId =>
      RealmObjectBase.get<String>(this, 'transactionId') as String?;
  @override
  set transactionId(String? value) =>
      RealmObjectBase.set(this, 'transactionId', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
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
        SchemaProperty(
          'productId',
          RealmPropertyType.string,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('quantity', RealmPropertyType.double),
        SchemaProperty('unitCost', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'personId',
          RealmPropertyType.string,
          optional: true,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty(
          'transactionId',
          RealmPropertyType.string,
          optional: true,
        ),
        SchemaProperty(
          'date',
          RealmPropertyType.timestamp,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
