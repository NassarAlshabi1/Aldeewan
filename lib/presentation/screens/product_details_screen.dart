import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aldeewan_mobile/domain/entities/product.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/presentation/providers/inventory_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/presentation/widgets/product_form.dart';
import 'package:aldeewan_mobile/presentation/widgets/stock_movement_form.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:aldeewan_mobile/presentation/widgets/dual_date_text.dart';

/// Shows full details for a single product plus its complete movement history.
class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  List<StockMovement> _movements = [];
  bool _loadingMovements = true;
  double _quantityOnHand = 0;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    final ds = ref.read(localDatabaseSourceProvider);
    final models = await ds.getStockMovementsByProduct(widget.productId);
    final qoh = await ds.getQuantityOnHand(widget.productId);
    if (!mounted) return;
    setState(() {
      _movements = models.map((m) => m.toEntity()).toList();
      _quantityOnHand = qoh;
      _loadingMovements = false;
    });
  }

  void _showEditModal(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductForm(
        product: product,
        onSave: (updated) async {
          await ref.read(inventoryProvider.notifier).updateProduct(updated);
          // Refresh local movements view in case product details changed.
          _loadMovements();
        },
      ),
    );
  }

  void _showMovementModal(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StockMovementForm(
        product: product,
        currentQuantityOnHand: _quantityOnHand,
        onSave: (movement) async {
          await ref.read(inventoryProvider.notifier).addStockMovement(movement);
          _loadMovements();
        },
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteProductTitle),
        content: Text(l10n.deleteProductMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(inventoryProvider.notifier).deleteProduct(product.id);
      if (context.mounted) context.pop();
    }
  }

  Future<void> _deleteMovement(StockMovement m) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteMovementTitle),
        content: Text(l10n.deleteMovementMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(inventoryProvider.notifier).deleteStockMovement(m.id);
      _loadMovements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final state = ref.watch(inventoryProvider);
    final numberFormat = NumberFormat('#,##0.##');

    final item = state.products
        .where((p) => p.product.id == widget.productId)
        .firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.product)),
        body: Center(child: Text(l10n.noProductsYet)),
      );
    }

    final product = item.product;
    final effectiveCurrency = product.currencyCode ?? currency;
    final qty = _loadingMovements ? item.quantityOnHand : _quantityOnHand;
    final statusColor = qty <= 0
        ? AppColors.error
        : (item.isLowStock ? AppColors.warning : AppColors.success);
    final stockValue = (product.costPrice ?? 0) * qty;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            tooltip: l10n.editProduct,
            onPressed: () => _showEditModal(product),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            tooltip: l10n.delete,
            onPressed: () => _confirmDelete(product),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Hero card with current stock
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quantityOnHand,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${numberFormat.format(qty)} ${product.unit ?? ""}'.trim(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 6.h),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          qty <= 0
                              ? l10n.outOfStock
                              : (item.isLowStock ? l10n.lowStock : l10n.inStock),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.package, size: 48, color: statusColor),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Product details card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  if (product.sku != null) _DetailRow(label: l10n.sku, value: product.sku!),
                  if (product.category != null) _DetailRow(label: l10n.category, value: product.category!),
                  if (product.unit != null) _DetailRow(label: l10n.unit, value: product.unit!),
                  if (product.costPrice != null)
                    _DetailRow(
                      label: l10n.costPrice,
                      value: '$effectiveCurrency ${numberFormat.format(product.costPrice)}',
                    ),
                  if (product.salePrice != null)
                    _DetailRow(
                      label: l10n.salePrice,
                      value: '$effectiveCurrency ${numberFormat.format(product.salePrice)}',
                    ),
                  if (product.lowStockThreshold != null)
                    _DetailRow(
                      label: l10n.lowStockThreshold,
                      value: numberFormat.format(product.lowStockThreshold),
                    ),
                  _DetailRow(
                    label: l10n.stockValue,
                    value: '$effectiveCurrency ${numberFormat.format(stockValue)}',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Movements section
          Row(
            children: [
              Icon(LucideIcons.history, size: 18, color: theme.colorScheme.primary),
              SizedBox(width: 6.w),
              Text(
                l10n.stockMovements,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (_loadingMovements)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_movements.isEmpty)
            EmptyState(
              message: l10n.noMovementsYet,
              icon: LucideIcons.history,
              lottieAsset: 'assets/animations/empty_list.json',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _movements.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final m = _movements[index];
                final isInbound = m.type == StockMovementType.inbound ||
                    m.type == StockMovementType.adjustmentIn;
                final movementColor = isInbound ? AppColors.success : AppColors.error;
                final typeLabel = switch (m.type) {
                  StockMovementType.inbound => l10n.inbound,
                  StockMovementType.outbound => l10n.outbound,
                  StockMovementType.adjustmentIn => l10n.adjustmentIn,
                  StockMovementType.adjustmentOut => l10n.adjustmentOut,
                };

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: movementColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      isInbound ? LucideIcons.arrowDown : LucideIcons.arrowUp,
                      color: movementColor,
                      size: 18,
                    ),
                  ),
                  title: Text(typeLabel, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: DualDateText(date: m.date, style: theme.textTheme.bodySmall),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${m.signedQuantity >= 0 ? "+" : ""}${numberFormat.format(m.signedQuantity)} ${product.unit ?? ""}'.trim(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: movementColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (m.unitCost != null)
                        Text(
                          '$effectiveCurrency ${numberFormat.format(m.unitCost)}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  onLongPress: () => _deleteMovement(m),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMovementModal(product),
        icon: const Icon(LucideIcons.arrowLeftRight),
        label: Text(l10n.addStockMovement),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
