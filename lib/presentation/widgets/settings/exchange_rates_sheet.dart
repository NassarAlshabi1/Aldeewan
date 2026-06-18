import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aldeewan_mobile/data/services/exchange_rate_service.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/data/models/currency_data.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';

/// A bottom sheet that lets the user define exchange rates between the
/// app's base currency and any other currency they use across persons.
///
/// Rates are stored as: 1 baseCurrency = X otherCurrency.
/// Used by the dashboard to show an estimated total across mixed currencies.
class ExchangeRatesSheet extends ConsumerStatefulWidget {
  const ExchangeRatesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ExchangeRatesSheet(),
    );
  }

  @override
  ConsumerState<ExchangeRatesSheet> createState() => _ExchangeRatesSheetState();
}

class _ExchangeRatesSheetState extends ConsumerState<ExchangeRatesSheet> {
  final Map<String, TextEditingController> _controllers = {};
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load(ExchangeRateService service) async {
    if (_loaded) return;
    await service.load();
    final rates = await service.getAllRates();
    for (final entry in rates.entries) {
      _controllers[entry.key] = TextEditingController(text: entry.value.toString());
    }
    _loaded = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final service = ref.watch(exchangeRateServiceProvider);
    final baseCurrency = service.baseCurrency;

    if (!_loaded) {
      _load(service);
    }

    // Show all currencies EXCEPT the base one.
    final editableCurrencies = supportedCurrencies.where((c) => c.code != baseCurrency).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(LucideIcons.arrowLeftRight, color: theme.colorScheme.primary),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.exchangeRates,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l10n.exchangeRatesSubtitle,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Base currency indicator
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.anchor, color: theme.colorScheme.primary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '${l10n.baseCurrency}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    baseCurrency,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // List of editable rates
            Expanded(
              child: editableCurrencies.isEmpty
                  ? Center(child: Text(l10n.noResults))
                  : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: editableCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = editableCurrencies[index];
                        _controllers.putIfAbsent(
                          currency.code,
                          () => TextEditingController(text: ''),
                        );
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  currency.symbol,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency.nameEn,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      l10n.rateHint(baseCurrency, currency.code),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              SizedBox(
                                width: 90.w,
                                child: TextField(
                                  controller: _controllers[currency.code],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: const OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 8.h,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Save button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: FilledButton.icon(
                onPressed: () async {
                  for (final entry in _controllers.entries) {
                    final value = double.tryParse(entry.value.text);
                    if (value != null && value > 0) {
                      await service.setRate(entry.key, value);
                    } else if (entry.value.text.isEmpty) {
                      await service.clearRate(entry.key);
                    }
                  }
                  if (context.mounted) {
                    ToastService.showSuccess(context, l10n.savedSuccessfully);
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(LucideIcons.check),
                label: Text(l10n.saveRate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
