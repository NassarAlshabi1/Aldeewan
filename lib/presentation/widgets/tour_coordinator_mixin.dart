import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:aldeewan_mobile/presentation/providers/guided_tour_provider.dart';

/// Mixin that consolidates the boilerplate needed by every screen that
/// participates in the cross-screen guided tour.
///
/// Previously, four screens (home, ledger, cashbook, settings) each had
/// their own copy of the `didChangeDependencies` →
/// `WidgetsBinding.instance.addPostFrameCallback` →
/// `canStartTourForScreen` → `markScreenTourStarted` → `_startXxxShowcase`
/// boilerplate. This mixin replaces that with one declarative override.
mixin TourCoordinatorMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// The screen key used by the GuidedTourProvider to track progress.
  TourScreen get tourScreen;

  /// The list of showcase keys to display when the tour visits this screen.
  List<GlobalKey> get tourShowcaseKeys;

  /// Optional: override to do custom work before the showcase starts
  /// (e.g. navigate to a specific tab first).
  void onTourStarting() {}

  /// Call from [State.didChangeDependencies]. Triggers the showcase for this
  /// screen when the tour is active and is now visiting this screen.
  void maybeStartTour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(guidedTourProvider.notifier);
      final tourState = ref.read(guidedTourProvider);
      if (!tourState.isActive) return;
      if (tourState.currentScreen != tourScreen) return;
      if (!notifier.canStartTourForScreen(tourScreen)) return;
      notifier.markScreenTourStarted();
      onTourStarting();
      _startShowcase();
    });
  }

  void _startShowcase() {
    if (!mounted) return;
    final keys = tourShowcaseKeys;
    if (keys.isEmpty) {
      // Nothing to showcase on this screen — advance immediately.
      ref.read(guidedTourProvider.notifier).onScreenTourComplete(context);
      return;
    }
    ShowCaseWidget.of(context).startShowCase(keys);
  }
}
