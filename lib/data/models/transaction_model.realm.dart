// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class TransactionModel extends _TransactionModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TransactionModel(
    String uuid,
    String type,
    double amount,
    DateTime date, {
    String? personId,
    String? category,
    String? note,
    DateTime? dueDate,
    String? externalId,
    String? status,
    int? accountId,
    String? goalId,
    bool isOpeningBalance = false,
    String? currencyCode,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TransactionModel>({
        'isOpeningBalance': false,
      });
    }
    RealmObjectBase.set(this, 'uuid', uuid);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'personId', personId);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'dueDate', dueDate);
    RealmObjectBase.set(this, 'externalId', externalId);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'accountId', accountId);
    RealmObjectBase.set(this, 'goalId', goalId);
    RealmObjectBase.set(this, 'isOpeningBalance', isOpeningBalance);
    RealmObjectBase.set(this, 'currencyCode', currencyCode);
  }

  TransactionModel._();

  @override
  String get uuid => RealmObjectBase.get<String>(this, 'uuid') as String;
  @override
  set uuid(String value) => RealmObjectBase.set(this, 'uuid', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get personId =>
      RealmObjectBase.get<String>(this, 'personId') as String?;
  @override
  set personId(String? value) => RealmObjectBase.set(this, 'personId', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get category =>
      RealmObjectBase.get<String>(this, 'category') as String?;
  @override
  set category(String? value) => RealmObjectBase.set(this, 'category', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  DateTime? get dueDate =>
      RealmObjectBase.get<DateTime>(this, 'dueDate') as DateTime?;
  @override
  set dueDate(DateTime? value) => RealmObjectBase.set(this, 'dueDate', value);

  @override
  String? get externalId =>
      RealmObjectBase.get<String>(this, 'externalId') as String?;
  @override
  set externalId(String? value) =>
      RealmObjectBase.set(this, 'externalId', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  int? get accountId => RealmObjectBase.get<int>(this, 'accountId') as int?;
  @override
  set accountId(int? value) => RealmObjectBase.set(this, 'accountId', value);

  @override
  String? get goalId => RealmObjectBase.get<String>(this, 'goalId') as String?;
  @override
  set goalId(String? value) => RealmObjectBase.set(this, 'goalId', value);

  @override
  bool get isOpeningBalance =>
      RealmObjectBase.get<bool>(this, 'isOpeningBalance') as bool;
  @override
  set isOpeningBalance(bool value) =>
      RealmObjectBase.set(this, 'isOpeningBalance', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currencyCode') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currencyCode', value);

  @override
  Stream<RealmObjectChanges<TransactionModel>> get changes =>
      RealmObjectBase.getChanges<TransactionModel>(this);

  @override
  Stream<RealmObjectChanges<TransactionModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<TransactionModel>(this, keyPaths);

  @override
  TransactionModel freeze() =>
      RealmObjectBase.freezeObject<TransactionModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'uuid': uuid.toEJson(),
      'type': type.toEJson(),
      'personId': personId.toEJson(),
      'amount': amount.toEJson(),
      'date': date.toEJson(),
      'category': category.toEJson(),
      'note': note.toEJson(),
      'dueDate': dueDate.toEJson(),
      'externalId': externalId.toEJson(),
      'status': status.toEJson(),
      'accountId': accountId.toEJson(),
      'goalId': goalId.toEJson(),
      'isOpeningBalance': isOpeningBalance.toEJson(),
      'currencyCode': currencyCode.toEJson(),
    };
  }

  static EJsonValue _toEJson(TransactionModel value) => value.toEJson();
  static TransactionModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'uuid': EJsonValue uuid,
        'type': EJsonValue type,
        'amount': EJsonValue amount,
        'date': EJsonValue date,
      } =>
        TransactionModel(
          fromEJson(uuid),
          fromEJson(type),
          fromEJson(amount),
          fromEJson(date),
          personId: fromEJson(ejson['personId']),
          category: fromEJson(ejson['category']),
          note: fromEJson(ejson['note']),
          dueDate: fromEJson(ejson['dueDate']),
          externalId: fromEJson(ejson['externalId']),
          status: fromEJson(ejson['status']),
          accountId: fromEJson(ejson['accountId']),
          goalId: fromEJson(ejson['goalId']),
          isOpeningBalance: fromEJson(
            ejson['isOpeningBalance'],
            defaultValue: false,
          ),
          currencyCode: fromEJson(ejson['currencyCode']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TransactionModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      TransactionModel,
      'TransactionModel',
      [
        SchemaProperty('uuid', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty(
          'personId',
          RealmPropertyType.string,
          optional: true,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty(
          'date',
          RealmPropertyType.timestamp,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('category', RealmPropertyType.string, optional: true),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('dueDate', RealmPropertyType.timestamp, optional: true),
        SchemaProperty(
          'externalId',
          RealmPropertyType.string,
          optional: true,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty('accountId', RealmPropertyType.int, optional: true),
        SchemaProperty(
          'goalId',
          RealmPropertyType.string,
          optional: true,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('isOpeningBalance', RealmPropertyType.bool),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          optional: true,
          indexType: RealmIndexType.regular,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
