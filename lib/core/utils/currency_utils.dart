import '../../data/services/currency_service.dart';
import '../../data/models/currency_model.dart';

/// Global currency utility for easy access throughout the app
class CurrencyUtils {
  static final CurrencyService _currencyService = CurrencyService();
  
  /// Format amount with default currency
  /// Example: formatAmount(1234.56) => "$1,234.56"
  static Future<String> format(double amount) async {
    return await _currencyService.formatAmount(amount);
  }

  /// Get currency symbol
  /// Example: getSymbol() => "$"
  static Future<String> getSymbol() async {
    return await _currencyService.getSymbol();
  }

  /// Get currency code
  /// Example: getCode() => "USD"
  static Future<String> getCode() async {
    return await _currencyService.getCode();
  }

  /// Get full currency model
  static Future<CurrencyModel> getCurrency() async {
    return await _currencyService.getDefaultCurrency();
  }

  /// Get cached currency synchronously (returns null if not cached)
  static CurrencyModel? getCachedCurrency() {
    return _currencyService.getCachedCurrencySync();
  }

  /// Format amount with cached currency (fallback to USD if not cached)
  /// Use this for synchronous formatting (e.g., in build methods)
  static String formatSync(double amount) {
    final cached = _currencyService.getCachedCurrencySync();
    if (cached != null) {
      return cached.formatAmount(amount);
    }
    // Fallback: basic USD format
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Preload currency (call this on app startup)
  static Future<void> preload() async {
    try {
      await _currencyService.getDefaultCurrency();
    } catch (e) {
    }
  }

  /// Refresh currency from API
  static Future<void> refresh() async {
    await _currencyService.getDefaultCurrency(forceRefresh: true);
  }

  /// Clear cached currency
  static Future<void> clearCache() async {
    await _currencyService.clearCache();
  }
}
