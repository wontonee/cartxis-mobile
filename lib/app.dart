import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vortex_app/core/theme/app_theme.dart';
import 'package:vortex_app/routes/app_router.dart';
import 'package:vortex_app/data/services/api_sync_service.dart';

class CartxisApp extends StatefulWidget {
  const CartxisApp({super.key});

  @override
  State<CartxisApp> createState() => _CartxisAppState();
}

class _CartxisAppState extends State<CartxisApp> with WidgetsBindingObserver {
  final ApiSyncService _apiSyncService = ApiSyncService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sendHeartbeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sendHeartbeat();
    }
  }

  Future<void> _sendHeartbeat() async {
    try {
      await _apiSyncService.sendHeartbeat();
    } catch (_) {
      // Ignore heartbeat errors to avoid blocking the app
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Cartxis',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // TODO: Make this configurable via settings
      
      // Routing
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      
      // Localization (TODO: Add when implementing i18n)
      // locale: const Locale('en', 'US'),
      // supportedLocales: const [
      //   Locale('en', 'US'),
      // ],
      
      // Builder for global configurations
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling beyond reasonable limits
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
