// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:aldeewan_mobile/presentation/providers/guided_tour_provider.dart';

/// Global keys for showcase targets - 12 step guided tour
class ShowcaseKeys {
  // Home Screen (Steps 1-4)
  static final GlobalKey dashboardCards = GlobalKey();
  static final GlobalKey quickActions = GlobalKey();
  static final GlobalKey budgetCard = GlobalKey();
  static final GlobalKey goalsCard = GlobalKey();

  // Ledger Screen (Step 5)
  static final GlobalKey ledgerList = GlobalKey();

  // Cashbook Screen (Steps 6-7)
  static final GlobalKey cashbookFilter = GlobalKey();
  static final GlobalKey searchBar = GlobalKey();

  // Settings Screen (Steps 8-9)
  static final GlobalKey backupTile = GlobalKey();
  static final GlobalKey helpButton = GlobalKey();

  /// Keys for Home Screen tour (4 steps)
  static List<GlobalKey> get homeKeys => [
        dashboardCards,
        quickActions,
        budgetCard,
        goalsCard,
      ];

  /// Keys for Ledger Screen tour (1 step).
  static List<GlobalKey> get ledgerKeys => [ledgerList];

  /// Keys for Cashbook Screen tour (2 steps — filter & search).
  static List<GlobalKey> get cashbookKeys => [cashbookFilter, searchBar];

  /// Keys for Settings Screen tour (2 steps — backup & help).
  static List<GlobalKey> get settingsKeys => [backupTile, helpButton];
}

/// Wrapper widget to provide Showcase context to the app
class GlobalShowcaseWrapper extends ConsumerWidget {
  final Widget child;

  const GlobalShowcaseWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShowCaseWidget(
      builder: (showcaseContext) => child,
      onFinish: () {
        // When a screen's showcase finishes, notify the tour orchestrator
        final tourState = ref.read(guidedTourProvider);
        if (tourState.isActive) {
          ref.read(guidedTourProvider.notifier).onScreenTourComplete(context);
        }
      },
    );
  }
}

// NOTE: ShowcaseTourMixin was REMOVED - it was an old per-screen tour system
// that conflicted with the new GuidedTourProvider cross-screen tour.
// The guided tour now uses canStartTourForScreen() and markScreenTourStarted()
// in each screen's didChangeDependencies() to coordinate the cross-screen tour.

/// Helper widget to wrap showcase targets
class ShowcaseTarget extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final Widget child;

  const ShowcaseTarget({
    super.key,
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Showcase(
      key: showcaseKey,
      title: title,
      description: description,
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      descTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      tooltipBackgroundColor: theme.cardColor,
      targetPadding: const EdgeInsets.all(8),
      showArrow: true,
      enableAutoScroll: true,
      child: child,
    );
  }
}
