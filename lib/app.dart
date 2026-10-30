import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cartxis_app/core/theme/app_theme.dart';
import 'package:cartxis_app/core/theme/theme_controller.dart';
import 'package:cartxis_app/routes/app_router.dart';
import 'package:cartxis_app/data/services/api_sync_service.dart';

class CartxisApp extends StatefulWidget {
  const CartxisApp({super.key});

  @override
  State<CartxisApp> createState() => _CartxisAppState();
}

class _CartxisAppState extends State<CartxisApp> with WidgetsBindingObserver {
  final ApiSyncService _apiSyncService = ApiSyncService();
  final ThemeController _themeController = ThemeController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeController.addListener(_onThemeChanged);
    _sendHeartbeat();
  }

  @override
  void dispose() {
    _themeController.removeListener(_onThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
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

  void _applySystemUi(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDark ? const Color(0xFF101922) : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartxis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeController.themeMode,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        _applySystemUi(Theme.of(context).brightness);
        return MediaQuery(
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
