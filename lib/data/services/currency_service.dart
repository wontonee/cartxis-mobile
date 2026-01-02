import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_model.dart';
import '../models/api_response.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class CurrencyService {
  final ApiClient _apiClient = ApiClient();
  static const String _currencyKey = 'default_currency';
  
  CurrencyModel? _cachedCurrency;

  /// Get default currency from API or cache
  Future<CurrencyModel> getDefaultCurrency({bool forceRefresh = false}) async {
    // Return cached currency if available and not forcing refresh
    if (_cachedCurrency != null && !forceRefresh) {
      return _cachedCurrency!;
    }

    try {
      // Try to get from local storage first
      if (!forceRefresh) {
        final cachedCurrency = await _getCachedCurrency();
        if (cachedCurrency != null) {
          _cachedCurrency = cachedCurrency;
          return cachedCurrency;
        }
      }

      // Fetch from API
      print('🌍 Fetching default currency from API...');
      final response = await _apiClient.get(ApiConfig.currencyDefault);

      if (response['success'] == false) {
        throw ApiException(
          message: response['message'] ?? 'Failed to fetch default currency',
          code: response['error_code'] ?? 'CURRENCY_FETCH_FAILED',
        );
      }

      // Parse response
      final apiResponse = ApiResponse<CurrencyModel>.fromJson(
        response,
        (data) => CurrencyModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          code: apiResponse.errorCode ?? 'CURRENCY_FETCH_FAILED',
        );
      }

      final currency = apiResponse.data!;
      
      // Cache the currency
      await _cacheCurrency(currency);
      _cachedCurrency = currency;

      print('✅ Default currency loaded: ${currency.code} (${currency.symbol})');

      return currency;
    } catch (e) {
      print('❌ Error fetching default currency: $e');
      
      // Try to return cached currency as fallback
      final cachedCurrency = await _getCachedCurrency();
      if (cachedCurrency != null) {
        print('📦 Using cached currency as fallback');
        _cachedCurrency = cachedCurrency;
        return cachedCurrency;
      }

      // If all else fails, return a default currency
      print('⚠️ Using hardcoded fallback currency');
      return _getHardcodedFallback();
    }
  }

  /// Cache currency to local storage
  Future<void> _cacheCurrency(CurrencyModel currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, jsonEncode(currency.toJson()));
      print('💾 Currency cached successfully');
    } catch (e) {
      print('⚠️ Failed to cache currency: $e');
    }
  }

  /// Get cached currency from local storage
  Future<CurrencyModel?> _getCachedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyJson = prefs.getString(_currencyKey);
      
      if (currencyJson != null) {
        final data = jsonDecode(currencyJson) as Map<String, dynamic>;
        return CurrencyModel.fromJson(data);
      }
    } catch (e) {
      print('⚠️ Failed to get cached currency: $e');
    }
    return null;
  }

  /// Clear cached currency
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currencyKey);
      _cachedCurrency = null;
      print('🗑️ Currency cache cleared');
    } catch (e) {
      print('⚠️ Failed to clear currency cache: $e');
    }
  }

  /// Get hardcoded fallback currency (INR to match your API)
  CurrencyModel _getHardcodedFallback() {
    return CurrencyModel(
      id: 0,
      name: 'Indian Rupee',
      code: 'INR',
      symbol: '₹',
      symbolPosition: 'before',
      decimalPlaces: 2,
      decimalSeparator: '.',
      thousandSeparator: ',',
    );
  }

  /// Format amount with default currency
  Future<String> formatAmount(double amount, {bool forceRefresh = false}) async {
    final currency = await getDefaultCurrency(forceRefresh: forceRefresh);
    return currency.formatAmount(amount);
  }

  /// Get currency symbol only
  Future<String> getSymbol({bool forceRefresh = false}) async {
    final currency = await getDefaultCurrency(forceRefresh: forceRefresh);
    return currency.symbol;
  }

  /// Get currency code only
  Future<String> getCode({bool forceRefresh = false}) async {
    final currency = await getDefaultCurrency(forceRefresh: forceRefresh);
    return currency.code;
  }

  /// Get cached currency synchronously (if available)
  CurrencyModel? getCachedCurrencySync() {
    return _cachedCurrency;
  }
}
