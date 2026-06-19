// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_account_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class FinancialAccountModel extends _FinancialAccountModel
    with RealmEntity, RealmObjectBase, RealmObject {
  FinancialAccountModel(
    int id,
    String name,
    String providerId,
    String accountType,
    double balance,
    String currency, {
    String? externalAccountId,
    DateTime? lastSyncTime,
    String? status,
    String? colorHex,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'providerId', providerId);
    RealmObjectBase.set(this, 'accountType', accountType);
    RealmObjectBase.set(this, 'balance', balance);
    RealmObjectBase.set(this, 'currency', currency);
    RealmObjectBase.set(this, 'externalAccountId', externalAccountId);
    RealmObjectBase.set(this, 'lastSyncTime', lastSyncTime);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'colorHex', colorHex);
  }

  FinancialAccountModel._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get providerId =>
      RealmObjectBase.get<String>(this, 'providerId') as String;
  @override
  set providerId(String value) =>
      RealmObjectBase.set(this, 'providerId', value);

  @override
  String get accountType =>
      RealmObjectBase.get<String>(this, 'accountType') as String;
  @override
  set accountType(String value) =>
      RealmObjectBase.set(this, 'accountType', value);

  @override
  double get balance => RealmObjectBase.get<double>(this, 'balance') as double;
  @override
  set balance(double value) => RealmObjectBase.set(this, 'balance', value);

  @override
  String get currency =>
      RealmObjectBase.get<String>(this, 'currency') as String;
  @override
  set currency(String value) => RealmObjectBase.set(this, 'currency', value);

  @override
  String? get externalAccountId =>
      RealmObjectBase.get<String>(this, 'externalAccountId') as String?;
  @override
  set externalAccountId(String? value) =>
      RealmObjectBase.set(this, 'externalAccountId', value);

  @override
  DateTime? get lastSyncTime =>
      RealmObjectBase.get<DateTime>(this, 'lastSyncTime') as DateTime?;
  @override
  set lastSyncTime(DateTime? value) =>
      RealmObjectBase.set(this, 'lastSyncTime', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get colorHex =>
      RealmObjectBase.get<String>(this, 'colorHex') as String?;
  @override
  set colorHex(String? value) => RealmObjectBase.set(this, 'colorHex', value);

  @override
  Stream<RealmObjectChanges<FinancialAccountModel>> get changes =>
      RealmObjectBase.getChanges<FinancialAccountModel>(this);

  @override
  Stream<RealmObjectChanges<FinancialAccountModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<FinancialAccountModel>(this, keyPaths);

  @override
  FinancialAccountModel freeze() =>
      RealmObjectBase.freezeObject<FinancialAccountModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'providerId': providerId.toEJson(),
      'accountType': accountType.toEJson(),
      'balance': balance.toEJson(),
      'currency': currency.toEJson(),
      'externalAccountId': externalAccountId.toEJson(),
      'lastSyncTime': lastSyncTime.toEJson(),
      'status': status.toEJson(),
      'colorHex': colorHex.toEJson(),
    };
  }

  static EJsonValue _toEJson(FinancialAccountModel value) => value.toEJson();
  static FinancialAccountModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'providerId': EJsonValue providerId,
        'accountType': EJsonValue accountType,
        'balance': EJsonValue balance,
        'currency': EJsonValue currency,
      } =>
        FinancialAccountModel(
          fromEJson(id),
          fromEJson(name),
          fromEJson(providerId),
          fromEJson(accountType),
          fromEJson(balance),
          fromEJson(currency),
          externalAccountId: fromEJson(ejson['externalAccountId']),
          lastSyncTime: fromEJson(ejson['lastSyncTime']),
          status: fromEJson(ejson['status']),
          colorHex: fromEJson(ejson['colorHex']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(FinancialAccountModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      FinancialAccountModel,
      'FinancialAccountModel',
      [
        SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty(
          'providerId',
          RealmPropertyType.string,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('accountType', RealmPropertyType.string),
        SchemaProperty('balance', RealmPropertyType.double),
        SchemaProperty('currency', RealmPropertyType.string),
        SchemaProperty(
          'externalAccountId',
          RealmPropertyType.string,
          optional: true,
        ),
        SchemaProperty(
          'lastSyncTime',
          RealmPropertyType.timestamp,
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty('colorHex', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
