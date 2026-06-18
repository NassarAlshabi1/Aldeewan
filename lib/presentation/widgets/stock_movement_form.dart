import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aldeewan_mobile/domain/entities/product.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:aldeewan_mobile/presentation/providers/inventory_provider.dart';

/// Modal form for recording a stock movement (inbound, outbound, or adjustment).
///
/// Validates that outbound movements don't exceed the current quantity on hand.
class StockMovementForm extends ConsumerStatefulWidget {
  final Product product;
  final double currentQuantityOnHand;
  final Function(StockMovement) onSave;

  const StockMovementForm({
    super.key,
    required this.product,
    required this.currentQuantityOnHand,
    required this.onSave,
  });

  @override
  ConsumerState<StockMovementForm> createState() => _StockMovementFormState();
}

class _StockMovementFormState extends ConsumerState<StockMovementForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _unitCostController;
  late TextEditingController _noteController;
  late StockMovementType _type;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _unitCostController = TextEditingController(
      text: widget.product.costPrice?.toStringAsFixed(2) ?? '',
    );
    _noteController = TextEditingController();
    _type = StockMovementType.inbound;
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text.replaceAll(',', ''));
    if (quantity == null || quantity <= 0) return;

    // Validate stock availability for outbound movements
    if (_type == StockMovementType.outbound || _type == StockMovementType.adjustmentOut) {
      if (quantity > widget.currentQuantityOnHand) {
        ToastService.showError(
          context,
          l10n.insufficientStock(
            widget.currentQuantityOnHand.toStringAsFixed(2),
            widget.product.unit ?? '',
          ),
        );
        return;
      }
    }

    final movement = StockMovement(
      id: generateInventoryId(),
      productId: widget.product.id,
      type: _type,
      quantity: quantity,
      unitCost: double.tryParse(_unitCostController.text.replaceAll(',', '')),
      date: _date,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      createdAt: DateTime.now(),
    );
    widget.onSave(movement);
    HapticFeedback.lightImpact();
    ToastService.showSuccess(context, l10n.savedSuccessfully);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addStockMovement,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                '${widget.product.name}'
                '${widget.product.sku != null ? " (${widget.product.sku})" : ""}'
                ' — ${l10n.quantityOnHand}: ${widget.currentQuantityOnHand.toStringAsFixed(2)}'
                '${widget.product.unit != null ? " ${widget.product.unit}" : ""}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Movement type selector
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _typeChip(l10n.inbound, StockMovementType.inbound, LucideIcons.arrowDownToLine, Colors.green),
                  _typeChip(l10n.outbound, StockMovementType.outbound, LucideIcons.arrowUpFromLine, Colors.red),
                  _typeChip(l10n.adjustmentIn, StockMovementType.adjustmentIn, LucideIcons.plus, Colors.blue),
                  _typeChip(l10n.adjustmentOut, StockMovementType.adjustmentOut, LucideIcons.minus, Colors.orange),
                ],
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantity,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(LucideIcons.scale),
                  suffixText: widget.product.unit ?? '',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: amountFormatters(allowFraction: true),
                validator: (v) {
                  final n = double.tryParse(v?.replaceAll(',', '') ?? '');
                  if (n == null || n <= 0) return l10n.pleaseEnterName;
                  return null;
                },
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: _unitCostController,
                decoration: InputDecoration(
                  labelText: l10n.unitCost,
                  border: const OutlineInputBorder(),
                  prefixText: '${widget.product.currencyCode ?? ''} ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: amountFormatters(allowFraction: true),
              ),
              SizedBox(height: 12.h),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.date,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(LucideIcons.calendar),
                  ),
                  child: Text(DateFormat.yMMMd().format(_date)),
                ),
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.movementNote,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(LucideIcons.text),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 24.h),

              FilledButton.icon(
                onPressed: () => _save(l10n),
                icon: const Icon(LucideIcons.check),
                label: Text(l10n.save),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, StockMovementType type, IconData icon, Color color) {
    final selected = _type == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.white : color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: selected,
      selectedColor: color,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
      onSelected: (_) => setState(() => _type = type),
    );
  }
}
