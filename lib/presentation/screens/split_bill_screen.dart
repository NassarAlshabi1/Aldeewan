import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/domain/repositories/transaction_repository.dart';

/// Screen that splits a bill between N people by equal shares, weighted
/// shares, or exact amounts. Each share is persisted as a separate
/// `debtGiven` transaction linked to the chosen person.
class SplitBillScreen extends ConsumerStatefulWidget {
  const SplitBillScreen({super.key});

  @override
  ConsumerState<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends ConsumerState<SplitBillScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  SplitMode _mode = SplitMode.equal;
  final Map<String, double> _shares = {}; // personId → share value
  final Set<String> _selected = {}; // personId

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ledgerAsync = ref.watch(ledgerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.splitBill),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronRight),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ledgerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (ledger) {
          final persons = ledger.persons.where((p) => !p.isArchived).toList();
          final totalAmount = double.tryParse(
                  _amountCtrl.text.replaceAll(',', '')) ??
              0;

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.totalAmount, style: theme.textTheme.titleMedium),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _amountCtrl,
                        decoration: InputDecoration(
                          prefixText: 'SDG ',
                          hintText: '0.00',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: amountFormatters(allowFraction: true),
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _noteCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.note,
                          hintText: 'Dinner / groceries / outing …',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Split-mode segmented control.
              SegmentedButton<SplitMode>(
                segments: [
                  ButtonSegment(value: SplitMode.equal, label: Text(l10n.equal)),
                  ButtonSegment(
                      value: SplitMode.percentage,
                      label: Text(l10n.percentage)),
                  ButtonSegment(value: SplitMode.exact, label: Text(l10n.exact)),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              SizedBox(height: 12.h),
              Text('${l10n.participants} (${_selected.length})',
                  style: theme.textTheme.titleMedium),
              SizedBox(height: 8.h),
              ...persons.map((p) {
                final isSelected = _selected.contains(p.id);
                final share = _shares[p.id] ?? 0;
                final computedShare = _computeShare(totalAmount, p.id);
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(p.id);
                          } else {
                            _selected.remove(p.id);
                            _shares.remove(p.id);
                          }
                        });
                      },
                    ),
                    title: Text(p.name),
                    subtitle: Text(_mode == SplitMode.equal
                        ? '${l10n.share}: ${computedShare.toStringAsFixed(2)}'
                        : '${l10n.share}: ${share.toStringAsFixed(2)}'
                            '${_mode == SplitMode.percentage ? '%' : ''}'),
                    trailing: _mode == SplitMode.equal
                        ? null
                        : SizedBox(
                            width: 100.w,
                            child: TextField(
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters:
                                  amountFormatters(allowFraction: true),
                              decoration: InputDecoration(
                                suffixText:
                                    _mode == SplitMode.percentage ? '%' : '',
                              ),
                              enabled: isSelected,
                              onChanged: (v) {
                                final parsed =
                                    double.tryParse(v.replaceAll(',', ''));
                                setState(() {
                                  _shares[p.id] = parsed ?? 0;
                                });
                              },
                            ),
                          ),
                  ),
                );
              }),
              SizedBox(height: 24.h),
              _buildSummary(theme, l10n, totalAmount),
              SizedBox(height: 12.h),
              FilledButton.icon(
                onPressed: _selected.isEmpty || totalAmount <= 0
                    ? null
                    : () => _save(context, ref, ledger.persons),
                icon: const Icon(LucideIcons.check),
                label: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  double _computeShare(double totalAmount, String personId) {
    if (_selected.isEmpty) return 0;
    switch (_mode) {
      case SplitMode.equal:
        return totalAmount / _selected.length;
      case SplitMode.percentage:
      case SplitMode.exact:
        return _shares[personId] ?? 0;
    }
  }

  Widget _buildSummary(
      ThemeData theme, AppLocalizations l10n, double totalAmount) {
    final allocated = _selected.fold<double>(
        0, (a, id) => a + _computeShare(totalAmount, id));
    final remaining = totalAmount - allocated;
    final isComplete = remaining.abs() < 0.01;
    return Card(
      color: isComplete
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isComplete ? l10n.fullyAllocated : l10n.remaining,
                style: theme.textTheme.titleMedium),
            Text(
              remaining.toStringAsFixed(2),
              style: theme.textTheme.titleLarge?.copyWith(
                color: isComplete ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
      BuildContext context, WidgetRef ref, List<Person> persons) async {
    final l10n = AppLocalizations.of(context)!;
    final totalAmount = double.tryParse(
            _amountCtrl.text.replaceAll(',', '')) ??
        0;
    if (totalAmount <= 0) return;

    final note = _noteCtrl.text.trim();
    final txnRepo = ref.read(transactionRepositoryProvider);
    final now = DateTime.now();

    try {
      for (final personId in _selected) {
        final share = _computeShare(totalAmount, personId);
        if (share <= 0) continue;
        final person =
            persons.firstWhereOrNull((p) => p.id == personId);
        final personName = person?.name ?? 'Unknown';
        await txnRepo.addTransaction(Transaction(
          id: const Uuid().v4(),
          type: TransactionType.debtGiven,
          amount: share,
          date: now,
          personId: personId,
          category: 'Split Bill',
          note: note.isEmpty ? 'Split bill with $personName' : '$note ($personName)',
        ));
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.splitBillSaved)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

enum SplitMode { equal, percentage, exact }
