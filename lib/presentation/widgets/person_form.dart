import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:uuid/uuid.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/data/models/currency_data.dart';
import 'package:aldeewan_mobile/presentation/widgets/currency_selector_sheet.dart';

class PersonForm extends ConsumerStatefulWidget {
  final Person? person;
  final Function(Person) onSave;

  const PersonForm({super.key, this.person, required this.onSave});

  @override
  ConsumerState<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends ConsumerState<PersonForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late PersonRole _role;
  /// null = use global app currency (default).
  /// When set, this person's balance and transactions are tracked in this currency.
  String? _currencyCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person?.name ?? '');
    _phoneController = TextEditingController(text: widget.person?.phone ?? '');
    _role = widget.person?.role ?? PersonRole.customer;
    _currencyCode = widget.person?.currencyCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l10n) {
    if (_formKey.currentState!.validate()) {
      final person = Person(
        id: widget.person?.id ?? const Uuid().v4(),
        role: _role,
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        createdAt: widget.person?.createdAt ?? DateTime.now(),
        currencyCode: _currencyCode,
      );
      widget.onSave(person);
      HapticFeedback.lightImpact();
      ToastService.showSuccess(context, l10n.savedSuccessfully);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appCurrency = ref.watch(currencyProvider);
    // Effective display: person's currency or app default
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.person == null ? l10n.addPerson : l10n.edit,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterName;
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                border: const OutlineInputBorder(),
                hintText: effectiveCurrency == 'SDG' ? '0912391234' : null,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (effectiveCurrency == 'SDG') {
                    if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
                      return 'Invalid phone number (Must be 10 digits starting with 0)';
                    }
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<PersonRole>(
              initialValue: _role,
              decoration: InputDecoration(
                labelText: l10n.role,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: PersonRole.customer,
                  child: Text(l10n.customer),
                ),
                DropdownMenuItem(
                  value: PersonRole.supplier,
                  child: Text(l10n.supplier),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _role = value;
                  });
                }
              },
            ),
            SizedBox(height: 12.h),
            // Currency picker — null means "use app default"
            InkWell(
              onTap: () async {
                final selected = await showDialog<String?>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.personCurrency),
                    content: Text(l10n.personCurrencyDialogBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, ''),
                        child: Text(l10n.useAppDefault),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx, 'pick');
                        },
                        child: Text(l10n.chooseCurrency),
                      ),
                    ],
                  ),
                );
                if (selected == 'pick') {
                  final code = await CurrencySelectorSheet.show(context, effectiveCurrency);
                  if (code != null) {
                    setState(() => _currencyCode = code);
                  }
                } else if (selected != null) {
                  // empty string = use app default
                  setState(() => _currencyCode = null);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.personCurrency,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Row(
                  children: [
                    Text(
                      currencyInfo.symbol,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _currencyCode == null
                            ? '${currencyInfo.name} (${l10n.appDefault})'
                            : currencyInfo.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      effectiveCurrency,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (_currencyCode != null && _currencyCode != appCurrency)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  l10n.personCurrencyNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: () => _save(l10n),
              child: Text(l10n.save),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
