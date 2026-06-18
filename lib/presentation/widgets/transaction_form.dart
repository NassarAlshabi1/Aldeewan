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

  void _save(AppLocalizations l10n) {
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
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => _save(l10n),
                child: Text(l10n.save),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
