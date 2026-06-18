import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';

/// Provider that exposes the [ExchangeRateService].
final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  final baseCurrency = ref.watch(currencyProvider);
  return ExchangeRateService(baseCurrency: baseCurrency);
});

/// Stores user-defined exchange rates relative to the app's base currency.
///
/// Rates are stored as `1 baseCurrency = X targetCurrency`.
/// For example, if base = USD and target = SAR, the stored value is 3.75
/// (meaning 1 USD = 3.75 SAR).
///
/// Rates persist across sessions via [SharedPreferences]. They are intentionally
/// manual — the app does not fetch live FX rates — so the user has full control
/// over the conversion used in the dashboard's "Total" card.
class ExchangeRateService {
  ExchangeRateService({required this.baseCurrency});

  /// The currency the dashboard total is displayed in.
  final String baseCurrency;

  static const String _prefix = 'fx_rate_';

  /// In-memory cache to avoid hitting SharedPreferences on every read.
  /// Map of currencyCode → rate (1 base = rate currencyCode).
  final Map<String, double> _cache = {};

  /// Loads all stored rates into [_cache]. Safe to call multiple times.
  Future<void> load() async {
    if (_cache.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      final code = key.substring(_prefix.length);
      final value = prefs.getDouble(key);
      if (value != null) _cache[code] = value;
    }
  }

  /// Returns the rate for [currencyCode] relative to [baseCurrency].
  /// Defaults to 1.0 when the currency equals the base or when no rate is set.
  Future<double> getRate(String currencyCode) async {
    if (currencyCode == baseCurrency) return 1.0;
    await load();
    return _cache[currencyCode] ?? 1.0;
  }

  /// Synchronous variant — uses cached rates only. Call [load] first.
  double getRateSync(String currencyCode) {
    if (currencyCode == baseCurrency) return 1.0;
    return _cache[currencyCode] ?? 1.0;
  }

  /// Sets or updates the rate for [currencyCode].
  /// `rate` means: 1 [baseCurrency] = `rate` [currencyCode].
  Future<void> setRate(String currencyCode, double rate) async {
    if (currencyCode == baseCurrency) return; // base is always 1.0
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_prefix$currencyCode', rate);
    _cache[currencyCode] = rate;
  }

  /// Clears the stored rate for [currencyCode] (falls back to 1.0).
  Future<void> clearRate(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$currencyCode');
    _cache.remove(currencyCode);
  }

  /// Returns all configured (non-base) currencies and their rates.
  Future<Map<String, double>> getAllRates() async {
    await load();
    return Map<String, double>.from(_cache);
  }

  /// Converts [amount] from [fromCurrency] to [baseCurrency]
  /// using the stored rate.
  ///
  /// Example: base=USD, from=SAR, rate=3.75 → amount=100 SAR → 100/3.75 = 26.67 USD
  double convertToBase(double amount, String fromCurrency) {
    if (fromCurrency == baseCurrency) return amount;
    final rate = getRateSync(fromCurrency);
    if (rate == 0) return amount;
    return amount / rate;
  }

  /// Converts [amount] from [baseCurrency] to [toCurrency].
  double convertFromBase(double amount, String toCurrency) {
    if (toCurrency == baseCurrency) return amount;
    final rate = getRateSync(toCurrency);
    return amount * rate;
  }
}
