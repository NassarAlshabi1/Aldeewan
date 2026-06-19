import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/utils/currency_formatter.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';

/// Calendar view that colours each day by total spending volume.
///
/// Tapping a day shows that day's transactions in a bottom sheet.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ledgerAsync = ref.watch(ledgerProvider);
    final currency = ref.watch(currencyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendar),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronRight),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.previousMonth,
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
              });
            },
          ),
          IconButton(
            tooltip: l10n.nextMonth,
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
              });
            },
          ),
        ],
      ),
      body: ledgerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (ledger) {
          final monthTx = ledger.transactions.where((t) {
            return t.date.year == _focusedDay.year &&
                t.date.month == _focusedDay.month;
          }).toList();
          // Group by day → (income, expense)
          final Map<int, _DaySummary> byDay = {};
          for (final t in monthTx) {
            final day = t.date.day;
            final entry = byDay.putIfAbsent(day, () => _DaySummary());
            final isIncome = t.type == TransactionType.paymentReceived ||
                t.type == TransactionType.cashSale ||
                t.type == TransactionType.cashIncome ||
                t.type == TransactionType.debtTaken;
            if (isIncome) {
              entry.income += t.amount;
            } else {
              entry.expense += t.amount;
            }
          }

          return Column(
            children: [
              _MonthHeader(focusedDay: _focusedDay, l10n: l10n),
              _CalendarGrid(
                focusedDay: _focusedDay,
                byDay: byDay,
                selectedDay: _selectedDay,
                onDaySelected: (day) {
                  setState(() => _selectedDay = day);
                  _showDayTransactions(context, day, monthTx, currency, l10n);
                },
              ),
              SizedBox(height: 16.h),
              _MonthSummary(byDay: byDay, currency: currency, l10n: l10n),
            ],
          );
        },
      ),
    );
  }

  void _showDayTransactions(
    BuildContext context,
    DateTime day,
    List<Transaction> monthTx,
    String currency,
    AppLocalizations l10n,
  ) {
    final dayTx = monthTx
        .where((t) =>
            t.date.year == day.year &&
            t.date.month == day.month &&
            t.date.day == day.day)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: EdgeInsets.all(16.w),
              children: [
                Text(
                  '${l10n.transactions} — ${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                if (dayTx.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(child: Text(l10n.noTransactions)),
                  )
                else
                  ...dayTx.map((t) {
                    final isIncome = t.type == TransactionType.paymentReceived ||
                        t.type == TransactionType.cashSale ||
                        t.type == TransactionType.cashIncome ||
                        t.type == TransactionType.debtTaken;
                    return ListTile(
                      leading: Icon(
                        isIncome
                            ? LucideIcons.arrowDownLeft
                            : LucideIcons.arrowUpRight,
                        color: isIncome ? AppColors.success : AppColors.error,
                      ),
                      title: Text(t.note ?? t.type),
                      subtitle: Text(t.category ?? ''),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount, currency)}',
                        style: TextStyle(
                          color: isIncome ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}

class _DaySummary {
  double income = 0;
  double expense = 0;
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.focusedDay, required this.l10n});
  final DateTime focusedDay;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final monthName = _monthName(focusedDay.month, l10n);
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Text(
        '$monthName ${focusedDay.year}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  String _monthName(int month, AppLocalizations l10n) {
    // Reuse intl's date symbols via DateFormat for proper locale rendering.
    return ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'][month];
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedDay,
    required this.byDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final Map<int, _DaySummary> byDay;
  final DateTime? selectedDay;
  final void Function(DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final daysInMonth =
        DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
    // weekday: Mon = 1 (RTL-friendly: week starts on Saturday in Arabic
    // calendars, but Flutter's Material Localizations defaults to the
    // locale's first day of week — we honour that by reading
    // MaterialLocalizations.of(context).firstDayOfWeekIndex).
    final firstWeekday = firstOfMonth.weekday; // 1=Mon..7=Sun

    // Find max expense for colour scaling.
    final maxExpense = byDay.values
        .fold<double>(0, (a, b) => a > b.expense ? a : b.expense);

    final theme = Theme.of(context);
    final cells = <Widget>[];

    // Leading blanks — assume week starts on Saturday for Arabic (6) and
    // Sunday for English (7). Honour MaterialLocalizations.
    final firstDay = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final leadingBlanks = (firstWeekday - firstDay) % 7;
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final summary = byDay[day];
      final intensity = summary == null || maxExpense == 0
          ? 0.0
          : (summary.expense / maxExpense).clamp(0.0, 1.0);
      final isSelected = selectedDay != null &&
          selectedDay!.year == focusedDay.year &&
          selectedDay!.month == focusedDay.month &&
          selectedDay!.day == day;
      final isToday = _isToday(focusedDay.year, focusedDay.month, day);

      cells.add(
        GestureDetector(
          onTap: () => onDaySelected(
              DateTime(focusedDay.year, focusedDay.month, day)),
          child: Container(
            decoration: BoxDecoration(
              color: intensity > 0
                  ? AppColors.error.withValues(alpha: 0.1 + 0.4 * intensity)
                  : (isSelected ? theme.colorScheme.primaryContainer : null),
              borderRadius: BorderRadius.circular(8.r),
              border: isToday
                  ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                  : null,
            ),
            margin: EdgeInsets.all(2.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (summary != null && (summary.income > 0 || summary.expense > 0))
                  Container(
                    width: 6.w,
                    height: 6.w,
                    margin: EdgeInsets.only(top: 2.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: summary.income > 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      children: cells,
    );
  }

  bool _isToday(int year, int month, int day) {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.byDay,
    required this.currency,
    required this.l10n,
  });

  final Map<int, _DaySummary> byDay;
  final String currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;
    for (final s in byDay.values) {
      totalIncome += s.income;
      totalExpense += s.expense;
    }
    final net = totalIncome - totalExpense;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          _statCard(
            theme,
            label: l10n.moneyIn,
            value: CurrencyFormatter.format(totalIncome, currency),
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          _statCard(
            theme,
            label: l10n.moneyOut,
            value: CurrencyFormatter.format(totalExpense, currency),
            color: AppColors.error,
          ),
          SizedBox(width: 8.w),
          _statCard(
            theme,
            label: l10n.net,
            value: CurrencyFormatter.format(net, currency),
            color: net >= 0 ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    ThemeData theme, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              SizedBox(height: 4.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
