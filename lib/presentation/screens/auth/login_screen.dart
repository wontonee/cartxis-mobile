import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/core/constants/app_sizes.dart';
import 'package:vortex_app/core/constants/app_strings.dart';
import 'package:vortex_app/core/theme/text_styles.dart';
import 'package:vortex_app/data/services/auth_service.dart';
import 'package:vortex_app/data/services/app_settings_service.dart';
import 'package:vortex_app/core/network/api_exception.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _settingsService = AppSettingsService();
  String? _logoUrl;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogoUrl();
  }

  Future<void> _loadLogoUrl() async {
    final url = await _settingsService.getMobileAuthLogo();
    if (mounted) {
      setState(() {
        _logoUrl = url;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call API to login
        final loginData = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${loginData.user.name}!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // TODO v2: Google & Apple login
  // void _onGoogleLogin() {
  //   // TODO: Implement Google login
  // }

  // void _onAppleLogin() {
  //   // TODO: Implement Apple login
  // }

  void _onForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  void _onRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.xl,
              ),
              child: Card(
                elevation: MediaQuery.of(context).size.width > 500 ? 8 : 0,
                color: MediaQuery.of(context).size.width > 500 
                    ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width > 500 
                      ? AppSizes.xl 
                      : 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        _buildHeader(isDark),

                        const SizedBox(height: 32),

                        // Email Field
                        _buildEmailField(isDark),

                        const SizedBox(height: 20),

                        // Password Field
                        _buildPasswordField(isDark),

                        const SizedBox(height: 16),

                        // Remember Me & Forgot Password
                        _buildRememberMeRow(isDark),

                        const SizedBox(height: 24),

                        // Login Button
                        _buildLoginButton(),

                        const SizedBox(height: 24),

                        // Divider
                        // TODO v2: Social login divider & buttons (Google/Apple)
                        // _buildDivider(isDark),
                        // const SizedBox(height: 24),
                        // _buildSocialLoginButtons(isDark),
                        // const SizedBox(height: 32),

                        // Register Link
                        _buildRegisterLink(isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Logo — fetched from /api/v1/app/settings (mobile_auth_logo).
        // Falls back to assets/transparent_logo.png if admin has not set one.
        SizedBox(
          width: 200,
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: _logoUrl != null
                ? Image.network(
                    _logoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/transparent_logo.png',
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    'assets/transparent_logo.png',
                    fit: BoxFit.contain,
                  ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          AppStrings.welcomeBack,
          style: AppTextStyles.headline1.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
            fontSize: 32,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          AppStrings.loginSubtitle,
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.emailAddress,
          style: AppTextStyles.label.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.enterEmail,
            prefixIcon: Icon(
              Icons.mail_outline,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.password,
          style: AppTextStyles.label.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.darkText : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.enterPassword,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRememberMeRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me Checkbox
        InkWell(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.rememberMe,
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Forgot Password
        TextButton(
          onPressed: _onForgotPassword,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            AppStrings.forgotPassword,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppStrings.login,
                style: AppTextStyles.button,
              ),
      ),
    );
  }

  // TODO v2: Social login divider — re-enable when Google/Apple login is implemented
  // Widget _buildDivider(bool isDark) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Divider(
  //           color: isDark ? AppColors.borderDark : AppColors.borderLight,
  //           thickness: 1,
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Text(
  //           AppStrings.orContinueWith,
  //           style: AppTextStyles.captionBold.copyWith(
  //             color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  //             fontSize: 11,
  //             letterSpacing: 0.5,
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         child: Divider(
  //           color: isDark ? AppColors.borderDark : AppColors.borderLight,
  //           thickness: 1,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // TODO v2: Social login buttons \u2014 re-enable when Google/Apple login is implemented
  // Widget _buildSocialLoginButtons(bool isDark) {
  //   return Row(
  //     children: [
  //       // Google Button
  //       Expanded(
  //         child: OutlinedButton(
  //           onPressed: _onGoogleLogin,
  //           style: OutlinedButton.styleFrom(
  //             foregroundColor: isDark ? AppColors.darkText : AppColors.textPrimary,
  //             side: BorderSide(
  //               color: isDark ? AppColors.borderDark : AppColors.borderLight,
  //             ),
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //             backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Image.network('https://lh3.googleusercontent.com/...', width: 20, height: 20),
  //               const SizedBox(width: 8),
  //               Text(AppStrings.google),
  //             ],
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       // Apple Button
  //       Expanded(
  //         child: OutlinedButton(
  //           onPressed: _onAppleLogin,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.apple, size: 24),
  //               const SizedBox(width: 8),
  //               Text(AppStrings.apple),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildRegisterLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _onRegister,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.only(left: 4),
          ),
          child: Text(
            AppStrings.register,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
