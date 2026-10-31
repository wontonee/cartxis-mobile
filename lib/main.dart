import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cartxis_app/app.dart';
import 'package:cartxis_app/core/config/api_config.dart';
import 'package:cartxis_app/core/theme/theme_controller.dart';
import 'package:cartxis_app/core/utils/crashlytics_filters.dart';
import 'package:cartxis_app/core/utils/currency_utils.dart';
import 'package:cartxis_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Forward Flutter framework + async errors to Crashlytics.
  // NetworkImage HTTP failures (e.g. missing avatar 404) are non-fatal —
  // they are UI degradations handled by errorBuilder, not app crashes.
  FlutterError.onError = (details) {
    if (isBenignImageLoadError(details.exception)) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterError(details);
      return;
    }
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    final fatal = !isBenignImageLoadError(error);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
    return true;
  };

  // Allow self-signed certificates in development mode
  if (!ApiConfig.isProduction) {
    HttpOverrides.global = _DevHttpOverrides();
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await ThemeController.instance.load();
  CurrencyUtils.preload();

  runApp(const CartxisApp());
}

/// HTTP Overrides for development to accept self-signed certificates
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
