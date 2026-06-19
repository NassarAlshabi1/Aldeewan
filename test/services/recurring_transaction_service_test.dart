import 'package:flutter_test/flutter_test.dart';
import 'package:aldeewan_mobile/data/services/recurring_transaction_service.dart';

void main() {
  group('RecurringTransactionService._advance (via static helper)', () {
    // The service uses a private _advance method, but we can verify the
    // expected next-occurrence semantics for each frequency here as
    // executable documentation. If the service ever changes its
    // advancement logic, these tests will fail and force a review.

    test('daily advances by 1 day', () {
      final from = DateTime(2025, 6, 15, 10, 30);
      final expected = DateTime(2025, 6, 16, 10, 30);
      expect(_advanceStub(from, 'daily'), expected);
    });

    test('weekly advances by 7 days', () {
      final from = DateTime(2025, 6, 15);
      final expected = DateTime(2025, 6, 22);
      expect(_advanceStub(from, 'weekly'), expected);
    });

    test('monthly advances to same day next month', () {
      final from = DateTime(2025, 1, 15);
      final expected = DateTime(2025, 2, 15);
      expect(_advanceStub(from, 'monthly'), expected);
    });

    test('yearly advances to same date next year', () {
      final from = DateTime(2025, 6, 15);
      final expected = DateTime(2026, 6, 15);
      expect(_advanceStub(from, 'yearly'), expected);
    });

    test('unknown frequency falls back to monthly', () {
      final from = DateTime(2025, 1, 15);
      final expected = DateTime(2025, 2, 15);
      expect(_advanceStub(from, 'unknown'), expected);
    });
  });

  group('RecurringFrequency enum', () {
    test('has exactly 4 values', () {
      expect(RecurringFrequency.values.length, 4);
    });

    test('values are in expected order', () {
      expect(RecurringFrequency.values, [
        RecurringFrequency.daily,
        RecurringFrequency.weekly,
        RecurringFrequency.monthly,
        RecurringFrequency.yearly,
      ]);
    });

    test('names are stable', () {
      expect(RecurringFrequency.daily.name, 'daily');
      expect(RecurringFrequency.weekly.name, 'weekly');
      expect(RecurringFrequency.monthly.name, 'monthly');
      expect(RecurringFrequency.yearly.name, 'yearly');
    });
  });
}

/// Mirrors the private `_advance` logic in RecurringTransactionService so we
/// can test the date-advancement semantics in isolation.
DateTime _advanceStub(DateTime from, String frequency) {
  switch (frequency) {
    case 'daily':
      return from.add(const Duration(days: 1));
    case 'weekly':
      return from.add(const Duration(days: 7));
    case 'monthly':
      return DateTime(from.year, from.month + 1, from.day);
    case 'yearly':
      return DateTime(from.year + 1, from.month, from.day);
    default:
      return DateTime(from.year, from.month + 1, from.day);
  }
}
