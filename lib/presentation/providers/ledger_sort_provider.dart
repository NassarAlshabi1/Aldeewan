import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sorting options for the ledger person list
enum LedgerSortOption { 
  /// Newest added first (by createdAt descending)
  dateAddedNew, 
  /// Oldest added first (by createdAt ascending)
  dateAddedOld, 
  /// Highest balance first (by absolute balance descending)
  amountHigh, 
  /// Lowest balance first (by absolute balance ascending)
  amountLow 
}

/// Provider to manage the current ledger sort option.
/// AutoDispose so the sort resets when the user leaves the ledger screen.
final ledgerSortProvider = StateProvider.autoDispose<LedgerSortOption>(
  (ref) => LedgerSortOption.dateAddedNew,
);
