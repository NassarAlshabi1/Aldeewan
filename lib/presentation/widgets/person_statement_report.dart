import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/charts/balance_trend_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';
import 'package:aldeewan_mobile/utils/transaction_label_mapper.dart';
import 'package:aldeewan_mobile/presentation/widgets/common/filter_action_tile.dart';
import 'package:aldeewan_mobile/utils/date_formatter_service.dart';

class PersonStatementReport extends ConsumerStatefulWidget {
  const PersonStatementReport({super.key});

  @override
  ConsumerState<PersonStatementReport> createState() => _PersonStatementReportState();
}

class _PersonStatementReportState extends ConsumerState<PersonStatementReport> {
  Person? _selectedPerson;
  DateTimeRange? _dateRange;
  List<Transaction> _statementTransactions = [];
  double _balanceBroughtForward = 0.0;
  bool _generated = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerProvider);
    final currency = ref.watch(currencyProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat('#,##0.##');
    final isSimpleMode = ref.watch(settingsProvider);

    return ledgerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
      data: (ledgerState) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilterActionTile(
                label: l10n.selectPerson,
                value: _selectedPerson?.name ?? l10n.selectPerson,
                icon: LucideIcons.user,
                onTap: () => _showPersonSelector(context, ledgerState.persons),
              ),
              SizedBox(height: 12.h),
              FilterActionTile(
                label: l10n.dateRange,
                value: _dateRange == null
                    ? l10n.selectDateRange
                    : '${DateFormatterService.formatDate(_dateRange!.start, locale)} - ${DateFormatterService.formatDate(_dateRange!.end, locale)}',
                icon: LucideIcons.calendar,
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    initialDateRange: _dateRange,
                  );
                  if (picked != null) {
                    setState(() {
                      _dateRange = picked;
                      _generated = false;
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),
              FilledButton.icon(
                onPressed: _selectedPerson != null && _dateRange != null && !_isGenerating
                    ? () {
                        _generateReport(notifier);
                      }
                    : null,
                icon: _isGenerating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(LucideIcons.fileBarChart),
                label: Text(_isGenerating ? l10n.loading : l10n.generateReport),
              ),
              if (_generated) ...[
                SizedBox(height: 24.h),
                const Divider(),
                SizedBox(height: 16.h),
                Text(
                  l10n.statementFor(_selectedPerson!.name),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.period(DateFormatterService.formatDate(_dateRange!.start, locale), DateFormatterService.formatDate(_dateRange!.end, locale)),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_statementTransactions.isNotEmpty) ...[
                  SizedBox(
                    height: 200.h,
                    child: _buildTrendChart(),
                  ),
                  SizedBox(height: 24.h),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _statementTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = _statementTransactions[index];
                      // Use the transaction's currency if set (inherited
                      // from the person at creation time); fall back to
                      // the person's currency; finally to the app default.
                      final effectiveCurrency = tx.currencyCode ??
                          _selectedPerson?.currencyCode ??
                          currency;
                      return ListTile(
                        title: Text(TransactionLabelMapper.getLabel(tx.type, isSimpleMode, l10n)),
                        subtitle: Text(DateFormatterService.formatDate(tx.date, locale)),
                        trailing: Text('$effectiveCurrency ${formatter.format(tx.amount)}'),
                      );
                    },
                  ),
                  const Divider(),
                  _buildSummaryRow(
                      l10n.closingBalance,
                      _calculateClosingBalance(),
                      _selectedPerson?.currencyCode ?? currency,
                      formatter),
                  SizedBox(height: 8.h),
                  _buildNetPositionRow(context, _calculateClosingBalance(), l10n),
                  SizedBox(height: 24.h),
                  OutlinedButton.icon(
                    onPressed: _exportCsv,
                    icon: const Icon(LucideIcons.download),
                    label: Text(l10n.exportCsv),
                  ),
                ] else ...[
                  // Empty state when no transactions found for person in date range
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.fileX,
                          size: 48.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          l10n.noEntriesYet,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendChart() {
    double runningBalance = _balanceBroughtForward;
    final spots = <FlSpot>[];
    double minBalance = runningBalance;
    double maxBalance = runningBalance;

    // Add initial point
    spots.add(FlSpot(0, runningBalance));

    for (int i = 0; i < _statementTransactions.length; i++) {
      final t = _statementTransactions[i];
      runningBalance = _applyTransactionToBalanceStatic(runningBalance, t, _selectedPerson!);
      spots.add(FlSpot((i + 1).toDouble(), runningBalance));
      
      if (runningBalance < minBalance) minBalance = runningBalance;
      if (runningBalance > maxBalance) maxBalance = runningBalance;
    }

    // Add some padding to min/max
    final range = maxBalance - minBalance;
    final padding = range == 0 ? 10.0 : range * 0.1;

    return BalanceTrendChart(
      spots: spots,
      minY: minBalance - padding,
      maxY: maxBalance + padding,
    );
  }

  Future<void> _generateReport(LedgerNotifier notifier) async {
    if (_selectedPerson == null || _dateRange == null) return;

    setState(() {
      _isGenerating = true;
    });

    final allTransactions = ref.read(ledgerProvider).value?.transactions ?? [];
    
    try {
      final result = await compute(
        _generateReportStatic,
        (allTransactions, _selectedPerson!, _dateRange!.start, _dateRange!.end),
      );

      if (mounted) {
        setState(() {
          _balanceBroughtForward = result.$1;
          _statementTransactions = result.$2;
          _generated = true;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    }
  }

  static (double, List<Transaction>) _generateReportStatic((List<Transaction>, Person, DateTime, DateTime) data) {
    final allTransactions = data.$1;
    final person = data.$2;
    final startDate = data.$3;
    final endDate = data.$4;

    final personTransactions = allTransactions
        .where((t) => t.personId == person.id)
        .toList();

    final beforeRange = personTransactions
        .where((t) => t.date.isBefore(startDate))
        .toList();

    final inRange = personTransactions
        .where((t) =>
            t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            t.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate Balance B/F
    double balanceBF = 0.0;
    for (var t in beforeRange) {
      balanceBF = _applyTransactionToBalanceStatic(balanceBF, t, person);
    }

    return (balanceBF, inRange);
  }

  static double _applyTransactionToBalanceStatic(double currentBalance, Transaction t, Person p) {
    if (p.role == PersonRole.customer) {
      // Customer Pattern:
      // + Balance (Asset) = Sale, Lend
      // - Balance (Asset) = Payment Received, Borrow
      // + Balance (Refund) = We pay them (Liability -> 0)
      
      if (t.type == TransactionType.saleOnCredit) return currentBalance + t.amount;
      if (t.type == TransactionType.debtGiven) return currentBalance + t.amount;
      
      if (t.type == TransactionType.paymentReceived) return currentBalance - t.amount;
      if (t.type == TransactionType.debtTaken) return currentBalance - t.amount;
      
      // Refund: We pay customer back (e.g. they paid advance, now we return it)
      // This reduces the negative balance (Liability), i.e., adds to it towards zero.
      // Wait, if balance is -100 (Liability), adding 100 makes it 0. Correct.
      if (t.type == TransactionType.paymentMade) return currentBalance + t.amount;
      
    } else { // Supplier
      // Supplier Pattern:
      // + Balance (Liability) = Purchase, Borrow
      // - Balance (Liability) = Payment Made, Lend
      // + Balance (Refund) = They pay us (Asset -> 0)
      
      if (t.type == TransactionType.purchaseOnCredit) return currentBalance + t.amount;
      if (t.type == TransactionType.debtTaken) return currentBalance + t.amount;
      
      if (t.type == TransactionType.paymentMade) return currentBalance - t.amount;
      if (t.type == TransactionType.debtGiven) return currentBalance - t.amount;
      
      // Refund: Supplier pays us back (e.g. we paid advance, now they return it)
      // This reduces the negative balance (Asset), i.e., adds to it towards zero.
      if (t.type == TransactionType.paymentReceived) return currentBalance + t.amount;
    }
    return currentBalance;
  }

  double _calculateClosingBalance() {
    double balance = _balanceBroughtForward;
    for (var t in _statementTransactions) {
      balance = _applyTransactionToBalanceStatic(balance, t, _selectedPerson!);
    }
    return balance;
  }

  Widget _buildSummaryRow(String label, double amount, String currency, NumberFormat formatter) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('$currency ${formatter.format(amount)}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNetPositionRow(BuildContext context, double balance, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final person = _selectedPerson!;
    
    String positionText;
    Color color;

    if (balance == 0) {
      positionText = l10n.settled;
      color = Colors.grey;
    } else {
      // Logic:
      // Customer: Balance > 0 (They owe us) -> Receivable (لك)
      // Customer: Balance < 0 (We owe them) -> Advance (عليك)
      // Supplier: Balance > 0 (We owe them) -> Payable (عليك)
      // Supplier: Balance < 0 (They owe us) -> Advance (لك)
      
      final isAsset = (person.role == PersonRole.customer && balance > 0) || 
                      (person.role == PersonRole.supplier && balance < 0);
      
      // l10n.receivable usually means "Receivable" (Asset).
      // l10n.payable usually means "Payable" (Liability).
      // l10n.advance usually means "Advance Payment".
      
      // Let's use explicit "For You" / "On You" if possible, or map to existing keys.
      // "لك" (For You) / "عليك" (On You)
      
      // I will use hardcoded Arabic for now if keys are missing, or reuse existing.
      // l10n.receivable -> "مستحق لك" (Receivable)
      // l10n.payable -> "مستحق عليك" (Payable)
      
      if (isAsset) {
        positionText = l10n.receivable; // "Receivable" (Asset)
        color = Colors.green;
      } else {
        positionText = l10n.payable; // "Payable" (Liability)
        color = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.netPosition, style: theme.textTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              positionText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPersonSelector(BuildContext context, List<Person> persons) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, index) {
          final person = persons[index];
          return ListTile(
            title: Text(person.name),
            onTap: () {
              setState(() {
                _selectedPerson = person;
                _generated = false;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (_selectedPerson == null || _dateRange == null) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Note', 'Amount', 'Balance'],
      ['', l10n.balanceBroughtForward, '', '', _balanceBroughtForward.toStringAsFixed(2)],
    ];

    double runningBalance = _balanceBroughtForward;
    for (var t in _statementTransactions) {
      runningBalance = _applyTransactionToBalanceStatic(runningBalance, t, _selectedPerson!);
      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        TransactionLabelMapper.getLabel(t.type, ref.read(settingsProvider), l10n),
        t.note ?? '',
        t.amount.toStringAsFixed(2),
        runningBalance.toStringAsFixed(2),
      ]);
    }

    final fileName = 'statement_${_selectedPerson!.name}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    await CsvExporter.exportToCsv(
      fileName: fileName,
      rows: rows,
      subject: l10n.statementFor(_selectedPerson!.name),
      text: 'Here is the statement for ${_selectedPerson!.name} from ${DateFormat.yMMMd().format(_dateRange!.start)} to ${DateFormat.yMMMd().format(_dateRange!.end)}.',
    );
  }
}

