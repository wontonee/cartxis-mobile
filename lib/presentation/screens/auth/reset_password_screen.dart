import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/core/constants/app_sizes.dart';
import 'package:vortex_app/core/theme/text_styles.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.66; // Medium by default

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() => _passwordStrength = 0);
      return;
    }

    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    setState(() => _passwordStrength = strength);
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.33) return Colors.red;
    if (_passwordStrength < 0.66) return Colors.orange;
    if (_passwordStrength < 1.0) return Colors.yellow.shade600;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_passwordStrength < 0.33) return 'Weak';
    if (_passwordStrength < 0.66) return 'Fair';
    if (_passwordStrength < 1.0) return 'Medium';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.backgroundDark.withOpacity(0.95)
                    : AppColors.backgroundLight.withOpacity(0.95),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark 
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the layout
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Headline
                      Text(
                        'Create new password',
                        style: AppTextStyles.headline1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        'Your new password must be different from previous used passwords.',
                        style: AppTextStyles.body2.copyWith(
                          color: isDark 
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // New Password Field
                      Text(
                        'New Password',
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark 
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onChanged: _calculatePasswordStrength,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: isDark 
                              ? Colors.grey.shade800
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password Strength Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password Strength',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark 
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            _getStrengthText(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStrengthColor(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Segmented Progress Bar
                      Row(
                        children: [
                          for (int i = 0; i < 4; i++) ...[
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: i < (_passwordStrength * 4).round()
                                      ? (i == 0 || i == 1 
                                          ? AppColors.primary 
                                          : (i == 2 
                                              ? (isDark 
                                                  ? Colors.yellow.shade600.withOpacity(0.3)
                                                  : Colors.yellow.shade600.withOpacity(0.5))
                                              : (isDark 
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade200)))
                                      : (isDark 
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade200),
                                ),
                              ),
                            ),
                            if (i < 3) const SizedBox(width: 6),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Must contain at least 8 characters, 1 number, and 1 symbol.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark 
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Confirm Password Field
                      Text(
                        'Confirm Password',
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark 
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: isDark 
                              ? Colors.grey.shade800
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Handle password reset
                      // Show success and navigate to login
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: isDark 
                        ? Colors.transparent
                        : Colors.blue.shade500.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Reset Password',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
