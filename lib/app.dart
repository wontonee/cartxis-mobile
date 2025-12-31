import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vortex_app/core/theme/app_theme.dart';
import 'package:vortex_app/routes/app_router.dart';

class VortexApp extends StatelessWidget {
  const VortexApp({super.key});

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
      title: 'Vortex eCommerce',
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
