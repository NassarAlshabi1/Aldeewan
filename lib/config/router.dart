import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aldeewan_mobile/presentation/screens/home_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/ledger_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/cashbook_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/analytics_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/settings_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/about_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/developer_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/splash_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/link_account_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/budget_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/budget_details_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/goals_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/goal_details_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/notifications_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/transaction_details_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/help_center_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/person_details_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/inventory_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/product_details_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/categories_management_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/split_bill_screen.dart';
import 'package:aldeewan_mobile/presentation/screens/calendar_screen.dart';
import 'package:aldeewan_mobile/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:aldeewan_mobile/presentation/widgets/showcase_wrapper.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/utils/sound_navigation_observer.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final soundService = ref.watch(soundServiceProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    observers: [
      SoundNavigationObserver(soundService),
    ],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/link-account',
        builder: (context, state) => const LinkAccountScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/categories',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CategoriesManagementScreen(),
      ),
      GoRoute(
        path: '/split-bill',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplitBillScreen(),
      ),
      GoRoute(
        path: '/calendar',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CalendarScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return GlobalShowcaseWrapper(
            child: ScaffoldWithNavBar(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BudgetDetailsScreen(budgetId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return GoalDetailsScreen(goalId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/ledger',
            builder: (context, state) => const LedgerScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey, // Open details above the shell (hides nav bar) - usually better for details
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PersonDetailsScreen(personId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/cashbook',
            builder: (context, state) => const CashbookScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProductDetailsScreen(productId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'about',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const AboutScreen(),
              ),
              GoRoute(
                path: 'developer',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const DeveloperScreen(),
              ),
              GoRoute(
                path: 'help',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const HelpCenterScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/transaction',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final transaction = state.extra as Transaction;
          return TransactionDetailsScreen(transaction: transaction);
        },
      ),
    ],
  );
});
