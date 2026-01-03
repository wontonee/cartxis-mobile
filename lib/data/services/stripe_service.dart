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
      return;
    }

    try {
      
      // Set the publishable key
      Stripe.publishableKey = publishableKey;
      
      // Important: Ensure the instance is created and configured
      await Stripe.instance.applySettings();
      
      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Open Stripe payment sheet
  /// 
  /// Parameters:
  /// - [clientSecret]: Payment Intent client secret from backend
  /// - [merchantDisplayName]: Business name to display
  /// - [customerEmail]: Customer's email (optional)
  /// - [customerName]: Customer's full name (required for Indian regulations)
  /// - [addressLine1]: Billing address line 1 (required for Indian regulations)
  /// - [addressLine2]: Billing address line 2 (optional)
  /// - [city]: Billing city (required for Indian regulations)
  /// - [state]: Billing state (optional)
  /// - [postalCode]: Billing postal code (optional)
  /// - [country]: Billing country code (default: 'IN')
  /// - [phone]: Customer's phone number (required for Indian regulations)
  Future<void> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
    String? customerEmail,
    String? customerName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
  }) async {
    if (!_isInitialized) {
      throw Exception('Stripe not initialized. Call initialize() first.');
    }

    try {

      // First, try to retrieve the Payment Intent to check for errors
      try {
        final paymentIntentId = clientSecret.split('_secret_').first;
        
        final retrievedIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
        
        if (retrievedIntent.status == PaymentIntentsStatus.Canceled) {
          throw Exception('Payment Intent has been canceled. Please create a new order.');
        }
        
        if (retrievedIntent.status == PaymentIntentsStatus.Succeeded) {
          throw Exception('Payment Intent already succeeded. Please create a new order.');
        }
      } catch (e) {
      }

      // Validate required fields for Indian regulations
      if (customerName == null || customerName.isEmpty) {
        throw Exception('Customer name is required for Indian payments');
      }
      if (addressLine1 == null || addressLine1.isEmpty) {
        throw Exception('Billing address is required for Indian payments');
      }
      if (city == null || city.isEmpty) {
        throw Exception('Billing city is required for Indian payments');
      }
      if (postalCode == null || postalCode.isEmpty) {
        throw Exception('Postal code is required for Indian payments');
      }

      // Initialize payment sheet with billing details (required for Indian regulations)
      // For Indian export regulations, billing details MUST be provided
      final billingAddress = Address(
        line1: addressLine1,
        line2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country ?? 'IN',
      );
      
      final billing = BillingDetails(
        name: customerName,
        email: customerEmail,
        phone: phone,
        address: billingAddress,
      );
      
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
          billingDetails: billing,
          billingDetailsCollectionConfiguration: BillingDetailsCollectionConfiguration(
            name: CollectionMode.always,
            email: CollectionMode.always,
            phone: CollectionMode.always,
            address: AddressCollectionMode.full,
            attachDefaultsToPaymentMethod: true,
          ),
        ),
      );


      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      
      // Extract payment intent ID from client secret
      final paymentIntentId = clientSecret.split('_secret_').first;
      onSuccess?.call(paymentIntentId);

    } on StripeException catch (e) {
      
      if (e.error.code == FailureCode.Canceled) {
        onCancelled?.call();
      } else {
        final errorMsg = e.error.message ?? 
                        e.error.localizedMessage ?? 
                        'Payment failed: ${e.error.code?.name ?? "Unknown error"}';
        onError?.call(errorMsg);
      }
    } catch (e) {
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
