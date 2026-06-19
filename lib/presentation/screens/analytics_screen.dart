import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_statement_report.dart';
import 'package:aldeewan_mobile/presentation/widgets/cash_flow_report.dart';
import 'package:aldeewan_mobile/presentation/widgets/debt_analysis_report.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/utils/error_handler.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';
import 'package:aldeewan_mobile/presentation/providers/calendar_provider.dart';
import 'package:aldeewan_mobile/utils/date_formatter_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialTabHandled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // No listener needed — we rebuild via AnimatedBuilder in the AppBar actions.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialTabHandled) {
      final tab = GoRouterState.of(context).uri.queryParameters['tab'];
      if (tab == 'debts') {
        _tabController.animateTo(2);
      } else if (tab == 'cashflow') {
        _tabController.animateTo(1);
      }
      _initialTabHandled = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        actions: [
          // AnimatedBuilder rebuilds only the actions area on tab change,
          // not the whole widget tree.
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return _tabController.index == 0
                  ? PopupMenuButton<String>(
                      tooltip: l10n.exportCsv,
                      onSelected: (value) {
                        if (value == 'export_persons') {
                          _exportPersonsCsv(context, ref);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'export_persons',
                            child: Text(l10n.exportPersons),
                          ),
                        ];
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
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
                Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.personStatement))),
                Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.cashFlow))),
                Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.ledger))),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const ExportReportTip(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PersonStatementReport(),
                CashFlowReport(),
                DebtAnalysisReport(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Future<void> _exportPersonsCsv(BuildContext context, WidgetRef ref) async {
    try {
      final persons = ref.read(ledgerProvider).value?.persons ?? [];
      final calendarState = ref.read(calendarProvider);
      final showHijri = calendarState.showHijri;
      final langCode = Localizations.localeOf(context).languageCode;

      final rows = <List<dynamic>>[
        ['ID', 'Name', 'Role', 'Phone', 'Created At', if (showHijri) 'Created At (Hijri)'],
      ];

      for (var p in persons) {
        rows.add([
          p.id,
          p.name,
          p.role.toString().split('.').last,
          p.phone ?? '',
          DateFormatterService.forceWesternNumerals(DateFormat('yyyy-MM-dd HH:mm').format(p.createdAt)),
          if (showHijri)
            DateFormatterService.formatHijriOnly(
              p.createdAt,
              langCode,
              adjustment: calendarState.adjustment,
            ),
        ]);
      }

      final fileName = 'persons_${DateFormatterService.forceWesternNumerals(DateFormat('yyyyMMdd').format(DateTime.now()))}.csv';
      await CsvExporter.exportToCsv(
        fileName: fileName,
        rows: rows,
        subject: 'Aldeewan Persons Export',
        text: 'Export of all persons.',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.exportSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed(ErrorHandler.getUserFriendlyErrorMessage(e, AppLocalizations.of(context)!)))),
        );
      }
    }
  }
}

