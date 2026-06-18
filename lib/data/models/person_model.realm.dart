// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class PersonModel extends _PersonModel
    with RealmEntity, RealmObjectBase, RealmObject {
  PersonModel(
    String id,
    String role,
    String name,
    DateTime createdAt,
    bool isArchived, {
    String? phone,
    String? currencyCode,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'role', role);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'isArchived', isArchived);
    RealmObjectBase.set(this, 'currencyCode', currencyCode);
  }

  PersonModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get role => RealmObjectBase.get<String>(this, 'role') as String;
  @override
  set role(String value) => RealmObjectBase.set(this, 'role', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  bool get isArchived =>
      RealmObjectBase.get<bool>(this, 'isArchived') as bool;
  @override
  set isArchived(bool value) =>
      RealmObjectBase.set(this, 'isArchived', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currencyCode') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currencyCode', value);

  @override
  Stream<RealmObjectChanges<PersonModel>> get changes =>
      RealmObjectBase.getChanges<PersonModel>(this);

  @override
  Stream<RealmObjectChanges<PersonModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PersonModel>(this, keyPaths);

  @override
  PersonModel freeze() => RealmObjectBase.freezeObject<PersonModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'role': role.toEJson(),
      'name': name.toEJson(),
      'phone': phone.toEJson(),
      'createdAt': createdAt.toEJson(),
      'isArchived': isArchived.toEJson(),
      'currencyCode': currencyCode.toEJson(),
    };
  }

  static EJsonValue _toEJson(PersonModel value) => value.toEJson();
  static PersonModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'role': EJsonValue role,
        'name': EJsonValue name,
        'createdAt': EJsonValue createdAt,
        'isArchived': EJsonValue isArchived,
      } =>
        PersonModel(
          fromEJson(id),
          fromEJson(role),
          fromEJson(name),
          fromEJson(createdAt),
          fromEJson(isArchived),
          phone: fromEJson(ejson['phone']),
          currencyCode: fromEJson(ejson['currencyCode']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PersonModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PersonModel,
      'PersonModel',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('role', RealmPropertyType.string),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('phone', RealmPropertyType.string, optional: true),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty('isArchived', RealmPropertyType.bool),
        SchemaProperty('currencyCode', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
