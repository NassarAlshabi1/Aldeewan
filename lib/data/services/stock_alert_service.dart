import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aldeewan_mobile/presentation/providers/inventory_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';

/// Watches the inventory state and posts a low-stock notification to the
/// in-app notification center whenever a product crosses its low-stock
/// threshold.
///
/// Notifications are deduplicated per (productId, last-seen-qty) to avoid
/// spamming the user on every recompute. Once a product recovers above
/// the threshold, the dedup entry is cleared so a future drop will alert
/// again. Dedup state is **persisted** in SharedPreferences so cold-start
/// does not re-fire notifications for already-known low-stock products.
class StockAlertService {
  StockAlertService(this._ref, this._prefs);

  final Ref _ref;
  final SharedPreferences _prefs;

  static const _kAlertedKey = 'stock_alert_alerted_ids';

  /// Tracks which product IDs we've already alerted about. Cleared when
  /// the product's quantity recovers above the threshold. Persisted.
  Set<String> _alertedProductIds = <String>{};
  Timer? _debounce;
  bool _initialized = false;

  /// Subscribe to inventory changes and emit notifications.
  ///
  /// Returns a function that cancels the subscription when called.
  void Function() start() {
    if (!_initialized) {
      _alertedProductIds = (_prefs.getStringList(_kAlertedKey) ?? <String>[]).toSet();
      _initialized = true;
    }

    final subscription = _ref.listen<InventoryState>(
      inventoryProvider,
      (previous, next) => _scheduleProcess(next),
      fireImmediately: false,
    );
    return () {
      _debounce?.cancel();
      subscription.close();
    };
  }

  /// Debounce inventory changes — bulk writes can fire many events in quick
  /// succession, and we only want one notification pass per burst.
  void _scheduleProcess(InventoryState state) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _process(state);
    });
  }

  Future<void> _process(InventoryState state) async {
    if (state.isLoading) return;

    final notifier = _ref.read(notificationHistoryProvider.notifier);

    for (final item in state.products) {
      final id = item.product.id;
      final isLow = item.isLowStock;
      final wasAlerted = _alertedProductIds.contains(id);

      if (isLow && !wasAlerted) {
        final qty = item.quantityOnHand.toStringAsFixed(2);
        final unit = item.product.unit ?? '';
        final threshold =
            item.product.lowStockThreshold?.toStringAsFixed(2) ?? '';
        await notifier.addNotification(
          title: 'Low stock: ${item.product.name}',
          body: 'Quantity on hand: $qty ${unit.trim()}'
              '${threshold.isNotEmpty ? " (threshold: $threshold)" : ""}',
          type: 'warning',
        );
        _alertedProductIds.add(id);
      } else if (!isLow && wasAlerted) {
        _alertedProductIds.remove(id);
      }
    }

    // Persist dedup state so cold-start does not re-fire alerts.
    await _prefs.setStringList(_kAlertedKey, _alertedProductIds.toList());
  }

  /// Clears the dedup state. Useful for tests or when the user manually
  /// dismisses all notifications.
  Future<void> reset() async {
    _alertedProductIds.clear();
    await _prefs.setStringList(_kAlertedKey, <String>[]);
  }
}

/// Provider that exposes a single [StockAlertService] instance.
final stockAlertServiceProvider = Provider<StockAlertService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StockAlertService(ref, prefs);
});
