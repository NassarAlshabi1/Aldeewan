import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';
import 'package:aldeewan_mobile/utils/transaction_label_mapper.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/presentation/providers/home_provider.dart';
import 'package:aldeewan_mobile/domain/entities/product.dart';
import 'package:aldeewan_mobile/presentation/providers/inventory_provider.dart';

import 'package:aldeewan_mobile/domain/entities/person.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final TransactionType? initialType;
  final String? personId;
  final PersonRole? personRole;
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialNote;
  /// Currency code inherited from the person (if any).
  /// When null, falls back to the global app currency.
  final String? currencyCode;
  final Function(Transaction) onSave;

  const TransactionForm({
    super.key,
    this.initialType,
    this.personId,
    this.personRole,
    this.initialAmount,
    this.initialDate,
    this.initialNote,
    this.currencyCode,
    required this.onSave,
  });

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TransactionType _type;
  late DateTime _date;
  bool _isOpeningBalance = false;

  /// Optional: when the transaction is a sale (saleOnCredit or cashSale)
  /// the user can link it to a product from the inventory. Selecting a
  /// product auto-creates an outbound StockMovement on save, reducing
  /// the product's quantity on hand by [_stockQuantity].
  String? _linkedProductId;
  double _stockQuantity = 1;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount.toString() : ''
    );
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _type = widget.initialType ?? (widget.personRole == PersonRole.customer
        ? TransactionType.saleOnCredit
        : (widget.personRole == PersonRole.supplier
            ? TransactionType.purchaseOnCredit
            : TransactionType.saleOnCredit));
    _date = widget.initialDate ?? DateTime.now();
    // defaulting _isOpeningBalance to false
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    ref.read(soundServiceProvider).playClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (!mounted) return;
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_formKey.currentState!.validate()) {
      final cleanAmount = _amountController.text.replaceAll(',', '').replaceAll(' ', '');
      final amount = double.tryParse(cleanAmount);
      if (amount == null) return;

      // Check Balance Constraint for payment and lending transactions
      // (You can't pay or lend more than you have)
      if (_type == TransactionType.paymentMade || _type == TransactionType.debtGiven) {
        final currentBalance = ref.read(dashboardStatsProvider).net;
        if (currentBalance < amount) {
          final currency = ref.read(currencyProvider);
          final formatter = NumberFormat('#,##0.##');
          ToastService.showError(context, l10n.insufficientFundsMessage(
            formatter.format(currentBalance),
            currency,
            formatter.format(amount),
          ));
          return;
        }
      }

      final transaction = Transaction(
        id: const Uuid().v4(),
        type: _type,
        personId: widget.personId,
        amount: amount,
        date: _date,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        isOpeningBalance: _isOpeningBalance,
        // Inherit currency from the person, or fall back to the global app currency.
        currencyCode: widget.currencyCode ?? ref.read(currencyProvider),
      );
      widget.onSave(transaction);

      // If the user linked this sale to a product, auto-create an
      // outbound StockMovement that reduces the product's quantity on
      // hand. Only applies to sale types (cashSale, saleOnCredit).
      if (_linkedProductId != null &&
          (_type == TransactionType.saleOnCredit ||
              _type == TransactionType.cashSale)) {
        final inventoryState = ref.read(inventoryProvider);
        final linked = inventoryState.products
            .where((p) => p.product.id == _linkedProductId)
            .firstOrNull;
        if (linked != null) {
          // Validate stock availability for the requested quantity.
          if (_stockQuantity > linked.quantityOnHand) {
            if (mounted) {
              ToastService.showError(
                context,
                l10n.insufficientStock(
                  linked.quantityOnHand.toStringAsFixed(2),
                  linked.product.unit ?? '',
                ),
              );
            }
            return;
          }
          final movement = StockMovement(
            id: generateInventoryId(),
            productId: linked.product.id,
            type: StockMovementType.outbound,
            quantity: _stockQuantity,
            unitCost: linked.product.costPrice,
            personId: widget.personId,
            transactionId: transaction.id,
            date: _date,
            note: transaction.note,
            createdAt: DateTime.now(),
          );
          await ref.read(inventoryProvider.notifier).addStockMovement(movement);
        }
      }

      HapticFeedback.lightImpact();
      ToastService.showSuccess(context, l10n.savedSuccessfully);
      Navigator.of(context).pop();
    }
  }

  List<TransactionType> _getFilteredTypes() {
    if (widget.personRole == null) return TransactionType.values;
    
    if (widget.personRole == PersonRole.customer) {
      return [
        TransactionType.saleOnCredit,
        TransactionType.paymentReceived,
        TransactionType.debtGiven,
        TransactionType.debtTaken,
        TransactionType.paymentMade, // Returns/Refunds
      ];
    } else {
      // Supplier
      return [
        TransactionType.purchaseOnCredit,
        TransactionType.paymentMade,
        TransactionType.debtTaken,
        TransactionType.debtGiven,
        TransactionType.paymentReceived, // Returns/Refunds
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Effective currency: person-specific currency overrides the global default.
    final currency = widget.currencyCode ?? ref.watch(currencyProvider);
    final isSimpleMode = ref.watch(settingsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialAmount != null ? l10n.editTransaction : l10n.addTransaction,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.type,
                  border: const OutlineInputBorder(),
                ),
                items: _getFilteredTypes().map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(TransactionLabelMapper.getLabel(type, isSimpleMode, l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(soundServiceProvider).playClick();
                    setState(() {
                      _type = value;
                    });
                  }
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  border: const OutlineInputBorder(),
                  prefixText: '$currency ', 
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: amountFormatters(allowFraction: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAmount;
                  }
                  if (double.tryParse(value.replaceAll(',', '')) == null) {
                    return l10n.invalidNumber;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.date,
                    border: const OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            DateFormat.yMMMd().format(_date),
                          ),
                        ),
                      ),
                      const Icon(LucideIcons.calendar),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(height: 12.h),
              
              // Old Debt Checkbox (Only for DebtGiven/DebtTaken)
              if (_type == TransactionType.debtGiven || _type == TransactionType.debtTaken)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24.h,
                          width: 24.w,
                          child: Checkbox(
                            value: _isOpeningBalance,
                            onChanged: (value) {
                              setState(() {
                                _isOpeningBalance = value ?? false;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            l10n.oldDebt,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.info,
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.oldDebt),
                                content: Text(l10n.oldDebtExplanation),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.ok),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  border: const OutlineInputBorder(),
                ),
              ),
              // Link-to-product picker — only shown for sale transactions.
              // When the user picks a product and quantity, an outbound
              // StockMovement is auto-created on save, reducing that
              // product's quantity on hand.
              if (_type == TransactionType.saleOnCredit ||
                  _type == TransactionType.cashSale) ...[
                SizedBox(height: 12.h),
                _buildProductLinkRow(context, l10n),
              ],
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () { _save(l10n); },
                child: Text(l10n.save),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a row that lets the user optionally link this sale to a
  /// product from the inventory. Shows the product's current quantity
  /// on hand and a numeric input for the quantity being sold.
  Widget _buildProductLinkRow(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final inventoryState = ref.watch(inventoryProvider);
    final products = inventoryState.products;

    // Find the currently selected product (if any).
    final selected = _linkedProductId == null
        ? null
        : products.where((p) => p.product.id == _linkedProductId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: products.isEmpty
              ? null
              : () async {
                  final picked = await showModalBottomSheet<String?>(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.4,
                        maxChildSize: 0.95,
                        expand: false,
                        builder: (ctx, scrollController) => Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                l10n.product,
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: products.length,
                                itemBuilder: (ctx, index) {
                                  final item = products[index];
                                  return ListTile(
                                    leading: const Icon(LucideIcons.package),
                                    title: Text(item.product.name),
                                    subtitle: Text(
                                      '${l10n.quantityOnHand}: '
                                      '${item.quantityOnHand.toStringAsFixed(2)}'
                                      '${item.product.unit != null ? " ${item.product.unit}" : ""}',
                                    ),
                                    trailing: item.product.salePrice != null
                                        ? Text(
                                            '${widget.currencyCode ?? ""} '
                                            '${item.product.salePrice!.toStringAsFixed(2)}',
                                          )
                                        : null,
                                    onTap: () => Navigator.pop(ctx, item.product.id),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _linkedProductId = picked);
                  }
                },
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.product,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(LucideIcons.link),
              suffixIcon: _linkedProductId != null
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => setState(() => _linkedProductId = null),
                    )
                  : null,
            ),
            child: Text(
              selected == null
                  ? (products.isEmpty ? '—' : l10n.product)
                  : '${selected.product.name}'
                      ' (${selected.quantityOnHand.toStringAsFixed(2)}'
                      '${selected.product.unit != null ? " ${selected.product.unit}" : ""})',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        if (_linkedProductId != null) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.quantity,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: _stockQuantity.toStringAsFixed(0),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixText: selected?.product.unit ?? '',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: amountFormatters(allowFraction: true),
                  onChanged: (v) {
                    final n = double.tryParse(v.replaceAll(',', ''));
                    if (n != null && n > 0) {
                      setState(() => _stockQuantity = n);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
