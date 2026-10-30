import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cartxis_app/core/constants/app_colors.dart';
import 'package:cartxis_app/core/constants/app_strings.dart';
import 'package:cartxis_app/data/services/auth_service.dart';
import 'package:cartxis_app/presentation/screens/auth/widgets/auth_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    _entrance.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait<Object?>([
      _authService.isLoggedIn(),
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);

    if (!mounted) return;

    final isLoggedIn = results.first as bool;
    Navigator.of(context).pushReplacementNamed(
      isLoggedIn ? '/home' : '/onboarding',
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.backgroundLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Soft brand atmosphere — light canvas, not a heavy blue wash.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    AppColors.backgroundLight,
                    Color(0xFFEAF4FF),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(
                size: 220,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -90,
              child: _GlowOrb(
                size: 280,
                color: AppColors.primaryLight.withValues(alpha: 0.12),
              ),
            ),

            // Brand mark
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AuthLogo(
                          width: 248,
                          height: 96,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Commerce, simplified',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom progress + version
            Positioned(
              left: 0,
              right: 0,
              bottom: bottom + 40,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        return SizedBox(
                          width: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.12,
                              ),
                              color: AppColors.primary.withValues(
                                alpha: 0.55 + (_pulse.value * 0.35),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'v${AppStrings.appVersion}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                        color: AppColors.textHint.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
