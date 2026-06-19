// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class RecurringTransactionModel extends _RecurringTransactionModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  RecurringTransactionModel(
    String id,
    String type,
    double amount,
    String frequency,
    DateTime startDate,
    DateTime nextRunDate,
    DateTime createdAt, {
    String? personId,
    String? category,
    String? note,
    String? currencyCode,
    DateTime? endDate,
    int occurrencesGenerated = 0,
    bool isPaused = false,
    DateTime? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<RecurringTransactionModel>({
        'occurrencesGenerated': 0,
        'isPaused': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'personId', personId);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'currencyCode', currencyCode);
    RealmObjectBase.set(this, 'frequency', frequency);
    RealmObjectBase.set(this, 'startDate', startDate);
    RealmObjectBase.set(this, 'endDate', endDate);
    RealmObjectBase.set(this, 'nextRunDate', nextRunDate);
    RealmObjectBase.set(this, 'occurrencesGenerated', occurrencesGenerated);
    RealmObjectBase.set(this, 'isPaused', isPaused);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  RecurringTransactionModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String? get personId =>
      RealmObjectBase.get<String>(this, 'personId') as String?;
  @override
  set personId(String? value) => RealmObjectBase.set(this, 'personId', value);

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
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currencyCode') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currencyCode', value);

  @override
  String get frequency =>
      RealmObjectBase.get<String>(this, 'frequency') as String;
  @override
  set frequency(String value) => RealmObjectBase.set(this, 'frequency', value);

  @override
  DateTime get startDate =>
      RealmObjectBase.get<DateTime>(this, 'startDate') as DateTime;
  @override
  set startDate(DateTime value) =>
      RealmObjectBase.set(this, 'startDate', value);

  @override
  DateTime? get endDate =>
      RealmObjectBase.get<DateTime>(this, 'endDate') as DateTime?;
  @override
  set endDate(DateTime? value) => RealmObjectBase.set(this, 'endDate', value);

  @override
  DateTime get nextRunDate =>
      RealmObjectBase.get<DateTime>(this, 'nextRunDate') as DateTime;
  @override
  set nextRunDate(DateTime value) =>
      RealmObjectBase.set(this, 'nextRunDate', value);

  @override
  int get occurrencesGenerated =>
      RealmObjectBase.get<int>(this, 'occurrencesGenerated') as int;
  @override
  set occurrencesGenerated(int value) =>
      RealmObjectBase.set(this, 'occurrencesGenerated', value);

  @override
  bool get isPaused => RealmObjectBase.get<bool>(this, 'isPaused') as bool;
  @override
  set isPaused(bool value) => RealmObjectBase.set(this, 'isPaused', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<RecurringTransactionModel>> get changes =>
      RealmObjectBase.getChanges<RecurringTransactionModel>(this);

  @override
  Stream<RealmObjectChanges<RecurringTransactionModel>> changesFor([
    List<String>? keyPaths,
  ]) =>
      RealmObjectBase.getChangesFor<RecurringTransactionModel>(this, keyPaths);

  @override
  RecurringTransactionModel freeze() =>
      RealmObjectBase.freezeObject<RecurringTransactionModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'type': type.toEJson(),
      'amount': amount.toEJson(),
      'personId': personId.toEJson(),
      'category': category.toEJson(),
      'note': note.toEJson(),
      'currencyCode': currencyCode.toEJson(),
      'frequency': frequency.toEJson(),
      'startDate': startDate.toEJson(),
      'endDate': endDate.toEJson(),
      'nextRunDate': nextRunDate.toEJson(),
      'occurrencesGenerated': occurrencesGenerated.toEJson(),
      'isPaused': isPaused.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(RecurringTransactionModel value) =>
      value.toEJson();
  static RecurringTransactionModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'type': EJsonValue type,
        'amount': EJsonValue amount,
        'frequency': EJsonValue frequency,
        'startDate': EJsonValue startDate,
        'nextRunDate': EJsonValue nextRunDate,
        'createdAt': EJsonValue createdAt,
      } =>
        RecurringTransactionModel(
          fromEJson(id),
          fromEJson(type),
          fromEJson(amount),
          fromEJson(frequency),
          fromEJson(startDate),
          fromEJson(nextRunDate),
          fromEJson(createdAt),
          personId: fromEJson(ejson['personId']),
          category: fromEJson(ejson['category']),
          note: fromEJson(ejson['note']),
          currencyCode: fromEJson(ejson['currencyCode']),
          endDate: fromEJson(ejson['endDate']),
          occurrencesGenerated: fromEJson(
            ejson['occurrencesGenerated'],
            defaultValue: 0,
          ),
          isPaused: fromEJson(ejson['isPaused'], defaultValue: false),
          updatedAt: fromEJson(ejson['updatedAt']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RecurringTransactionModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      RecurringTransactionModel,
      'RecurringTransactionModel',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty('personId', RealmPropertyType.string, optional: true),
        SchemaProperty('category', RealmPropertyType.string, optional: true),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          optional: true,
        ),
        SchemaProperty('frequency', RealmPropertyType.string),
        SchemaProperty('startDate', RealmPropertyType.timestamp),
        SchemaProperty('endDate', RealmPropertyType.timestamp, optional: true),
        SchemaProperty('nextRunDate', RealmPropertyType.timestamp),
        SchemaProperty('occurrencesGenerated', RealmPropertyType.int),
        SchemaProperty('isPaused', RealmPropertyType.bool),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty(
          'updatedAt',
          RealmPropertyType.timestamp,
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
