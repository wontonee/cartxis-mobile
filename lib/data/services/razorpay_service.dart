import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onError;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  /// Open Razorpay checkout
  /// 
  /// Parameters:
  /// - [amount]: Amount in smallest currency unit (paise for INR, cents for USD)
  /// - [orderId]: Order ID from your backend (optional but recommended)
  /// - [name]: Business/Product name
  /// - [description]: Payment description
  /// - [prefillContact]: Customer's phone number
  /// - [prefillEmail]: Customer's email
  /// - [key]: Razorpay API Key (Test/Live)
  /// - [themeColor]: Optional theme color for Razorpay UI
  void openCheckout({
    required int amount,
    required String key,
    String? orderId,
    required String name,
    required String description,
    String? prefillContact,
    String? prefillEmail,
    String? themeColor,
  }) {
    final options = {
      'key': key,
      'amount': amount, // Amount in smallest currency unit (e.g., paise)
      'name': name,
      'description': description,
      'timeout': 300, // in seconds (5 minutes)
      'currency': 'INR',
      if (orderId != null) 'order_id': orderId,
      'prefill': {
        if (prefillContact != null) 'contact': prefillContact,
        if (prefillEmail != null) 'email': prefillEmail,
      },
      'theme': {
        'color': themeColor ?? '#3399cc',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
    }
  }

  /// Clear all event listeners
  void dispose() {
    _razorpay.clear();
  }

  /// Get error message from error code
  String getErrorMessage(int code) {
    switch (code) {
      case Razorpay.NETWORK_ERROR:
        return 'Network error. Please check your internet connection.';
      case Razorpay.INVALID_OPTIONS:
        return 'Invalid payment options. Please try again.';
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment was cancelled.';
      case Razorpay.TLS_ERROR:
        return 'Device security issue. Please update your device.';
      default:
        return 'Payment failed. Please try again.';
    }
  }
}
