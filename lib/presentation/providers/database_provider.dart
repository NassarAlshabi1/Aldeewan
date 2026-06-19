import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';

/// `localDatabaseSourceProvider` is now canonically defined in
/// `dependency_injection.dart`. This file only exposes the async
/// `realmProvider` for widgets that still need a raw Realm handle.
final realmProvider = FutureProvider<Realm>((ref) async {
  final source = ref.watch(localDatabaseSourceProvider);
  return source.db;
});
