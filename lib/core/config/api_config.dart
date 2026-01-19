/// API Configuration
class ApiConfig {
  ApiConfig._();

  // Environment Configuration
  static const bool isProduction = false; // Change to true for production

  // Base URLs
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  // Use your actual local IP (e.g., 192.168.x.x) for physical devices
  static const String testBaseUrl = 'https://cartxis.test';

  //'http://192.168.1.13:8000'; // Android emulator special IP
  static const String productionBaseUrl =
      'https://api.vortex.com'; // Update with actual production URL

  // Current Base URL based on environment
  static String get baseUrl => isProduction ? productionBaseUrl : testBaseUrl;

  // API Version
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String authLogin = '/api/$apiVersion/auth/login';
  static const String authRegister = '/api/$apiVersion/auth/register';
  static const String authLogout = '/api/$apiVersion/auth/logout';
  static const String authMe = '/api/$apiVersion/auth/me';
  static const String authForgotPassword =
      '/api/$apiVersion/auth/forgot-password';
  static const String authResetPassword =
      '/api/$apiVersion/auth/reset-password';
  static const String authVerifyEmail = '/api/$apiVersion/auth/verify-email';

  // Customer Endpoints
  static const String customerProfile = '/api/$apiVersion/customer/profile';
  static const String wishlist = '/api/$apiVersion/customer/wishlist';
  static const String wishlistAdd = '/api/$apiVersion/customer/wishlist/add';

  // Currency Endpoints
  static const String currencyDefault = '/api/$apiVersion/currency/default';

  // System Sync Endpoints
  static const String apiSyncHeartbeat = '/api/$apiVersion/system/api-sync/heartbeat';
  static const String apiSyncStatus = '/api/$apiVersion/system/api-sync/status';

  // Product Endpoints
  static const String products = '/api/$apiVersion/products';
  static const String productsFeatured = '/api/$apiVersion/products/featured';
  static const String productsNewArrivals =
      '/api/$apiVersion/products/new-arrivals';
  static const String productsOnSale = '/api/$apiVersion/products/on-sale';

  // Category Endpoints
  static const String categories = '/api/$apiVersion/categories';

  // Banner Endpoints
  static const String banners = '/api/$apiVersion/banners';

  // Timeout Settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Device Information
  static const String deviceName = 'Flutter App'; // Can be updated dynamically

  // Full URL Helper
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
