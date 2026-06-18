import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_form.dart';
import 'package:aldeewan_mobile/presentation/widgets/transaction_form.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/presentation/widgets/debounced_search_bar.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';
import 'package:aldeewan_mobile/presentation/widgets/showcase_wrapper.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_sort_provider.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:aldeewan_mobile/presentation/providers/guided_tour_provider.dart';
import 'package:showcaseview/showcaseview.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialActionHandled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialActionHandled) {
      final uri = GoRouterState.of(context).uri;
      final action = uri.queryParameters['action'];
      final tab = uri.queryParameters['tab'];
      final filter = uri.queryParameters['filter'];
      
      // Handle tab switching
      if (tab == 'suppliers' && _tabController.index != 1) {
        Future.microtask(() => _tabController.animateTo(1));
      } else if (tab == 'customers' && _tabController.index != 0) {
        Future.microtask(() => _tabController.animateTo(0));
      }
      
      // Handle balance filter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (filter == 'owes') {
          ref.read(ledgerBalanceFilterProvider.notifier).state = 'owes';
        } else {
          ref.read(ledgerBalanceFilterProvider.notifier).state = 'all';
        }
      });
      
      if (action == 'debt' || action == 'payment' || action == 'scan') {
        _initialActionHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleQuickAction(action!);
        });
      }
    }
    
    // Auto-start ledger tour if guided tour is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tourNotifier = ref.read(guidedTourProvider.notifier);
      if (tourNotifier.canStartTourForScreen(TourScreen.ledger)) {
        tourNotifier.markScreenTourStarted();
        _startLedgerShowcase();
      }
    });
  }
  
  void _startLedgerShowcase() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        try {
          // ignore: deprecated_member_use
          ShowCaseWidget.of(context).startShowCase(ShowcaseKeys.ledgerKeys);
        } catch (e) {
          debugPrint('Ledger showcase error: $e');
        }
      }
    });
  }

  void _handleQuickAction(String action) {
    final l10n = AppLocalizations.of(context)!;
    final ledgerAsync = ref.read(ledgerProvider);
    final persons = ledgerAsync.value?.persons ?? [];

    double? initialAmount;
    DateTime? initialDate;
    String? initialNote;

    if (action == 'scan') {
      final uri = GoRouterState.of(context).uri;
      if (uri.queryParameters.containsKey('amount')) {
        initialAmount = double.tryParse(uri.queryParameters['amount']!);
      }
      if (uri.queryParameters.containsKey('date')) {
        initialDate = DateTime.tryParse(uri.queryParameters['date']!);
      }
      initialNote = uri.queryParameters['note'];
    }

    if (persons.isEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: EdgeInsets.all(24.0.w),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.users, size: 48.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                l10n.noPersonsFound,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.addPersonPrompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddPersonModal(context);
                },
                icon: const Icon(LucideIcons.userPlus),
                label: Text(l10n.addPerson),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      );
      return;
    }

    // Determine modal title based on action
    String modalTitle;
    if (action == 'debt') {
      modalTitle = l10n.customer; // "Select Customer" for debt
    } else if (action == 'payment') {
      modalTitle = l10n.supplier; // "Select Supplier" for payment
    } else {
      modalTitle = l10n.selectPerson;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Text(
              '${l10n.selectPerson} - $modalTitle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                // Re-watch in case it changes while open (unlikely but good practice)
                final ledgerAsync = ref.watch(ledgerProvider);
                final currentPersons = ledgerAsync.value?.persons ?? [];
                
                // Filter persons based on action type
                final filteredPersons = action == 'debt' 
                    ? currentPersons.where((p) => p.role == PersonRole.customer).toList()
                    : action == 'payment'
                        ? currentPersons.where((p) => p.role == PersonRole.supplier).toList()
                        : currentPersons;
                
                return ListView.builder(
                  itemCount: filteredPersons.length,
                  itemBuilder: (context, index) {
                    final person = filteredPersons[index];
                    return ListTile(
                      title: Text(person.name),
                      subtitle: Text(person.role == PersonRole.customer ? l10n.customer : l10n.supplier),
                      onTap: () {
                        Navigator.pop(context); // Close selector
                        _showTransactionModal(
                          person,
                          action,
                          initialAmount: initialAmount,
                          initialDate: initialDate,
                          initialNote: initialNote,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionModal(
    Person person,
    String action, {
    double? initialAmount,
    DateTime? initialDate,
    String? initialNote,
  }) {
    TransactionType type;
    if (action == 'debt') {
      type = person.role == PersonRole.customer
          ? TransactionType.saleOnCredit
          : TransactionType.purchaseOnCredit;
    } else if (action == 'payment') {
      type = person.role == PersonRole.customer
          ? TransactionType.paymentReceived
          : TransactionType.paymentMade;
    } else {
      // Default for scan or other actions
      type = person.role == PersonRole.customer
          ? TransactionType.saleOnCredit
          : TransactionType.purchaseOnCredit;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionForm(
        personId: person.id,
        personRole: person.role,
        currencyCode: person.currencyCode,
        initialType: type,
        initialAmount: initialAmount,
        initialDate: initialDate,
        initialNote: initialNote,
        onSave: (transaction) {
          ref.read(soundServiceProvider).playSuccess();
          ref.read(ledgerProvider.notifier).addTransaction(transaction);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPersonModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PersonForm(
        onSave: (person) async {
          try {
            await ref.read(ledgerProvider.notifier).addPerson(person);
            ref.read(soundServiceProvider).playSuccess();
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
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ledger),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), width: 1),
              ),
              labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent,
              padding: EdgeInsets.all(4.w),
              tabs: [
                Tab(text: l10n.customer),
                Tab(text: l10n.supplier),
              ],
            ),
          ),
        ),
      ),
      body: ledgerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (ledgerState) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPersonList(context, ledgerState.persons, PersonRole.customer, notifier, l10n, currency),
              _buildPersonList(context, ledgerState.persons, PersonRole.supplier, notifier, l10n, currency),
            ],
          );
        },
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: ledgerAsync.maybeWhen(
        data: (ledgerState) {
          final searchQuery = ref.watch(ledgerSearchProvider);
          final currentRole = _tabController.index == 0 ? PersonRole.customer : PersonRole.supplier;
          final currentTabHasPeople = ledgerState.persons.any((p) => p.role == currentRole);
          // Hide FAB when empty state shows CTA button
          if (!currentTabHasPeople && searchQuery.isEmpty) return null;
          
          return FloatingActionButton(
            onPressed: () => _showAddPersonModal(context),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            tooltip: l10n.addPerson,
            child: const Icon(Icons.add),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildPersonList(BuildContext context, List<Person> persons, PersonRole role, LedgerNotifier notifier, AppLocalizations l10n, String currency) {
    final searchQuery = ref.watch(ledgerSearchProvider);
    final sortOption = ref.watch(ledgerSortProvider);
    final showArchived = ref.watch(showArchivedProvider);
    final balanceFilter = ref.watch(ledgerBalanceFilterProvider);
    final theme = Theme.of(context);
    
    // Filter by role first, then exclude archived unless showArchived is true
    var filteredPersons = persons.where((p) => p.role == role).toList();
    
    // Filter out archived persons unless showArchived is enabled
    if (!showArchived) {
      filteredPersons = filteredPersons.where((p) => !p.isArchived).toList();
    }
    
    // Apply balance filter: show only persons with outstanding balance
    if (balanceFilter == 'owes') {
      filteredPersons = filteredPersons.where((p) {
        final balance = notifier.calculatePersonBalance(p);
        // For customers: balance > 0 means they owe us
        // For suppliers: balance > 0 means we owe them
        return balance != 0;
      }).toList();
    }
    
    if (searchQuery.isNotEmpty) {
      filteredPersons = filteredPersons.where((p) {
        final name = p.name.toLowerCase();
        final phone = (p.phone ?? '').toLowerCase();
        return name.contains(searchQuery) || phone.contains(searchQuery);
      }).toList();
    }
    
    // Apply sorting
    filteredPersons.sort((a, b) {
      final balanceA = notifier.calculatePersonBalance(a);
      final balanceB = notifier.calculatePersonBalance(b);
      switch (sortOption) {
        case LedgerSortOption.dateAddedNew:
          return b.createdAt.compareTo(a.createdAt);
        case LedgerSortOption.dateAddedOld:
          return a.createdAt.compareTo(b.createdAt);
        case LedgerSortOption.amountHigh:
          return balanceB.abs().compareTo(balanceA.abs());
        case LedgerSortOption.amountLow:
          return balanceA.abs().compareTo(balanceB.abs());
      }
    });

    return Column(
      children: [
        // Search bar and sort dropdown row
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: DebouncedSearchBar(
                  hintText: l10n.search,
                  onSearch: (query) {
                    ref.read(ledgerSearchProvider.notifier).state = query;
                  },
                ),
              ),
              SizedBox(width: 8.w),
              // Clear filter button (show when any filter is active)
              if (balanceFilter == 'owes' || searchQuery.isNotEmpty || showArchived)
                IconButton(
                  icon: Icon(LucideIcons.filterX, color: theme.colorScheme.error),
                  tooltip: l10n.all,
                  onPressed: () {
                    // Reset all filters
                    ref.read(ledgerBalanceFilterProvider.notifier).state = 'all';
                    ref.read(ledgerSearchProvider.notifier).state = '';
                    ref.read(showArchivedProvider.notifier).state = false;
                  },
                ),
              // Sort dropdown
              PopupMenuButton<LedgerSortOption>(
                icon: Icon(LucideIcons.arrowUpDown, color: theme.colorScheme.primary),
                tooltip: l10n.sortBy,
                onSelected: (value) {
                  ref.read(ledgerSortProvider.notifier).state = value;
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: LedgerSortOption.dateAddedNew,
                    child: Row(
                      children: [
                        Icon(
                          sortOption == LedgerSortOption.dateAddedNew ? LucideIcons.check : null,
                          size: 18.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(l10n.sortNewest),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: LedgerSortOption.dateAddedOld,
                    child: Row(
                      children: [
                        Icon(
                          sortOption == LedgerSortOption.dateAddedOld ? LucideIcons.check : null,
                          size: 18.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(l10n.sortOldest),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: LedgerSortOption.amountHigh,
                    child: Row(
                      children: [
                        Icon(
                          sortOption == LedgerSortOption.amountHigh ? LucideIcons.check : null,
                          size: 18.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(l10n.sortHighestAmount),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: LedgerSortOption.amountLow,
                    child: Row(
                      children: [
                        Icon(
                          sortOption == LedgerSortOption.amountLow ? LucideIcons.check : null,
                          size: 18.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(l10n.sortLowestAmount),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Person balance tip
        const PersonBalanceTip(),
        // List or empty state - Tour Step 5
        Expanded(
          child: ShowcaseTarget(
            showcaseKey: ShowcaseKeys.ledgerList,
            title: l10n.tour5Title,
            description: l10n.tour5Desc,
            child: filteredPersons.isEmpty
                ? EmptyState(
                    message: searchQuery.isEmpty ? l10n.noEntriesYet : l10n.noResults,
                    icon: LucideIcons.users,
                    lottieAsset: 'assets/animations/empty_users.json',
                    actionLabel: searchQuery.isEmpty ? l10n.addPerson : null,
                    onAction: searchQuery.isEmpty ? () => _showAddPersonModal(context) : null,
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: 0, bottom: 80.h),
                    itemCount: filteredPersons.length,
        itemBuilder: (context, index) {
        final person = filteredPersons[index];
        final balance = notifier.calculatePersonBalance(person);
        
        // Determine color based on role and balance
        // Customer: > 0 means they owe us (Asset -> Green)
        // Supplier: > 0 means we owe them (Liability -> Red)
        final isAsset = (role == PersonRole.customer && balance > 0) || 
                        (role == PersonRole.supplier && balance < 0);
        final isLiability = (role == PersonRole.supplier && balance > 0) || 
                            (role == PersonRole.customer && balance < 0);
        
        Color balanceColor = Theme.of(context).colorScheme.onSurface;
        if (balance != 0) {
          balanceColor = isAsset ? AppColors.success : (isLiability ? AppColors.error : Colors.grey);
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          elevation: 0,
          color: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              person.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: person.phone != null && person.phone!.isNotEmpty
                ? Row(
                    children: [
                      Icon(LucideIcons.phone, size: 12.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            person.phone!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
            trailing: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      NumberFormat.currency(
                        symbol: person.currencyCode ?? currency,
                        decimalDigits: (person.currencyCode ?? currency) == 'SDG' ? 0 : 2,
                      ).format(balance.abs()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
                  ),
                  Text(
                    balance == 0
                        ? l10n.settled
                        : (role == PersonRole.customer
                            ? (balance > 0 ? l10n.receivable : l10n.advanceYouOwe)
                            : (balance > 0 ? l10n.payable : l10n.advanceOwesYou)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              context.push('/ledger/${person.id}');
            },
          ),
        );
      },
    ),
          ),
        ),
      ],
    );
  }
}
