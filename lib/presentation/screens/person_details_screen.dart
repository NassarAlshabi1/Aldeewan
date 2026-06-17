import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/transaction_form.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_form.dart';
import 'package:aldeewan_mobile/presentation/widgets/delete_person_dialog.dart';
import 'package:aldeewan_mobile/presentation/widgets/dual_date_text.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/utils/transaction_label_mapper.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:go_router/go_router.dart';

class PersonDetailsScreen extends ConsumerWidget {
  final String personId;

  const PersonDetailsScreen({super.key, required this.personId});

  Future<void> _launchWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    var number = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddTransactionModal(BuildContext context, WidgetRef ref, Person person) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionForm(
        personId: person.id,
        personRole: person.role,
        initialType: person.role == PersonRole.customer
            ? TransactionType.saleOnCredit
            : TransactionType.purchaseOnCredit,
        onSave: (transaction) async {
          try {
            await ref.read(ledgerProvider.notifier).addTransaction(transaction);
          } catch (e) {
            if (context.mounted) {
              ToastService.showError(context, l10n.saveFailed);
            }
          }
        },
      ),
    );
  }

  void _showEditPersonModal(BuildContext context, WidgetRef ref, Person person) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PersonForm(
        person: person,
        onSave: (updatedPerson) async {
          try {
            await ref.read(ledgerProvider.notifier).addPerson(updatedPerson);
          } catch (e) {
            if (context.mounted) {
              ToastService.showError(context, l10n.saveFailed);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ledgerAsync = ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final isSimpleMode = ref.watch(settingsProvider);
    final currency = ref.watch(currencyProvider);
    final numberFormat = NumberFormat('#,##0.##');

    return ledgerAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.loading)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: Text(l10n.error)),
        body: Center(child: Text(l10n.errorOccurred(e.toString()))),
      ),
      data: (ledgerState) {
        final person = ledgerState.persons.firstWhere(
          (p) => p.id == personId,
          orElse: () => Person(
            id: 'not-found',
            role: PersonRole.customer,
            name: 'Not Found',
            createdAt: DateTime.now(),
          ),
        );

        if (person.id == 'not-found') {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.personNotFound)),
            body: Center(child: Text(l10n.personNotFound)),
          );
        }

        final transactions = ledgerState.transactions
            .where((t) => t.personId == personId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        final balance = notifier.calculatePersonBalance(person);
        
        // Determine balance color
        final isAsset = (person.role == PersonRole.customer && balance > 0) || 
                        (person.role == PersonRole.supplier && balance < 0);
        final isLiability = (person.role == PersonRole.supplier && balance > 0) || 
                            (person.role == PersonRole.customer && balance < 0);
        
        Color balanceColor = Theme.of(context).colorScheme.onSurface;
        if (balance != 0) {
          balanceColor = isAsset ? AppColors.success : (isLiability ? AppColors.error : Colors.grey);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(person.name),
            actions: [
              if (person.phone != null && person.phone!.isNotEmpty)
                IconButton(
                  icon: const Icon(LucideIcons.messageCircle),
                  onPressed: () => _launchWhatsApp(person.phone),
                ),
              IconButton(
                icon: const Icon(LucideIcons.edit),
                onPressed: () => _showEditPersonModal(context, ref, person),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DeletePersonDialog(
                      personId: person.id,
                      personName: person.name,
                      onDeleted: () => Navigator.of(context).pop(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.currentBalance,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currency ${numberFormat.format(balance.abs())}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: balanceColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              balance == 0 
                                  ? l10n.settled 
                                  : (person.role == PersonRole.customer 
                                      ? (balance > 0 ? l10n.receivable : l10n.advance) 
                                      : (balance > 0 ? l10n.payable : l10n.advance)),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (person.phone != null && person.phone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.phone, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      person.phone!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: transactions.isEmpty
                    ? EmptyState(
                        message: l10n.noEntriesYet,
                        icon: LucideIcons.history,
                        // TODO: Add 'assets/animations/empty_list.json'
                        lottieAsset: 'assets/animations/empty_list.json',
                        actionLabel: l10n.addTransaction,
                        onAction: () => _showAddTransactionModal(context, ref, person),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          // Logic for icon/color:
                          // Sale/Purchase (Debt increases) -> Arrow Up? Or specific icon.
                          // Payment (Debt decreases) -> Arrow Down?
                          
                          final isDebtIncrease = tx.type == TransactionType.saleOnCredit || 
                                                 tx.type == TransactionType.purchaseOnCredit ||
                                                 tx.type == TransactionType.debtGiven ||
                                                 tx.type == TransactionType.debtTaken;
                          
                          return Card(
                            margin: EdgeInsets.zero,
                            elevation: 0,
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                            ),
                            child: ListTile(
                              onTap: () {
                                context.push('/transaction', extra: tx);
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDebtIncrease
                                      ? AppColors.warning.withValues(alpha: 0.1)
                                      : AppColors.info.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isDebtIncrease
                                      ? LucideIcons.fileText
                                      : LucideIcons.banknote,
                                  color: isDebtIncrease ? AppColors.warning : AppColors.info,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                TransactionLabelMapper.getLabel(tx.type, isSimpleMode, l10n),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: DualDateText(
                                date: tx.date,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$currency ${numberFormat.format(tx.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: isDebtIncrease ? AppColors.warning : AppColors.info,
                                    ),
                                  ),
                                  if (tx.note != null && tx.note!.isNotEmpty)
                                    Text(
                                      tx.note!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTransactionModal(context, ref, person),
            label: Text(l10n.addTransaction),
            icon: const Icon(LucideIcons.plus),
          ),
        );
      },
    );
  }


}
