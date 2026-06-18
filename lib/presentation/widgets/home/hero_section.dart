import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/home_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/hero_balance_card.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);
    final range = ref.watch(summaryRangeProvider);

    // Use monthly income/expense for Net Position (actual cash flow)
    final monthlyIncome = ref.watch(monthlyIncomeProvider);
    final monthlyExpense = ref.watch(monthlyExpenseProvider);
    final netPosition = monthlyIncome - monthlyExpense;

    // Detect if any person uses a non-default currency. When true, the net
    // position shown is an approximation (sum of mixed currencies converted
    // to the base currency using the user's FX rates).
    final ledger = ref.watch(ledgerProvider).value;
    final hasMixedCurrencies = ledger != null &&
        ledger.persons.any((p) => p.currencyCode != null && p.currencyCode != currency);

    final netSubtitle = netPosition >= 0 ? l10n.profitThisMonth : l10n.lossThisMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Range filter chips
        Row(
          children: [
            ChoiceChip(
              label: Text(l10n.all),
              selected: range == SummaryRange.all,
              onSelected: (_) {
                ref.read(summaryRangeProvider.notifier).state = SummaryRange.all;
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(l10n.thisMonth),
              selected: range == SummaryRange.month,
              onSelected: (_) {
                ref.read(summaryRangeProvider.notifier).state = SummaryRange.month;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Hero net balance card
        HeroBalanceCard(
          title: l10n.netPosition,
          subtitle: netSubtitle,
          rawAmount: netPosition,
          currencyCode: currency,
          isPositive: netPosition >= 0,
        ),
        if (hasMixedCurrencies)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.mixedTotalNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

