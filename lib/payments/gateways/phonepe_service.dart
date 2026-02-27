import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// PhonePe Payment Gateway Service
//
// SDK docs:
//   https://developer.phonepe.com/payment-gateway/mobile-app-integration/
//          standard-checkout-mobile/flutter/sdk-setup
//
// pubspec.yaml dependency (add when enabling PhonePe):
//   phonepe_payment_sdk: ^2.0.0     # check pub.dev for the latest version
//   Run: flutter pub add phonepe_payment_sdk
//
// Android – project-level build.gradle (android/build.gradle.kts):
//   Add to repositories:
//     maven { url = uri("https://phonepe.mycloudrepo.io/public/repositories/phonepe-intentsdk-android") }
//
//   MainActivity.kt must extend FlutterFragmentActivity:
//     import io.flutter.embedding.android.FlutterFragmentActivity
//     class MainActivity : FlutterFragmentActivity()
//
// iOS – Runner/Info.plist:
//   Add LSApplicationQueriesSchemes array:
//     ppemerchantsdkv1, ppemerchantsdkv2, ppemerchantsdkv3, paytmmp, gpay
//   Create a custom URL scheme (e.g. "cartxisapp") under CFBundleURLTypes.
//   In AppDelegate.m add inside openURL:
//     NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
//     [userInfo setObject:options forKey:@"options"];
//     [userInfo setObject:url forKey:@"openUrl"];
//     [[NSNotificationCenter defaultCenter]
//         postNotificationName:@"ApplicationOpenURLNotification"
//         object:nil userInfo:userInfo];
//     return YES;
// ─────────────────────────────────────────────────────────────────────────────

import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

/// Available PhonePe environments.
enum PhonePeEnvironment {
  /// UAT / sandbox – use for development and testing.
  sandbox,

  /// Live environment – use for production.
  production,
}

/// Result of a PhonePe transaction attempt.
class PhonePeResult {
  /// `true` when payment completed successfully.
  final bool isSuccess;

  /// `true` when the user dismissed the PhonePe payment sheet.
  final bool isCancelled;

  /// Raw status string returned by the SDK: SUCCESS | FAILURE | INTERRUPTED.
  final String status;

  /// Error description when [isSuccess] is `false`.
  final String? errorMessage;

  /// PhonePe order ID (from the backend Create Order API response).
  final String? orderId;

  /// PhonePe transaction ID returned by the native SDK on success (may be null).
  final String? transactionId;

  const PhonePeResult._({
    required this.isSuccess,
    required this.isCancelled,
    required this.status,
    this.errorMessage,
    this.orderId,
    this.transactionId,
  });

  factory PhonePeResult.success(String orderId, {String? transactionId}) =>
      PhonePeResult._(
        isSuccess: true,
        isCancelled: false,
        status: 'SUCCESS',
        orderId: orderId,
        transactionId: transactionId,
      );

  factory PhonePeResult.failure(String errorMessage) => PhonePeResult._(
        isSuccess: false,
        isCancelled: false,
        status: 'FAILURE',
        errorMessage: errorMessage,
      );

  factory PhonePeResult.interrupted() => PhonePeResult._(
        isSuccess: false,
        isCancelled: true,
        status: 'INTERRUPTED',
        errorMessage: 'Payment was interrupted by the user.',
      );
}

/// Service that wraps the PhonePe Flutter SDK for Standard Checkout.
///
/// Usage flow:
///   1. Call [initialize] once (e.g. on app start / first checkout).
///   2. Your **backend** calls PhonePe's Create Order API and returns
///      `orderId` + `token` to the app.
///   3. Call [startTransaction] with those values.
///   4. Check [PhonePeResult.isSuccess] and verify via backend webhook or
///      PhonePe's Check Order Status API.
class PhonePeService {
  bool _isInitialized = false;

  /// The URL scheme registered in iOS Info.plist (CFBundleURLTypes).
  /// Only used on iOS – ignored on Android.
  /// Example: "cartxisapp"
  // ignore: unused_field
  static const String _iosAppSchema = 'cartxisapp';

  // ──────────────────────────────────────────────────────────── lifecycle ──

