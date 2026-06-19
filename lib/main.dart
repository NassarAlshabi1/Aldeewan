import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aldeewan_mobile/presentation/providers/theme_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/locale_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/security_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';
import 'package:aldeewan_mobile/config/router.dart';

import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/config/theme.dart';
import 'package:aldeewan_mobile/presentation/widgets/privacy_blur.dart';
import 'package:aldeewan_mobile/utils/auth_service.dart';
import 'package:aldeewan_mobile/utils/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';
import 'package:aldeewan_mobile/data/services/stock_alert_service.dart';
import 'package:aldeewan_mobile/data/services/recurring_transaction_service.dart';
import 'package:aldeewan_mobile/data/services/smart_alert_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService().init();
  
  final prefs = await SharedPreferences.getInstance();
  final isAppLockEnabled = prefs.getBool('app_lock_enabled') ?? false;

  runApp(ProviderScope(
    overrides: [
      securityProvider.overrideWith((ref) => SecurityNotifier(isAppLockEnabled)),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: MyApp(initialSecurityState: isAppLockEnabled),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  final bool initialSecurityState;
  const MyApp({super.key, this.initialSecurityState = false});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late bool _isLocked;
  final _authService = AuthService();
  VoidCallback? _stockAlertCancel;
  Timer? _recurringTick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLocked = widget.initialSecurityState;

    if (_isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkMissedReminders());
    // Start listening to inventory changes for low-stock alerts.
    // The subscription lives for the app's lifetime; cancellation happens
    // in dispose().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stockAlertCancel = ref.read(stockAlertServiceProvider).start();
    });
    // Materialise any due recurring transactions on app start, then every 5 min.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runRecurringAndSmartAlerts();
      _recurringTick = Timer.periodic(const Duration(minutes: 5), (_) {
        _runRecurringAndSmartAlerts();
      });
    });
  }

  Future<void> _runRecurringAndSmartAlerts() async {
    try {
      final recurringService = ref.read(recurringTransactionServiceProvider);
      final generated = await recurringService.runDue();
      if (generated > 0 && kDebugMode) {
        debugPrint('Recurring: generated $generated transactions');
      }
      // Smart alerts run after recurring so budget-overrun alerts reflect
      // any transactions just materialised.
      await ref.read(smartAlertServiceProvider).runAll();
    } catch (e, s) {
      if (kDebugMode) debugPrint('Recurring/SmartAlerts error: $e\n$s');
    }
  }

  @override
  void dispose() {
    _recurringTick?.cancel();
    _stockAlertCancel?.call();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final context = rootNavigatorKey.currentContext;
    String reason = 'Please authenticate to access Aldeewan';
    if (context != null && context.mounted) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        reason = l10n.authenticateReason;
      }
    }
    final authenticated = await _authService.authenticate(reason);
    if (!mounted) return;

    if (authenticated) {
      setState(() {
        _isLocked = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final securityEnabled = ref.read(securityProvider);
    
    if (state == AppLifecycleState.paused) {
      if (securityEnabled) {
        setState(() {
          _isLocked = true;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (securityEnabled && _isLocked) {
        _checkAuth();
      }
      _checkMissedReminders();
    }
  }

  Future<void> _checkMissedReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
    
    if (isEnabled) {
      final hour = prefs.getInt('daily_reminder_hour') ?? 20;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      final now = DateTime.now();
      final reminderTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      final lastLogStr = prefs.getString('last_daily_reminder_log');
      final lastLog = lastLogStr != null ? DateTime.parse(lastLogStr) : null;
      
      // If today is not the same day as last log AND time has passed
      bool needsLog = false;
      if (lastLog == null) {
        needsLog = now.isAfter(reminderTime);
      } else {
        final isSameDay = lastLog.year == now.year && lastLog.month == now.month && lastLog.day == now.day;
        if (!isSameDay && now.isAfter(reminderTime)) {
          needsLog = true;
        }
      }

      if (needsLog) {
        // Need access to localizations... wait until context is available or use defaults
        // Since this is background mostly, we might use default English/Arabic fallback?
        // Or better: use the current locale if context is available.
        
        final context = rootNavigatorKey.currentContext;
        String title = 'Daily Reminder';
        String body = "Don't forget to record your transactions for today!";
        
        if (context != null && context.mounted) {
          final l10n = AppLocalizations.of(context);
          if (l10n != null) {
            title = l10n.dailyReminderTitle;
            body = l10n.dailyReminderBody;
          }
        }
        
        // Add to history
        ref.read(notificationHistoryProvider.notifier).addNotification(
          title: title,
          body: body,
          type: 'info',
        );
        
        await prefs.setString('last_daily_reminder_log', now.toIso8601String());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    // ScreenUtilInit wraps the app for responsive scaling
    // Design size: iPhone 14 (390x844) as baseline
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        title: 'Aldeewan',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
        builder: (context, child) {
          return PrivacyBlur(
            isLocked: _isLocked,
            onUnlock: _checkAuth,
            child: child!,
          );
        },
      ),
    );
  }
}
