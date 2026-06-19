import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/data/services/onboarding_service.dart';
import 'package:aldeewan_mobile/presentation/providers/dependency_injection.dart';

/// `sharedPreferencesProvider` is now canonically defined in
/// `dependency_injection.dart` (overridden in main()).

/// Provider for OnboardingService
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingService(prefs);
});

/// Provider for tour completion state
final tourCompletedProvider = StateProvider<bool>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.isTourCompleted;
});

/// Provider for dismissed tips list
final dismissedTipsProvider = StateProvider<List<String>>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.dismissedTips;
});

/// Notifier for managing onboarding state
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingService _service;

  OnboardingNotifier(this._service)
      : super(OnboardingState(
          tourCompleted: _service.isTourCompleted,
          dismissedTips: _service.dismissedTips,
        ));

  /// Complete the tour
  Future<void> completeTour() async {
    await _service.completeTour();
    state = state.copyWith(tourCompleted: true);
  }

  /// Restart the tour
  Future<void> restartTour() async {
    await _service.resetTour();
    state = state.copyWith(tourCompleted: false);
  }

  /// Dismiss a tip
  Future<void> dismissTip(String tipId) async {
    await _service.dismissTip(tipId);
    state = state.copyWith(dismissedTips: _service.dismissedTips);
  }

  /// Check if a tip should be shown
  bool shouldShowTip(String tipId) {
    return !state.dismissedTips.contains(tipId);
  }

  /// Reset all (tour + tips)
  Future<void> resetAll() async {
    await _service.resetAll();
    state = OnboardingState(
      tourCompleted: false,
      dismissedTips: [],
    );
  }
}

/// State class for onboarding
class OnboardingState {
  final bool tourCompleted;
  final List<String> dismissedTips;

  const OnboardingState({
    required this.tourCompleted,
    required this.dismissedTips,
  });

  OnboardingState copyWith({
    bool? tourCompleted,
    List<String>? dismissedTips,
  }) {
    return OnboardingState(
      tourCompleted: tourCompleted ?? this.tourCompleted,
      dismissedTips: dismissedTips ?? this.dismissedTips,
    );
  }
}

/// Main provider for onboarding notifier
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return OnboardingNotifier(service);
});