  /// Initialize the PhonePe SDK.
  ///
  /// Call this once before invoking [startTransaction].
  ///
  /// - [merchantId]  : Merchant ID provided by PhonePe at onboarding.
  /// - [environment] : [PhonePeEnvironment.sandbox] for UAT/testing,
  ///                   [PhonePeEnvironment.production] for live.
  /// - [flowId]      : Any unique alphanumeric string (e.g. logged-in user ID
  ///                   or UUID). Helps PhonePe debug production issues.
  /// - [enableLogging]: Set `true` in debug, `false` in production builds.
  Future<bool> initialize({
    required String merchantId,
    PhonePeEnvironment environment = PhonePeEnvironment.sandbox,
    bool enableLogging = false,
  }) async {
    // Always re-initialize to ensure the correct merchantId and environment
    // are applied, even when retrying after a failed attempt.
    _isInitialized = false;

    final environmentValue =
        environment == PhonePeEnvironment.sandbox ? 'SANDBOX' : 'PRODUCTION';

    // SDK v3 signature: init(environment, merchantId, flowId, enableLogs)
    // flowId must be a non-empty alphanumeric string — used for analytics/debugging.
    // merchantId MUST be the short PhonePe merchant ID (e.g. M22TUU3OAID7Z).
    final flowId = DateTime.now().millisecondsSinceEpoch.toString();
    final result = await PhonePePaymentSdk.init(
      environmentValue,
      merchantId,  // short PhonePe merchant ID
      flowId,      // unique per session
      enableLogging,
    );

    _isInitialized = result;
    return result;
  }

  // ──────────────────────────────────────────────────────── transaction ──

  /// Launch the PhonePe Standard Checkout payment sheet.
  ///
  /// Prerequisites:
  ///   - [initialize] must have been called and returned `true`.
  ///   - Your backend must have called PhonePe's Create Order API and returned
  ///     [orderId] and [token].
  ///
  /// Parameters:
  ///   - [orderId]    : PhonePe-generated order ID from the backend.
  ///   - [merchantId] : Same merchant ID used during [initialize].
  ///   - [token]      : Order token from the backend Create Order API response.
  ///
  /// Returns a [PhonePeResult] — always check [PhonePeResult.isSuccess].
  /// Verify final payment status on your backend via webhook or Order Status API.
  Future<PhonePeResult> startTransaction({
    required String orderId,
    required String merchantId,
    required String token,
  }) async {
    if (!_isInitialized) {
      return PhonePeResult.failure(
          'PhonePe SDK not initialized. Call initialize() first.');
    }

    // Build the request payload as per PhonePe Standard Checkout docs.
    // body MUST be plain jsonEncode (not base64) — the native SDK forwards it
    // to PhonePe as-is. The backend checksum is SHA256(base64(body)+secret)###1.
    final Map<String, dynamic> payload = {
      'orderId': orderId,
      'merchantId': merchantId,
      'token': token,
      'paymentMode': {'type': 'PAY_PAGE'},
    };
    final String body = jsonEncode(payload);

    try {
      // SDK v3 startTransaction only takes (request, appSchema) — no checksum.
      // The JWT order token in the body authenticates the request.
      final Map<dynamic, dynamic>? response =
          await PhonePePaymentSdk.startTransaction(
        body,         // plain JSON string
        _iosAppSchema,
      );

      if (response == null) {
        return PhonePeResult.failure('No response from PhonePe SDK.');
      }

      final String status = response['status']?.toString() ?? 'FAILURE';
      final String? error = response['error']?.toString();

      switch (status) {
        case 'SUCCESS':
          // Extract transaction ID if the native SDK includes it in the response.
          final String? txnId = response['transactionId']?.toString() ??
              response['transaction_id']?.toString();
          return PhonePeResult.success(orderId, transactionId: txnId);
        case 'INTERRUPTED':
          return PhonePeResult.interrupted();
        default:
          return PhonePeResult.failure(
              error ?? 'Payment failed. Please try again.');
      }
    } catch (e) {
      return PhonePeResult.failure('PhonePe error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────── status ──

  /// Reset the service (e.g. on logout so a fresh merchant ID can be used).
  void reset() {
    _isInitialized = false;
  }
}
