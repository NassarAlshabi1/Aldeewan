import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';

import 'package:aldeewan_mobile/presentation/widgets/cashbook/cashbook_list_item.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_entry_form.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/category_provider.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/presentation/providers/cashbook_provider.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/presentation/widgets/debounced_search_bar.dart';

import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';
import 'package:aldeewan_mobile/presentation/widgets/showcase_wrapper.dart';
import 'package:aldeewan_mobile/presentation/providers/guided_tour_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/filtered_transactions_provider.dart';
import 'package:showcaseview/showcaseview.dart';

class CashbookScreen extends ConsumerStatefulWidget {
  const CashbookScreen({super.key});

  @override
  ConsumerState<CashbookScreen> createState() => _CashbookScreenState();
}



class _CashbookScreenState extends ConsumerState<CashbookScreen> {  // REMOVED ShowcaseTourMixin

  bool _initialActionHandled = false;
  
  // Pagination: initial display count, increases on "Load More"
  static const int _pageSize = 50;
  int _displayCount = _pageSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialActionHandled) {
      final uri = GoRouterState.of(context).uri;
      final action = uri.queryParameters['action'];
      final filterParam = uri.queryParameters['filter'];
      
      // Handle filter query parameter (from dashboard cards)
      if (filterParam != null) {
        _initialActionHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (filterParam == 'income') {
            ref.read(cashFilterProvider.notifier).state = CashFilter.income;
          } else if (filterParam == 'expense') {
            ref.read(cashFilterProvider.notifier).state = CashFilter.expense;
          }
        });
      }
      
      // Handle add action query parameter (from receipt scanner)
      if (action == 'add') {
        _initialActionHandled = true;
        
        double? initialAmount;
        DateTime? initialDate;
        String? initialNote;

        if (uri.queryParameters.containsKey('amount')) {
          initialAmount = double.tryParse(uri.queryParameters['amount']!);
        }
        if (uri.queryParameters.containsKey('date')) {
          initialDate = DateTime.tryParse(uri.queryParameters['date']!);
        }
        initialNote = uri.queryParameters['note'];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showAddCashEntryModal(context, ref, initialAmount, initialDate, initialNote);
        });
      }
    }
    
    // Auto-start cashbook tour if guided tour is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tourNotifier = ref.read(guidedTourProvider.notifier);
      if (tourNotifier.canStartTourForScreen(TourScreen.cashbook)) {
        tourNotifier.markScreenTourStarted();
        _startCashbookShowcase();
      }
    });
  }
  
  void _startCashbookShowcase() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        try {
          // ignore: deprecated_member_use
          ShowCaseWidget.of(context).startShowCase(ShowcaseKeys.cashbookKeys);
        } catch (e) {
          debugPrint('Cashbook showcase error: $e');
        }
      }
    });
  }

  void _showAddCashEntryModal(
    BuildContext context, 
    WidgetRef ref, [
    double? initialAmount,
    DateTime? initialDate,
    String? initialNote,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CashEntryForm(
        initialAmount: initialAmount,
        initialDate: initialDate,
        initialNote: initialNote,
        onSave: (transaction) {
          ref.read(soundServiceProvider).playMoneyIn();
          ref.read(ledgerProvider.notifier).addTransaction(transaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final computedAsync = ref.watch(filteredTransactionsProvider);
    final ledgerAsync = ref.watch(ledgerProvider); // Display lookup
    final currency = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,##0.##');
    final localCategories = ref.watch(categoryProvider);
    
    // UI state watchers that don't affect filtering (since filtering is now in provider)
    // Note: Search & Filter updates trigger provider rebuild
    final searchQuery = ref.watch(cashbookSearchProvider);
    final datePreset = ref.watch(dateRangePresetProvider);
    final filter = ref.watch(cashFilterProvider);

    return computedAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.errorOccurred(e.toString())))),
      data: (computedState) {
        // Pre-computed data from provider
        final filteredTransactions = computedState.transactions;
        final totalIn = computedState.totalIn;
        final totalOut = computedState.totalOut;
        final net = computedState.net;



        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.cashbook),
          ),
          resizeToAvoidBottomInset: false,
          body: Column(
              children: [
                // Search bar - Tour Step 8
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  child: ShowcaseTarget(
                    showcaseKey: ShowcaseKeys.searchBar,
                    title: l10n.tour8Title,
                    description: l10n.tour8Desc,
                    child: DebouncedSearchBar(
                      hintText: l10n.search,
                      onSearch: (query) {
                        ref.read(cashbookSearchProvider.notifier).state = query;
                      },
                    ),
                  ),
                ),
                // Compact filter row with 2 dropdowns - Tour Step 7
                ShowcaseTarget(
                  showcaseKey: ShowcaseKeys.cashbookFilter,
                  title: l10n.tour7Title,
                  description: l10n.tour7Desc,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                    child: Row(
                      children: [
                      // Type filter dropdown
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CashFilter>(
                              value: filter,
                              isExpanded: true,
                              icon: Icon(LucideIcons.chevronDown, size: 18.sp, color: theme.colorScheme.onSurfaceVariant),
                              items: [
                                DropdownMenuItem(
                                  value: CashFilter.all,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.list, size: 16.sp, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.allTransactions))),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: CashFilter.income,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.arrowDownLeft, size: 16.sp, color: AppColors.success),
                                      SizedBox(width: 8.w),
                                      Text(l10n.income),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: CashFilter.expense,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.arrowUpRight, size: 16.sp, color: AppColors.error),
                                      SizedBox(width: 8.w),
                                      Text(l10n.expense),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(cashFilterProvider.notifier).state = value;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Date filter dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<DateRangePreset>(
                              value: datePreset,
                              isExpanded: true,
                              icon: Icon(LucideIcons.chevronDown, size: 18, color: theme.colorScheme.onSurfaceVariant),
                              items: [
                                DropdownMenuItem(
                                  value: DateRangePreset.all,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.infinity, size: 16.sp, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.all))),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.today,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendarCheck, size: 16.sp, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Text(l10n.today),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.thisWeek,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendarDays, size: 16.sp, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Text(l10n.thisWeek),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.thisMonth,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendar, size: 16.sp, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Text(l10n.thisMonth),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: DateRangePreset.custom,
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendarRange, size: 16.sp, color: theme.colorScheme.primary),
                                      SizedBox(width: 8.w),
                                      Text(datePreset == DateRangePreset.custom 
                                          ? _formatDateRange(ref.watch(customDateRangeProvider))
                                          : l10n.custom),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) async {
                                if (value == DateRangePreset.custom) {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    initialDateRange: ref.read(customDateRangeProvider),
                                  );
                                  if (picked != null) {
                                    ref.read(customDateRangeProvider.notifier).state = picked;
                                    ref.read(dateRangePresetProvider.notifier).state = DateRangePreset.custom;
                                  }
                                } else if (value != null) {
                                  ref.read(dateRangePresetProvider.notifier).state = value;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
                // Summary bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          context,
                          label: l10n.income,
                          value: totalIn,
                          color: AppColors.success,
                          currency: currency,
                          formatter: numberFormat,
                        ),
                        _buildSummaryItem(
                          context,
                          label: l10n.expense,
                          value: totalOut,
                          color: AppColors.error,
                          currency: currency,
                          formatter: numberFormat,
                        ),
                        _buildSummaryItem(
                          context,
                          label: l10n.net,
                          value: net,
                          color: net >= 0 ? AppColors.success : AppColors.error,
                          currency: currency,
                          formatter: numberFormat,
                        ),
                      ],
                    ),
                  ),
                ),
                // Mixed-currency indicator: shows when the current list
                // contains at least one transaction whose currency differs
                // from the app default. The summary above sums raw amounts
                // across currencies, so we flag it as an estimate.
                if (filteredTransactions.any(
                  (t) => t.currencyCode != null && t.currencyCode != currency,
                ))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.mixedTotalNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 8.h),
                // Filter transactions tip
                const FilterTransactionsTip(),
                const Divider(height: 1),
                // List of transactions
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? EmptyState(
                          message: searchQuery.isNotEmpty ? l10n.noResults : l10n.noEntriesYet,
                          icon: LucideIcons.history,
                          lottieAsset: 'assets/animations/empty_list.json',
                        )
                      : _buildPaginatedList(
                          context: context,
                          theme: theme,
                          l10n: l10n,
                          filteredTransactions: filteredTransactions,
                          ledgerAsync: ledgerAsync,
                          categories: localCategories,
                          currency: currency,
                          numberFormat: numberFormat,
                        ),
                ),
              ],
            ),
      floatingActionButton: filteredTransactions.isEmpty && ref.watch(cashbookSearchProvider).isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddCashEntryModal(context, ref),
              tooltip: l10n.addTransaction,
              child: Icon(Icons.add, size: 24.sp),
            ),
    );
      },
    );
  }

  /// Builds a paginated ListView with "Load More" button
  Widget _buildPaginatedList({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
    required List<Transaction> filteredTransactions,
    required AsyncValue<dynamic> ledgerAsync,
    required List<dynamic> categories,
    required String currency,
    required NumberFormat numberFormat,
  }) {
    // Reset display count if filter changed and list is smaller
    final effectiveDisplayCount = _displayCount.clamp(0, filteredTransactions.length);
    final displayedTransactions = filteredTransactions.take(effectiveDisplayCount).toList();
    final hasMore = filteredTransactions.length > effectiveDisplayCount;
    final remaining = filteredTransactions.length - effectiveDisplayCount;
    
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      // +1 for Load More button if there are more items
      itemCount: displayedTransactions.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Load More button at the end
        if (index == displayedTransactions.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _displayCount += _pageSize;
                  });
                },
                icon: Icon(LucideIcons.chevronsDown, size: 18.sp),
                label: Text(
                  '${l10n.loadMore} ($remaining ${l10n.moreItems})',
                ),
              ),
            ),
          );
        }
        
        final tx = displayedTransactions[index];
        
        String? personName;
        if (tx.personId != null) {
          final persons = ledgerAsync.value?.persons ?? [];
          // Use firstWhereOrNull to avoid StateError if the person was deleted.
          final person = persons.firstWhereOrNull((p) => p.id == tx.personId);
          if (person != null) {
            personName = person.name;
          }
        }

        // Find category
        final category = categories.where((c) => c.name == tx.category).firstOrNull;

        return CashbookListItem(
          transaction: tx,
          personName: personName,
          category: category,
          currency: currency,
          numberFormat: numberFormat,
          getTransactionLabel: _getTransactionLabel,
        );
      },
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    required String currency,
    required NumberFormat formatter,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$currency ${formatter.format(value)}',
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  String _getTransactionLabel(TransactionType type, AppLocalizations l10n) {
    switch (type) {
      case TransactionType.paymentReceived:
        return l10n.paymentReceived;
      case TransactionType.paymentMade:
        return l10n.paymentMade;
      case TransactionType.cashSale:
        return l10n.cashLabel; // نقد - Cash
      case TransactionType.cashIncome:
        return l10n.bankLabel; // بنك - Bank
      case TransactionType.cashExpense:
        return l10n.expense;
      case TransactionType.debtGiven:
        return l10n.debtGiven;
      case TransactionType.debtTaken:
        return l10n.debtTaken;
      default:
        return l10n.transaction;
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return '';
    final formatter = DateFormat.MMMd();
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }
}
