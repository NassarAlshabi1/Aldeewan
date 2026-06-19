import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:aldeewan_mobile/data/models/notification_item_model.dart';
import 'package:aldeewan_mobile/domain/repositories/inventory_repositories.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';

class NotificationHistoryNotifier
    extends StateNotifier<List<NotificationItemModel>> {
  NotificationHistoryNotifier(this._repo) : super([]) {
    _init();
  }

  final NotificationRepository _repo;
  StreamSubscription<List<NotificationItemModel>>? _subscription;

  Future<void> _init() async {
    final initial = await _repo.getNotifications();
    if (!mounted) return;
    state = initial;
    _subscription = _repo.watchNotifications().listen((notifications) {
      if (!mounted) return;
      final sorted = List<NotificationItemModel>.from(notifications)
        ..sort((a, b) => b.date.compareTo(a.date));
      state = sorted;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addNotification({
    required String title,
    required String body,
    String type = 'info',
  }) async {
    final notification = NotificationItemModel(
      const Uuid().v4(),
      title,
      body,
      DateTime.now(),
      false,
      type,
    );
    await _repo.addNotification(notification);
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    await _repo.deleteNotification(id);
  }
}

final notificationHistoryProvider = StateNotifierProvider<
    NotificationHistoryNotifier, List<NotificationItemModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationHistoryNotifier(repo);
});
