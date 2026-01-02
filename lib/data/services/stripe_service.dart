import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  bool _isInitialized = false;
  
  Function(String paymentIntentId)? onSuccess;
  Function(String errorMessage)? onError;
  Function()? onCancelled;

  /// Initialize Stripe with publishable key
  Future<void> initialize(String publishableKey) async {
    if (_isInitialized) {
      debugPrint('⚠️ Stripe already initialized');
      return;
    }

    try {
      debugPrint('🔑 Initializing Stripe with key: ${publishableKey.substring(0, 20)}...');
      Stripe.publishableKey = publishableKey;
      _isInitialized = true;
      debugPrint('✅ Stripe initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Stripe: $e');
      rethrow;
    }
  }

  /// Open Stripe payment sheet
  /// 
  /// Parameters:
  /// - [clientSecret]: Payment Intent client secret from backend
  /// - [merchantDisplayName]: Business name to display
  /// - [customerEmail]: Customer's email (optional)
  Future<void> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
    String? customerEmail,
  }) async {
    if (!_isInitialized) {
      throw Exception('Stripe not initialized. Call initialize() first.');
    }

    try {
      debugPrint('💳 Initializing Stripe payment sheet...');
      debugPrint('   Merchant: $merchantDisplayName');
      debugPrint('   Client secret: ${clientSecret.substring(0, 20)}...');

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          customerEphemeralKeySecret: null, // Optional: for saved cards
          customerId: null, // Optional: for saved cards
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF3399cc),
                  text: Colors.white,
                  border: Color(0xFF3399cc),
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF3399cc),
                  text: Colors.white,
                  border: Color(0xFF3399cc),
                ),
              ),
            ),
          ),
        ),
      );

      debugPrint('✅ Payment sheet initialized');

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      debugPrint('✅ Payment completed successfully');
      
      // Extract payment intent ID from client secret
      final paymentIntentId = clientSecret.split('_secret_').first;
      onSuccess?.call(paymentIntentId);

    } on StripeException catch (e) {
      debugPrint('❌ Stripe error: ${e.error.message}');
      
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('💭 Payment cancelled by user');
        onCancelled?.call();
      } else {
        onError?.call(e.error.message ?? 'Payment failed');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      onError?.call('Payment failed: $e');
    }
  }

  /// Get user-friendly error message
  String getErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'canceled':
        return 'Payment was cancelled.';
      case 'Failed':
        return 'Payment failed. Please try again.';
      default:
        return 'Payment failed. Please try again.';
    }
  }

  /// Clear callbacks
  void dispose() {
    onSuccess = null;
    onError = null;
    onCancelled = null;
  }
}
