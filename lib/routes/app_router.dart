import 'package:flutter/material.dart';
import 'package:vortex_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:vortex_app/presentation/screens/auth/login_screen.dart';
import 'package:vortex_app/presentation/screens/auth/register_screen.dart';
import 'package:vortex_app/presentation/screens/auth/reset_password_screen.dart';
import 'package:vortex_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:vortex_app/presentation/screens/splash/splash_screen.dart';
import 'package:vortex_app/presentation/screens/products/product_list_screen.dart';
import 'package:vortex_app/presentation/screens/products/product_detail_screen.dart';
import 'package:vortex_app/presentation/screens/categories/categories_screen.dart';
import 'package:vortex_app/presentation/screens/main/main_navigation_screen.dart';
import 'package:vortex_app/presentation/screens/checkout/shipping_screen.dart';
import 'package:vortex_app/presentation/screens/checkout/review_screen.dart';
import 'package:vortex_app/presentation/screens/checkout/order_success_screen.dart';
import 'package:vortex_app/presentation/screens/order/order_detail_screen.dart';
import 'package:vortex_app/presentation/screens/order/order_list_screen.dart';
import 'package:vortex_app/presentation/screens/profile/edit_profile_screen.dart';
import 'package:vortex_app/presentation/screens/profile/address_management_screen.dart';
import 'package:vortex_app/presentation/screens/support/help_support_screen.dart';
import 'package:vortex_app/presentation/screens/support/about_us_screen.dart';
import 'package:vortex_app/presentation/screens/support/terms_conditions_screen.dart';
import 'package:vortex_app/presentation/screens/support/privacy_policy_screen.dart';
import 'package:vortex_app/presentation/screens/search/search_screen.dart';

/// App router configuration
class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetail = '/product-detail';
  static const String categories = '/categories';
  static const String shipping = '/shipping';
  static const String payment = '/payment';
  static const String review = '/review';
  static const String orderSuccess = '/order-success';
  static const String orderDetail = '/order-detail';
  static const String orderList = '/order-list';
  static const String editProfile = '/edit-profile';
  static const String addressManagement = '/address-management';
  static const String helpSupport = '/help-support';
  static const String aboutUs = '/about-us';
  static const String termsConditions = '/terms-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String search = '/search';

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );

      case productList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductListScreen(
            category: args?['category'] ?? 'Sneakers',
          ),
          settings: settings,
        );

      case productDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: args?['product'] ?? {},
          ),
          settings: settings,
        );

      case categories:
        return MaterialPageRoute(
          builder: (_) => const CategoriesScreen(),
          settings: settings,
        );

      case shipping:
        return MaterialPageRoute(
          builder: (_) => const ShippingScreen(),
          settings: settings,
        );

      // Payment screen now requires parameters - navigate with data from ShippingScreen
      // case payment:
      //   return MaterialPageRoute(
      //     builder: (_) => const PaymentScreen(),
      //     settings: settings,
      //   );

      case review:
        return MaterialPageRoute(
          builder: (_) => const ReviewScreen(),
          settings: settings,
        );

      case orderSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderNumber: args?['orderNumber'] ?? '#VX-000000',
            totalAmount: args?['totalAmount'] ?? 0.0,
            estimatedDelivery: args?['estimatedDelivery'] ?? 'TBD',
          ),
          settings: settings,
        );

      case orderDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            orderNumber: args?['orderNumber'] ?? '#ORD-000000',
            orderDate: args?['orderDate'] ?? 'Unknown date',
            orderStatus: args?['orderStatus'] ?? 'Processing',
            totalAmount: args?['totalAmount'] ?? 0.0,
          ),
          settings: settings,
        );

      case orderList:
        return MaterialPageRoute(
          builder: (_) => const OrderListScreen(),
          settings: settings,
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );

      case addressManagement:
        return MaterialPageRoute(
          builder: (_) => const AddressManagementScreen(),
          settings: settings,
        );

      case helpSupport:
        return MaterialPageRoute(
          builder: (_) => const HelpSupportScreen(),
          settings: settings,
        );

      case aboutUs:
        return MaterialPageRoute(
          builder: (_) => const AboutUsScreen(),
          settings: settings,
        );

      case termsConditions:
        return MaterialPageRoute(
          builder: (_) => const TermsConditionsScreen(),
          settings: settings,
        );

      case privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
          settings: settings,
        );

      case search:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SearchScreen(
            initialQuery: args?['query'] as String?,
          ),
          settings: settings,
        );

      // TODO: Add more routes as we implement more screens

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Page transitions
  static Route<dynamic> fadeTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<dynamic> slideTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
