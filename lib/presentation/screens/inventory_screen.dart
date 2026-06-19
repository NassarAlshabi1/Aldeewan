import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/utils/pdf_inventory_exporter.dart';
import 'package:aldeewan_mobile/utils/error_handler.dart';
import 'package:aldeewan_mobile/presentation/providers/inventory_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/presentation/widgets/product_form.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/presentation/widgets/debounced_search_bar.dart';

/// Lists all products with their quantity on hand, low-stock alerts, and
/// stock value. Includes a search bar and aggregate totals at the top.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';

  void _showAddProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductForm(
        onSave: (product) async {
          // Generate ID if empty (new product)
          final p = product.id.isEmpty
              ? product.copyWith(id: generateInventoryId())
              : product;
          await ref.read(inventoryProvider.notifier).addProduct(p);
        },
      ),
    );
  }

  /// Exports the current inventory snapshot to a PDF file and shares it.
  /// The PDF includes summary band (totals, low-stock count, value) plus
  /// a full table of all products with their quantities, prices,
  /// thresholds, status, and stock value.
  Future<void> _exportPdf(AppLocalizations l10n) async {
    try {
      final state = ref.read(inventoryProvider);
      if (state.products.isEmpty) return;

      await PdfInventoryExporter.export(
        products: state.products,
        baseCurrency: ref.read(currencyProvider),
        appTitle: l10n.inventory,
        subtitle: l10n.inventorySubtitle,
        statusLabel: (isLow, isOut) =>
            isOut ? l10n.outOfStock : (isLow ? l10n.lowStock : l10n.inStock),
        labels: {
          'name': l10n.productName,
          'sku': l10n.sku,
          'qty': l10n.quantityOnHand,
          'cost': l10n.costPrice,
          'sale': l10n.salePrice,
          'threshold': l10n.lowStockThreshold,
          'status': l10n.movementType, // 'Status' header fallback
          'value': l10n.stockValue,
          'totalProducts': l10n.totalProducts,
          'lowStock': l10n.lowStockItems,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorOccurred(
            ErrorHandler.getUserFriendlyErrorMessage(e, l10n),
          ))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final state = ref.watch(inventoryProvider);
    final formatter = NumberFormat('#,##0.##');

    // Filter products by search query (name, SKU, category)
    final filtered = state.products.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.product.name.toLowerCase().contains(q) ||
          (p.product.sku?.toLowerCase().contains(q) ?? false) ||
          (p.product.category?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Aggregates
    final totalProducts = state.products.length;
    final lowStockCount = state.products.where((p) => p.isLowStock).length;
    double totalStockValue = 0;
    for (final p in state.products) {
      final cost = p.product.costPrice ?? 0;
      totalStockValue += p.quantityOnHand * cost;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventory),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.fileText),
            tooltip: l10n.exportPdf,
            onPressed: state.products.isEmpty ? null : () => _exportPdf(l10n),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  child: DebouncedSearchBar(
                    hintText: l10n.searchProducts,
                    onSearch: (q) => setState(() => _searchQuery = q),
                  ),
                ),

                // Summary cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: l10n.totalProducts,
                          value: totalProducts.toString(),
                          icon: LucideIcons.package,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _SummaryCard(
                          label: l10n.lowStockItems,
                          value: lowStockCount.toString(),
                          icon: LucideIcons.alertTriangle,
                          color: lowStockCount > 0 ? AppColors.error : AppColors.success,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _SummaryCard(
                          label: l10n.stockValue,
                          value: '$currency ${formatter.format(totalStockValue)}',
                          icon: LucideIcons.banknote,
                          color: AppColors.success,
                          small: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // Product list
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyState(
                          message: state.products.isEmpty
                              ? l10n.noProductsYet
                              : l10n.noResults,
                          icon: LucideIcons.package,
                          lottieAsset: 'assets/animations/empty_list.json',
                          actionLabel: state.products.isEmpty ? l10n.addProduct : null,
                          onAction: state.products.isEmpty ? _showAddProductModal : null,
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final product = item.product;
                            final qty = item.quantityOnHand;
                            final isOut = qty <= 0;
                            final statusColor = isOut
                                ? AppColors.error
                                : (item.isLowStock ? AppColors.warning : AppColors.success);
                            final statusLabel = isOut
                                ? l10n.outOfStock
                                : (item.isLowStock ? l10n.lowStock : l10n.inStock);

                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(
                                  color: theme.dividerColor.withValues(alpha: 0.05),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                leading: Container(
                                  width: 44.w,
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(LucideIcons.package, color: statusColor),
                                ),
                                title: Text(
                                  product.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (product.sku != null || product.category != null)
                                      Text(
                                        [
                                          if (product.sku != null) product.sku!,
                                          if (product.category != null) product.category!,
                                        ].join(' • '),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    Row(
                                      children: [
                                        Text(
                                          '$qty ${product.unit ?? ""}'.trim(),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            statusLabel,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  product.salePrice != null
                                      ? '$currency ${formatter.format(product.salePrice)}'
                                      : '—',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                onTap: () => context.push('/inventory/${product.id}'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductModal,
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.addProduct),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool small;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: (small ? theme.textTheme.bodyMedium : theme.textTheme.titleMedium)
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
