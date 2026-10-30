import 'package:flutter/material.dart';
import 'package:cartxis_app/core/network/api_exception.dart';
import 'package:cartxis_app/data/services/auth_service.dart';
import 'package:cartxis_app/routes/app_router.dart';

/// Shared cart UX helpers for catalogue screens.
/// Cart mutations require Sanctum; guests get a login prompt instead of a dead-end error.
class CartFeedback {
  CartFeedback._();

  static Future<bool> hasAuthToken() async {
    final token = await AuthService().getToken();
    return token != null && token.isNotEmpty;
  }

  static bool isAuthError(Object error) {
    if (error is ApiException) {
      return error.statusCode == 401 ||
          error.code == 'UNAUTHORIZED' ||
          error.code == 'UNAUTHENTICATED';
    }
    final text = error.toString().toLowerCase();
    return text.contains('unauthorized') ||
        text.contains('unauthenticated') ||
        text.contains('401');
  }

  static String messageForAddError(Object error) {
    if (isAuthError(error)) {
      return 'Please login to add items to cart';
    }
    if (error is ApiException) {
      switch (error.code) {
        case 'PRODUCT_UNAVAILABLE':
          return 'Product not available';
        case 'INSUFFICIENT_STOCK':
          return 'Insufficient stock';
        case 'QUOTE_ONLY_PRODUCT':
          return 'This product requires a quote request';
        case 'NO_INTERNET':
        case 'CONNECTION_FAILED':
          return 'Network error. Please check your connection';
        case 'SERVER_ERROR':
          return 'Server error while adding to cart. Please try again later.';
      }
      final normalized = error.message.trim().toLowerCase();
      if (normalized == 'server error' || normalized == 'server error.') {
        return 'Server error while adding to cart. Please try again later.';
      }
      if (error.message.isNotEmpty) {
        return error.message;
      }
    }
    final text = error.toString();
    if (text.contains('PRODUCT_UNAVAILABLE')) {
      return 'Product not available';
    }
    return 'Failed to add to cart';
  }

  /// Returns false when the user must log in first (snackbar already shown).
  static Future<bool> ensureLoggedIn(BuildContext context) async {
    if (await hasAuthToken()) {
      return true;
    }
    if (context.mounted) {
      showLoginRequired(context);
    }
    return false;
  }

  static void showLoginRequired(
    BuildContext context, {
    String message = 'Please login to add items to cart',
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'LOGIN',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.login);
          },
        ),
      ),
    );
  }

  static void showAddError(BuildContext context, Object error) {
    if (isAuthError(error)) {
      showLoginRequired(context, message: messageForAddError(error));
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(messageForAddError(error))),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
