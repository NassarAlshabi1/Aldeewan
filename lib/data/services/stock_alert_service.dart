import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aldeewan_mobile/presentation/providers/inventory_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';

/// Watches the inventory state and posts a low-stock notification to the
/// in-app notification center whenever a product crosses its low-stock
/// threshold.
///
/// Notifications are deduplicated per (productId, last-seen-qty) to avoid
/// spamming the user on every recompute. Once a product recovers above
/// the threshold, the dedup entry is cleared so a future drop will alert
/// again.
class StockAlertService {
  StockAlertService(this._ref);

  final Ref _ref;

  /// Tracks which product IDs we've already alerted about. Cleared when
  /// the product's quantity recovers above the threshold.
  final Set<String> _alertedProductIds = {};

  /// Subscribe to inventory changes and emit notifications.
  ///
  /// Returns a function that cancels the subscription when called.
  void Function() start() {
    final subscription = _ref.listen<InventoryState>(
      inventoryProvider,
      (previous, next) => _onInventoryChanged(next),
      fireImmediately: false,
    );
    return subscription.close;
  }

  void _onInventoryChanged(InventoryState state) {
    if (state.isLoading) return;

    final notifier = _ref.read(notificationHistoryProvider.notifier);
    final l10nProvider = _ref.container;
    // Reading l10n is hard from here (no BuildContext), so we use
    // generic strings that are translated at the notification-view layer
    // via type. Keep titles/body in English; the NotificationsScreen
    // already displays them as-is.

    for (final item in state.products) {
      final id = item.product.id;
      final isLow = item.isLowStock;
      final wasAlerted = _alertedProductIds.contains(id);

      if (isLow && !wasAlerted) {
        // Crossed below threshold — fire notification.
        final qty = item.quantityOnHand.toStringAsFixed(2);
        final unit = item.product.unit ?? '';
        final threshold = item.product.lowStockThreshold?.toStringAsFixed(2) ?? '';
        notifier.addNotification(
          title: '⚠️ Low stock: ${item.product.name}',
          body: 'Quantity on hand: $qty ${unit.trim()}'
              '${threshold.isNotEmpty ? " (threshold: $threshold)" : ""}',
          type: 'warning',
        );
        _alertedProductIds.add(id);
      } else if (!isLow && wasAlerted) {
        // Recovered above threshold — clear dedup so future drops alert.
        _alertedProductIds.remove(id);
      }
    }
  }

  /// Clears the dedup state. Useful for tests or when the user manually
  /// dismisses all notifications.
  void reset() {
    _alertedProductIds.clear();
  }
}

/// Provider that exposes a single [StockAlertService] instance.
final stockAlertServiceProvider = Provider<StockAlertService>((ref) {
  return StockAlertService(ref);
});
