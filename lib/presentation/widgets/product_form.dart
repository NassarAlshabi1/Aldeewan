import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aldeewan_mobile/domain/entities/product.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:aldeewan_mobile/data/models/currency_data.dart';
import 'package:aldeewan_mobile/presentation/widgets/currency_selector_sheet.dart';

/// Modal form for creating or editing a [Product].
class ProductForm extends ConsumerStatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const ProductForm({super.key, this.product, required this.onSave});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _categoryController;
  late TextEditingController _unitController;
  late TextEditingController _costPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _lowStockController;
  String? _currencyCode;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _unitController = TextEditingController(text: p?.unit ?? '');
    _costPriceController = TextEditingController(
      text: p?.costPrice?.toStringAsFixed(2) ?? '',
    );
    _salePriceController = TextEditingController(
      text: p?.salePrice?.toStringAsFixed(2) ?? '',
    );
    _lowStockController = TextEditingController(
      text: p?.lowStockThreshold?.toString() ?? '',
    );
    _currencyCode = p?.currencyCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _costPriceController.dispose();
    _salePriceController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      costPrice: double.tryParse(_costPriceController.text.replaceAll(',', '')),
      salePrice: double.tryParse(_salePriceController.text.replaceAll(',', '')),
      currencyCode: _currencyCode,
      lowStockThreshold: double.tryParse(_lowStockController.text.replaceAll(',', '')),
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
      isArchived: widget.product?.isArchived ?? false,
    );
    widget.onSave(product);
    HapticFeedback.lightImpact();
    ToastService.showSuccess(context, l10n.savedSuccessfully);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appCurrency = ref.watch(currencyProvider);
    final effectiveCurrency = _currencyCode ?? appCurrency;
    final currencyInfo = supportedCurrencies.firstWhere(
      (c) => c.code == effectiveCurrency,
      orElse: () => supportedCurrencies.first,
    );

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
                widget.product == null ? l10n.addProduct : l10n.editProduct,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.productName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(LucideIcons.package),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.pleaseEnterName : null,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      decoration: InputDecoration(
                        labelText: l10n.sku,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: l10n.category,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: InputDecoration(
                        labelText: l10n.unit,
                        hintText: 'kg / piece / box',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final code = await CurrencySelectorSheet.show(context, effectiveCurrency);
                        if (code != null) {
                          setState(() => _currencyCode = code);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.personCurrency,
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          '${currencyInfo.symbol} $effectiveCurrency',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      decoration: InputDecoration(
                        labelText: l10n.costPrice,
                        border: const OutlineInputBorder(),
                        prefixText: '$effectiveCurrency ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: amountFormatters(allowFraction: true),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration: InputDecoration(
                        labelText: l10n.salePrice,
                        border: const OutlineInputBorder(),
                        prefixText: '$effectiveCurrency ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: amountFormatters(allowFraction: true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _lowStockController,
                decoration: InputDecoration(
                  labelText: l10n.lowStockThreshold,
                  border: const OutlineInputBorder(),
                  helperText: l10n.lowStockThresholdHint,
                  prefixIcon: const Icon(LucideIcons.bell),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: amountFormatters(allowFraction: true),
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
}
