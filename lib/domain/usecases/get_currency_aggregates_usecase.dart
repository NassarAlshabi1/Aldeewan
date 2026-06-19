import 'package:aldeewan_mobile/domain/entities/person.dart';
/// Aggregated balances grouped by currency code.
///
/// Used by the dashboard to show "Total Receivable" / "Total Payable"
/// both per-currency AND as a single approximate total (converted to base).
class CurrencyAggregates {
  /// Map of currencyCode → total receivable (customers owe us) in that currency.
  final Map<String, double> receivableByCurrency;

  /// Map of currencyCode → total payable (we owe suppliers) in that currency.
  final Map<String, double> payableByCurrency;

  const CurrencyAggregates({
    required this.receivableByCurrency,
    required this.payableByCurrency,
  });

  /// All distinct currency codes that appear in either map.
  Set<String> get allCurrencies => {
        ...receivableByCurrency.keys,
        ...payableByCurrency.keys,
      };

  /// Sum of all receivables across all currencies, WITHOUT conversion.
  /// (Useful only when all persons use the same currency.)
  double get totalReceivableRaw =>
      receivableByCurrency.values.fold(0.0, (a, b) => a + b);

  /// Sum of all payables across all currencies, WITHOUT conversion.
  double get totalPayableRaw =>
      payableByCurrency.values.fold(0.0, (a, b) => a + b);
}

/// Computes per-currency aggregates for receivables and payables.
///
/// Each person's outstanding balance is attributed to the currency
/// declared on the person (or the provided [defaultCurrency] when the
/// person has no explicit currency).
class GetCurrencyAggregatesUseCase {
  CurrencyAggregates call({
    required List<Person> persons,
    required Map<String, double> balances,
    required String defaultCurrency,
  }) {
    return calculate((persons, balances, defaultCurrency));
  }

  static CurrencyAggregates calculate(
    (List<Person>, Map<String, double>, String) input,
  ) {
    final persons = input.$1;
    final balances = input.$2;
    final defaultCurrency = input.$3;

    final receivable = <String, double>{};
    final payable = <String, double>{};

    for (final person in persons) {
      final balance = balances[person.id] ?? 0.0;
      if (balance == 0) continue;

      final currency = person.currencyCode ?? defaultCurrency;

      if (person.role == PersonRole.customer) {
        // Positive balance = customer owes us (receivable).
        // Negative balance = we owe customer (advance) — counts as payable.
        if (balance > 0) {
          receivable[currency] = (receivable[currency] ?? 0) + balance;
        } else {
          payable[currency] = (payable[currency] ?? 0) + balance.abs();
        }
      } else {
        // Supplier: positive balance = we owe supplier (payable).
        // Negative balance = supplier owes us (advance) — counts as receivable.
        if (balance > 0) {
          payable[currency] = (payable[currency] ?? 0) + balance;
        } else {
          receivable[currency] = (receivable[currency] ?? 0) + balance.abs();
        }
      }
    }

    return CurrencyAggregates(
      receivableByCurrency: receivable,
      payableByCurrency: payable,
    );
  }
}
