import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PayPal Payment Gateway Service (WebView-based)
//
// Flow:
//   1. Backend creates a PayPal Order (v2) and returns approve_url + paypal_order_id
//   2. Flutter opens PaypalWebViewScreen with the approve_url
//   3. User logs in and approves payment on PayPal's page
//   4. PayPal redirects to return_url — URL contains ?token=ORDER_ID&PayerID=...
//   5. WebView detects the PayerID param → closes and returns PayPalResult.success
//   6. Caller then calls backend verifyPayment(paypal_order_id)
//      → backend CAPTURES the order and marks it COMPLETED
//
// iOS / Android setup: webview_flutter ^4.x — no extra platform config needed.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────── result type ──

/// Result returned after the PayPal WebView closes.
class PayPalResult {
  final bool isSuccess;
  final bool isCancelled;

  /// PayPal Order ID (same value the backend generated — echoed back by PayPal
  /// in the ?token= query param of the return URL).
  final String? paypalOrderId;

  /// PayPal Payer ID returned on successful approval.
  final String? payerId;

  final String? errorMessage;

  const PayPalResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.paypalOrderId,
    this.payerId,
    this.errorMessage,
  });

  factory PayPalResult.success({
    required String paypalOrderId,
    String? payerId,
  }) =>
      PayPalResult._(
        isSuccess: true,
        isCancelled: false,
        paypalOrderId: paypalOrderId,
        payerId: payerId,
      );

  factory PayPalResult.cancelled() => const PayPalResult._(
        isSuccess: false,
        isCancelled: true,
      );

  factory PayPalResult.failure(String errorMessage) => PayPalResult._(
        isSuccess: false,
        isCancelled: false,
        errorMessage: errorMessage,
      );

  @override
  String toString() =>
      'PayPalResult(success=$isSuccess, cancelled=$isCancelled, '
      'orderId=$paypalOrderId, payerId=$payerId, error=$errorMessage)';
}

// ─────────────────────────────────────────────────────── service ──

class PayPalService {
  /// Open the PayPal checkout WebView and await the user's action.
  ///
  /// Returns a [PayPalResult] that is:
  ///   • [PayPalResult.success] when PayPal redirects with PayerID in the URL
  ///   • [PayPalResult.cancelled] when the user cancels
  ///   • [PayPalResult.failure] when an error occurs
  ///
  /// After a successful result, call the backend verifyPayment endpoint with
  /// [PayPalResult.paypalOrderId] so the backend can capture and mark the order.
  Future<PayPalResult> launchCheckout({
    required BuildContext context,
    required String approveUrl,

    /// The URL prefix to watch for after PayPal approval (return_url).
    /// Any URL containing `PayerID=` is treated as successful by default, so
    /// this is only needed if you want to restrict to a specific domain.
    String? returnUrlPrefix,

    /// The URL prefix to watch for when the user cancels.
    String? cancelUrlPrefix,
  }) async {
    try {
      final result = await Navigator.of(context).push<PayPalResult>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _PayPalWebViewScreen(
            approveUrl: approveUrl,
            returnUrlPrefix: returnUrlPrefix,
            cancelUrlPrefix: cancelUrlPrefix,
          ),
        ),
      );

      return result ?? PayPalResult.cancelled();
    } catch (e) {
      return PayPalResult.failure('PayPal launch error: $e');
    }
  }
}

// ─────────────────────────────────────────────────────── internal screen ──

class _PayPalWebViewScreen extends StatefulWidget {
  final String approveUrl;
  final String? returnUrlPrefix;
  final String? cancelUrlPrefix;

  const _PayPalWebViewScreen({
    required this.approveUrl,
    this.returnUrlPrefix,
    this.cancelUrlPrefix,
  });

  @override
  State<_PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<_PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasReturned = false; // guard against double-pop

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (err) {
            // Ignore ERR_ABORTED which fires when we programmatically navigate away
            if (err.errorCode == -3) return;
            if (!_hasReturned) {
              _hasReturned = true;
              Navigator.of(context).pop(
                PayPalResult.failure('Page load error: ${err.description}'),
              );
            }
          },
          onNavigationRequest: (req) => _handleNavigation(req.url),
        ),
      )
      ..loadRequest(Uri.parse(widget.approveUrl));
  }

  NavigationDecision _handleNavigation(String url) {
    if (_hasReturned) return NavigationDecision.prevent;

    final uri = Uri.tryParse(url);
    if (uri == null) return NavigationDecision.navigate;

    // ── Check for successful approval ─────────────────────────────────────
    // After the user approves, PayPal appends ?token=ORDER_ID&PayerID=PAYER_ID
    final payerId = uri.queryParameters['PayerID'];
    final token = uri.queryParameters['token'];

    final matchesReturn = widget.returnUrlPrefix != null
        ? url.startsWith(widget.returnUrlPrefix!)
        : true; // match any URL that has PayerID

    if (payerId != null && payerId.isNotEmpty && matchesReturn) {
      _hasReturned = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop(
            PayPalResult.success(
              paypalOrderId: token ?? '',
              payerId: payerId,
            ),
          );
        }
      });
      return NavigationDecision.prevent;
    }

    // ── Check for cancellation ────────────────────────────────────────────
    // PayPal appends ?token=ORDER_ID to the cancel_url (no PayerID)
    final matchesCancel = widget.cancelUrlPrefix != null
        ? url.startsWith(widget.cancelUrlPrefix!)
        : false;

    if (matchesCancel && payerId == null) {
      _hasReturned = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(PayPalResult.cancelled());
      });
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _onUserCancel() {
    if (!_hasReturned) {
      _hasReturned = true;
      Navigator.of(context).pop(PayPalResult.cancelled());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Checkout'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel payment',
          onPressed: _onUserCancel,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
