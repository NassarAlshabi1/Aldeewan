import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/transaction_form.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/utils/transaction_label_mapper.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_entry_form.dart';
import 'package:aldeewan_mobile/presentation/widgets/dual_date_text.dart';
import 'package:aldeewan_mobile/presentation/widgets/common/info_row.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final isSimpleMode = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.paymentReceived ||
        transaction.type == TransactionType.cashSale ||
        transaction.type == TransactionType.cashIncome ||
        transaction.type == TransactionType.debtTaken;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionDetails),
        actions: [
          Semantics(
            label: l10n.deleteTransaction,
            button: true,
            child: IconButton(
              icon: const Icon(LucideIcons.trash2),
              tooltip: l10n.delete,
              onPressed: () => _confirmDelete(context, ref, l10n),
            ),
          ),
          Semantics(
            label: l10n.editTransaction,
            button: true,
            child: IconButton(
              icon: const Icon(LucideIcons.pencil),
              tooltip: l10n.edit,
              onPressed: () => _showEditModal(context, ref),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Hero
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.amount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency ${NumberFormat('#,##0.##').format(transaction.amount)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      TransactionLabelMapper.getLabel(transaction.type, isSimpleMode, l10n),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  if (transaction.isOpeningBalance)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.history, size: 14, color: theme.colorScheme.onSecondaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            l10n.oldDebt,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Direction Indicator
                  Consumer(
                    builder: (context, ref, _) {
                      final ledger = ref.watch(ledgerProvider);
                      return ledger.maybeWhen(
                        data: (state) {
                          final person = state.persons
                              .where((p) => p.id == transaction.personId)
                              .firstOrNull;
                          return _buildDirectionIndicator(context, transaction, l10n, person?.name);
                        },
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Details Grid
            InfoRow(
              icon: LucideIcons.calendar,
              label: l10n.date,
              customValue: DualDateText(
                date: transaction.date,
                style: theme.textTheme.bodyLarge,
                format: 'yMMMMEEEEd',
              ),
            ),
            if (transaction.category != null) ...[
              const SizedBox(height: 24),
              InfoRow(
                icon: LucideIcons.tag,
                label: l10n.category,
                value: CategoryHelper.getLocalizedCategory(transaction.category!, l10n),
              ),
            ],
            if (transaction.personId != null) ...[
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, _) {
                  final ledger = ref.watch(ledgerProvider);
                  return ledger.maybeWhen(
                    data: (state) {
                      final person = state.persons
                          .where((p) => p.id == transaction.personId)
                          .firstOrNull;
                      return InfoRow(
                        icon: LucideIcons.user,
                        label: l10n.person,
                        value: person?.name ?? 'Unknown',
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ],
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              const SizedBox(height: 24),
              InfoRow(
                icon: LucideIcons.stickyNote,
                label: l10n.note,
                value: transaction.note!,
              ),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildDirectionIndicator(BuildContext context, Transaction tx, AppLocalizations l10n, String? personName) {
    final theme = Theme.of(context);
    String from;
    String to;
    IconData icon = LucideIcons.arrowRight;

    // Logic for direction
    // You = l10n.me (Need to add 'me' key or use 'You')
    // Person = personName ?? 'Unknown'
    // External = 'External' (or specific logic)

    final you = l10n.me;
    
    final other = personName ?? (tx.personId != null ? l10n.unknown : l10n.general);

    switch (tx.type) {
      case TransactionType.saleOnCredit: // We gave goods (Value), they owe us. Debt (Us).
      case TransactionType.debtGiven:
        // Context: "Lent" -> You gave to Them.
        from = you;
        to = other;
        break;
      case TransactionType.purchaseOnCredit: // We got goods, we owe them. Debt (Them).
      case TransactionType.debtTaken:
        // Context: "Borrowed" -> They gave to You.
        from = other;
        to = you;
        break;
      case TransactionType.paymentReceived: // They paid us.
        from = other;
        to = you;
        break;
      case TransactionType.paymentMade: // We paid them.
        from = you;
        to = other;
        break;
      case TransactionType.cashSale: // We sold for cash.
        from = other; // Money came from customer
        to = you;
        break;
      case TransactionType.cashIncome:
        from = l10n.general;
        to = you;
        break;
      case TransactionType.cashExpense:
        from = you;
        to = l10n.general;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(from, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(to, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    // Capture the screen's navigator before showing the dialog
    final screenNavigator = Navigator.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              // 1. Close dialog first
              Navigator.of(dialogContext).pop();
              
              // 2. Perform delete action
              ref.read(soundServiceProvider).playDelete();
              HapticFeedback.heavyImpact();
              await ref.read(ledgerProvider.notifier).deleteTransaction(transaction.id);
              
              // 3. Navigate back using the screen's navigator (captured before dialog)
              if (screenNavigator.mounted) {
                screenNavigator.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref) {
    if (transaction.personId != null) {
      // It's a Ledger Transaction
      final ledger = ref.read(ledgerProvider).value;
      final person = ledger?.persons.where((p) => p.id == transaction.personId).firstOrNull;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => TransactionForm(
          initialAmount: transaction.amount,
          initialDate: transaction.date,
          initialNote: transaction.note,
          initialType: transaction.type,
          personId: transaction.personId,
          personRole: person?.role,
          currencyCode: person?.currencyCode ?? transaction.currencyCode,
          onSave: (updatedTx) {
             // Create a new transaction that preserves the original ID for "update"
             final preservationTx = Transaction(
               id: transaction.id, // Preserving ID!
               type: updatedTx.type,
               personId: updatedTx.personId,
               amount: updatedTx.amount,
               date: updatedTx.date,
               note: updatedTx.note,
               category: updatedTx.category,
               goalId: updatedTx.goalId,
               isOpeningBalance: updatedTx.isOpeningBalance,
             );
             ref.read(ledgerProvider.notifier).updateTransaction(preservationTx);
             Navigator.pop(context); // Close the details screen
          },
        ),
      );
    } else {
      // It's a Cashbook Transaction
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => CashEntryForm(
          initialAmount: transaction.amount,
          initialDate: transaction.date,
          initialNote: transaction.note,
          onSave: (updatedTx) {
             // Preserve ID
             final preservationTx = Transaction(
               id: transaction.id,
               type: updatedTx.type,
               personId: updatedTx.personId,
               amount: updatedTx.amount,
               date: updatedTx.date,
               note: updatedTx.note,
               category: updatedTx.category,
               goalId: updatedTx.goalId,
               isOpeningBalance: updatedTx.isOpeningBalance,
             );
             ref.read(ledgerProvider.notifier).updateTransaction(preservationTx);
             Navigator.pop(context);
          },
        ),
      );
    }
  }
}
