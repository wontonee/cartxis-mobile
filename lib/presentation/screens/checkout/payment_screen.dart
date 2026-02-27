import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/services/checkout_service.dart';
import 'package:vortex_app/presentation/screens/checkout/review_screen.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';

class PaymentScreen extends StatefulWidget {
  final List<dynamic> paymentMethods;
  final Map<String, dynamic>? checkoutSummary;
  final Map<String, dynamic> selectedAddress;
  final Map<String, dynamic> selectedShippingMethod;

  const PaymentScreen({
    super.key,
    required this.paymentMethods,
    this.checkoutSummary,
    required this.selectedAddress,
    required this.selectedShippingMethod,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final CheckoutService _checkoutService = CheckoutService();
  String? _selectedPayment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-select first payment method
    if (widget.paymentMethods.isNotEmpty) {
      _selectedPayment = widget.paymentMethods[0]['code'];
    }
  }

  IconData _getIconForPaymentMethod(String iconName) {
    switch (iconName) {
      case 'credit-card':
        return Icons.credit_card;
      case 'stripe':
        return Icons.credit_card;
      case 'razorpay':
        return Icons.bolt;
      case 'money':
        return Icons.payments;
      case 'upi':
        return Icons.qr_code_scanner;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Color _getColorForPaymentMethod(String code) {
    switch (code) {
      case 'stripe':
        return Colors.blue;
      case 'razorpay':
        return const Color(0xFF092642);
      case 'cod':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: isDark 
                    ? const Color(0xFF101922).withOpacity(0.95) 
                    : const Color(0xFFF6F7F8).withOpacity(0.95),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Tabs
                      _buildProgressTabs(isDark),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Select Payment Option',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Payment Methods
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.paymentMethods.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final method = widget.paymentMethods[index];
                          return _buildPaymentOption(method, isDark);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2936) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark 
                        ? const Color(0xFF334155) 
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total to pay',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade600,
                          ),
                        ),
                        StyledPriceText(
                          amount: (widget.checkoutSummary?['total'] as num?)?.toDouble() ?? 0.0,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Continue Button
                    ElevatedButton(
                      onPressed: _isLoading || _selectedPayment == null
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              
                              try {
                                // Fetch checkout summary (payment method is set in review_screen
                                // for each gateway — Razorpay, Stripe, and COD/PhonePe/others)
                                final summary = await _checkoutService.getCheckoutSummary();
                                
                                // Get selected payment method details
                                final selectedPaymentMethod = widget.paymentMethods.firstWhere(
                                  (method) => method['code'] == _selectedPayment,
                                  orElse: () => {},
                                );
                                
                                // Navigate to review screen
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReviewScreen(
                                        checkoutSummary: summary,
                                        selectedAddress: widget.selectedAddress,
                                        selectedShippingMethod: widget.selectedShippingMethod,
                                        selectedPaymentMethod: selectedPaymentMethod,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to proceed: $e'),
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
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            const Text(
                              'Continue to Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (!_isLoading) const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Security Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 14,
                          color: isDark 
                              ? Colors.grey.shade500 
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '100% SECURE PAYMENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: isDark 
                                ? Colors.grey.shade500 
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTabs(bool isDark) {
    return Column(
      children: [
        // Tab Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Payment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Review',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Progress Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.67, // 2/3 progress
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Step 3 of 4',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(Map<String, dynamic> method, bool isDark) {
    final bool isSelected = _selectedPayment == method['code'];
    final String code = method['code'] ?? '';
    final String name = method['name'] ?? '';
    final String description = method['description'] ?? '';
    final String iconName = method['icon'] ?? '';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = code;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark 
                  ? AppColors.primary.withOpacity(0.1) 
                  : AppColors.primary.withOpacity(0.05))
              : (isDark ? const Color(0xFF1E2936) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : (isDark 
                    ? const Color(0xFF334155) 
                    : const Color(0xFFE2E8F0)),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon/Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getColorForPaymentMethod(code).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForPaymentMethod(iconName),
                color: _getColorForPaymentMethod(code),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primary 
                      : (isDark 
                          ? const Color(0xFF475569) 
                          : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
                color: isSelected 
                    ? AppColors.primary 
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
