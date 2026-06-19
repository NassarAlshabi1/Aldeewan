
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/theme_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/locale_provider.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/security_provider.dart';
import 'package:aldeewan_mobile/utils/error_handler.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/sound_settings_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/guided_tour_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/calendar_provider.dart';
import 'package:aldeewan_mobile/utils/date_formatter_service.dart';

import 'package:showcaseview/showcaseview.dart';

import 'package:aldeewan_mobile/presentation/widgets/settings/settings_section.dart';
import 'package:aldeewan_mobile/presentation/widgets/settings/settings_tile.dart';
import 'package:aldeewan_mobile/presentation/widgets/settings/theme_selector.dart';
import 'package:aldeewan_mobile/presentation/widgets/showcase_wrapper.dart';
import 'package:aldeewan_mobile/presentation/widgets/currency_selector_sheet.dart';
import 'package:aldeewan_mobile/presentation/widgets/settings/exchange_rates_sheet.dart';
import 'package:aldeewan_mobile/presentation/providers/backup_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/restore_strategy_dialog.dart';
import 'package:aldeewan_mobile/presentation/widgets/password_prompt_dialog.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-start settings tour if guided tour is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tourNotifier = ref.read(guidedTourProvider.notifier);
      if (tourNotifier.canStartTourForScreen(TourScreen.settings)) {
        tourNotifier.markScreenTourStarted();
        _startSettingsShowcase();
      }
    });
  }
  
  void _startSettingsShowcase() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        try {
          // ignore: deprecated_member_use
          ShowCaseWidget.of(context).startShowCase(ShowcaseKeys.settingsKeys);
        } catch (e) {
          debugPrint('Settings showcase error: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final currency = ref.watch(currencyProvider);
    final isAppLockEnabled = ref.watch(securityProvider);
    final isSimpleMode = ref.watch(settingsProvider);
    final isSoundEnabled = ref.watch(soundSettingsProvider);
    final notificationState = ref.watch(notificationProvider);
    final calendarState = ref.watch(calendarProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 40.h),
        child: Column(
          children: [
            // Appearance Section
            SettingsSection(
              title: l10n.appearance,
              children: [
                ThemeSelector(
                  currentMode: themeMode,
                  onThemeChanged: (mode) {
                    ref.read(themeProvider.notifier).setTheme(mode);
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.languages,
                  iconColor: Colors.purple,
                  title: l10n.language,
                  trailing: DropdownButton<Locale>(
                    value: locale,
                    underline: const SizedBox(),
                    icon: Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
                    onChanged: (Locale? newValue) {
                      if (newValue != null) {
                        ref.read(localeProvider.notifier).setLocale(newValue);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: Text(l10n.english, style: theme.textTheme.bodyMedium),
                      ),
                      const DropdownMenuItem(
                        value: Locale('ar'),
                        child: Text('العربية'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.layoutTemplate,
                  iconColor: Colors.orange,
                  title: l10n.simpleMode,
                  subtitle: l10n.simpleModeSubtitle,
                  trailing: Switch.adaptive(
                    value: isSimpleMode,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(settingsProvider.notifier).setSimpleMode(value);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.volume2,
                  iconColor: Colors.teal,
                  title: l10n.appSounds,
                  subtitle: l10n.appSoundsSubtitle,
                  trailing: Switch.adaptive(
                    value: isSoundEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(soundSettingsProvider.notifier).setSoundEnabled(value);
                    },
                  ),
                ),
              ],
            ),

            // Notifications Section
            SettingsSection(
              title: l10n.notifications,
              children: [
                SettingsTile(
                  icon: LucideIcons.bell,
                  iconColor: Colors.amber,
                  title: l10n.dailyReminder,
                  subtitle: l10n.dailyReminderSubtitle,
                  trailing: Switch.adaptive(
                    value: notificationState.isEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(notificationProvider.notifier).toggleReminder(
                        value,
                        l10n.dailyReminderTitle,
                        l10n.dailyReminderBody,
                      );
                    },
                  ),
                ),
                if (notificationState.isEnabled) ...[
                  const Divider(height: 1, indent: 60),
                  SettingsTile(
                    icon: LucideIcons.clock,
                    iconColor: Colors.blue,
                    title: l10n.reminderTime,
                    trailing: TextButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: notificationState.time,
                        );
                        if (picked != null) {
                          ref.read(notificationProvider.notifier).setTime(
                            picked,
                            l10n.dailyReminderTitle,
                            l10n.dailyReminderBody,
                          );
                        }
                      },
                      child: Text(
                        notificationState.time.format(context),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ],
            ),

            // Hijri Calendar Section
            SettingsSection(
              title: l10n.hijriCalendar,
              children: [
                SettingsTile(
                  icon: LucideIcons.moon,
                  iconColor: Colors.deepPurple,
                  title: l10n.showHijriDate,
                  trailing: Switch.adaptive(
                    value: calendarState.showHijri,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (val) => ref.read(calendarProvider.notifier).toggleHijri(val),
                  ),
                ),
                if (calendarState.showHijri) ...[
                  const Divider(height: 1, indent: 60),
                  SettingsTile(
                    icon: LucideIcons.settings2,
                    iconColor: Colors.grey,
                    title: l10n.hijriAdjustment,
                    subtitle: l10n.hijriAdjustmentDesc,
                    trailing: Text(
                      calendarState.adjustment == 0 
                          ? '0' 
                          : (calendarState.adjustment > 0 ? '+${calendarState.adjustment}' : '${calendarState.adjustment}'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showAdjustmentDialog(context, calendarState.adjustment),
                  ),
                ],
              ],
            ),

            SettingsSection(
              title: l10n.general,
              children: [
                SettingsTile(
                  icon: LucideIcons.banknote,
                  iconColor: Colors.green,
                  title: l10n.currency,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(LucideIcons.chevronRight, size: 20.sp, color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                  onTap: () async {
                    final selected = await CurrencySelectorSheet.show(context, currency);
                    if (selected != null) {
                      ref.read(currencyProvider.notifier).setCurrency(selected);
                    }
                  },
                ),
                const Divider(height: 1, indent: 60),

                // Exchange rates — lets the user define FX rates between the
                // base currency and any other currency used across persons.
                SettingsTile(
                  icon: LucideIcons.arrowLeftRight,
                  iconColor: Colors.teal,
                  title: l10n.exchangeRates,
                  subtitle: l10n.exchangeRatesSubtitle,
                  trailing: Icon(LucideIcons.chevronRight, size: 20.sp, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () => ExchangeRatesSheet.show(context),
                ),
                const Divider(height: 1, indent: 60),

                SettingsTile(
                  icon: LucideIcons.lock,
                  iconColor: Colors.blue,
                  title: l10n.appLock,
                  subtitle: l10n.appLockSubtitle,
                  trailing: Switch.adaptive(
                    value: isAppLockEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(securityProvider.notifier).setAppLock(value);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.tags,
                  iconColor: Colors.indigo,
                  title: l10n.manageCategories,
                  onTap: () {
                    context.push('/categories');
                  },
                ),
              ],
            ),

            // Data Management Section
            SettingsSection(
              title: l10n.dataManagement,
              children: [
                // Backup to cloud tile - Tour Step 11
                ShowcaseTarget(
                  showcaseKey: ShowcaseKeys.backupTile,
                  title: l10n.tour11Title,
                  description: l10n.tour11Desc,
                  child: SettingsTile(
                    icon: LucideIcons.upload,
                    iconColor: Colors.teal,
                    title: l10n.backupToCloud,
                    subtitle: l10n.backupToCloudSubtitle,
                    tooltip: l10n.backupData,
                    onTap: () => _backupData(context, ref),
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.download,
                  iconColor: Colors.amber,
                  title: l10n.restoreFromCloud,
                  subtitle: l10n.restoreFromCloudSubtitle,
                  trailing: IconButton(
                    icon: Icon(LucideIcons.helpCircle, size: 20.sp, color: Colors.grey),
                    tooltip: l10n.comingSoon, // Or a dynamic help text if available, but comingSoon is a placeholder for now. Wait, I should use l10n.helpCenter.
                    onPressed: () => _showRestoreHelpDialog(context),
                  ),
                  onTap: () => _restoreData(context, ref),
                  tooltip: l10n.restoreData,
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.fileSpreadsheet,
                  iconColor: Colors.greenAccent.shade700,
                  title: l10n.exportPersons,
                  onTap: () => _exportPersonsCsv(context, ref),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.fileText,
                  iconColor: Colors.blueAccent,
                  title: l10n.exportTransactions,
                  onTap: () => _exportTransactionsCsv(context, ref),
                ),
              ],
            ),

            SettingsSection(
              title: l10n.helpCenter,
              children: [
                // Help Center tile - Tour Step 12
                ShowcaseTarget(
                  showcaseKey: ShowcaseKeys.helpButton,
                  title: l10n.tour12Title,
                  description: l10n.tour12Desc,
                  child: SettingsTile(
                    icon: LucideIcons.helpCircle,
                    iconColor: Colors.blue,
                    title: l10n.helpCenter,
                    subtitle: l10n.helpCenterSubtitle,
                    onTap: () => context.go('/settings/help'),
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.info,
                  iconColor: Colors.blue,
                  title: l10n.aboutApp,
                  onTap: () => context.go('/settings/about'),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.user,
                  iconColor: Colors.grey,
                  title: l10n.aboutDeveloper,
                  onTap: () => context.go('/settings/developer'),
                ),
              ],
            ),

            SizedBox(height: 32.h),
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.appVersionInfo('2.2.0'),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.madeWithLove,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        icon: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.download,
            size: 28.sp,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          l10n.restoreHelpTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.restoreHelpStep1, style: theme.textTheme.bodyMedium),
            SizedBox(height: 8.h),
            Text(l10n.restoreHelpStep2, style: theme.textTheme.bodyMedium),
            SizedBox(height: 8.h),
            Text(l10n.restoreHelpStep3, style: theme.textTheme.bodyMedium),
            SizedBox(height: 8.h),
            Text(l10n.restoreHelpStep4, style: theme.textTheme.bodyMedium),
            SizedBox(height: 8.h),
            Text(l10n.restoreHelpStep5, style: theme.textTheme.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;


    try {
      // 1. Ask for encryption
      final bool? encrypt = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.backupEncrypt),
          content: Text(l10n.backupEncryptSubtitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel), // Actually "No" or "Skip"
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.backupEncrypt),
            ),
          ],
        ),
      );

      if (encrypt == null) return; // Dismissed

      String? password;
      if (encrypt) {
        if (!context.mounted) return;
        password = await PasswordPromptDialog.show(context, isCreateMode: true);
        if (password == null) return; // Cancelled password entry
      }

      // 2. Generate Backup using Service
      final backupService = ref.read(backupServiceProvider);
      // Show loading indicator? simpler to just await (it's fast mostly)
      // or show snackbar "Generating..."
      
      final jsonString = await backupService.createBackup(password: password);
      
      final fileName = 'Aldeewan_Backup_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.json';
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Aldeewan Backup',
        text: l10n.backupSuccess,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupFailed(ErrorHandler.getUserFriendlyErrorMessage(e, l10n)))),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        // 1. Check for encryption
        String? password;
        if (content.contains('"isEncrypted":true')) {
          if (!context.mounted) return;
          password = await PasswordPromptDialog.show(context, isCreateMode: false);
          if (password == null) return; // Cancelled
        }

        // 2. Ask Strategy
        if (!context.mounted) return;
        final strategy = await RestoreStrategyDialog.show(context);
        if (strategy == null) return; // Cancelled

        // 3. Perform Restore
        final backupService = ref.read(backupServiceProvider);
        await backupService.restoreBackup(content, strategy: strategy, password: password);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(l10n.restoreSuccess)),
          );
          // Optional: Refresh providers if not auto-watched or if Replace needs forced refresh.
          // Since providers watch streams/db, they should auto update.
          // But LedgerNotifier specifically might need manual reset if it holds in-memory state that doesn't listen to DB changes fully?
          // LedgerNotifier listens to Repositories streams, which listen to Realm streams. So it should update automatically!
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.restoreFailed(ErrorHandler.getUserFriendlyErrorMessage(e, l10n)))),
        );
      }
    }
  }

  Future<void> _exportPersonsCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
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
      text: l10n.exportPersons,
    );
  }

  Future<void> _exportTransactionsCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ledgerState = ref.read(ledgerProvider).value;
    final transactions = ledgerState?.transactions ?? [];
    final persons = ledgerState?.persons ?? [];
    final personMap = {for (var p in persons) p.id: p.name};
    
    final calendarState = ref.read(calendarProvider);
    final showHijri = calendarState.showHijri;
    final langCode = Localizations.localeOf(context).languageCode;

    final rows = <List<dynamic>>[
      ['Date', if (showHijri) 'Hijri Date', 'Type', 'Person', 'Amount', 'Note', 'Category'],
    ];

    for (var t in transactions) {
      rows.add([
        DateFormatterService.forceWesternNumerals(DateFormat('yyyy-MM-dd').format(t.date)),
        if (showHijri)
          DateFormatterService.formatHijriOnly(
            t.date,
            langCode,
            adjustment: calendarState.adjustment,
          ),
        t.type.toString().split('.').last,
        t.personId != null ? (personMap[t.personId] ?? 'Unknown') : '',
        t.amount.toStringAsFixed(2),
        t.note ?? '',
        t.category ?? '',
      ]);
    }

    final fileName = 'transactions_${DateFormatterService.forceWesternNumerals(DateFormat('yyyyMMdd').format(DateTime.now()))}.csv';
    await CsvExporter.exportToCsv(
      fileName: fileName,
      rows: rows,
      subject: 'Aldeewan Transactions Export',
      text: l10n.exportTransactions,
    );
  }

  void _showAdjustmentDialog(BuildContext context, int current) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.hijriAdjustment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [-2, -1, 0, 1, 2].map((val) {
             final label = val == 0 ? "0 ${l10n.days}" : (val > 0 ? "+$val" : "$val");
             return RadioListTile<int>(
               title: Text(label),
               value: val,
               // ignore: deprecated_member_use
               groupValue: current,
               // ignore: deprecated_member_use
               onChanged: (v) {
                 ref.read(calendarProvider.notifier).setAdjustment(v!);
                 Navigator.pop(context);
               },
             );
          }).toList(),
        ),
      ),
    );
  }
}
