import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderNumber;
  final double totalAmount;
  final String estimatedDelivery;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.estimatedDelivery,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _iconController;
  late AnimationController _decorationsController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _decorationsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _iconController.dispose();
    _decorationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A2632) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _buildSuccessIcon(isDark),
                      const SizedBox(height: 32),
                      const Text(
                        'Order Placed!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your order has been placed successfully. Thank you for shopping with us!',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildOrderDetailsCard(isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButtons(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(bool isDark) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing background
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.2 + (_pulseController.value * 0.3),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue.shade900.withOpacity(0.3)
                        : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // Main icon
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _iconController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 56,
              ),
            ),
          ),

          // Decorative icons
          _buildFloatingIcon(
            Icons.star,
            Colors.yellow.shade400,
            const Offset(-60, -60),
            0,
          ),
          _buildFloatingIcon(
            Icons.celebration,
            Colors.blue.shade400,
            const Offset(-80, 0),
            300,
          ),
          _buildFloatingIcon(
            Icons.favorite,
            Colors.green.shade400,
            const Offset(60, 40),
            700,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(
    IconData icon,
    Color color,
    Offset offset,
    int delayMilliseconds,
  ) {
    return AnimatedBuilder(
      animation: _decorationsController,
      builder: (context, child) {
        final delay = delayMilliseconds / 1000;
        final value = (_decorationsController.value + delay) % 1.0;
        
        return Transform.translate(
          offset: offset,
          child: Transform.translate(
            offset: Offset(0, -10 * (0.5 - (value - 0.5).abs()) * 2),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetailsCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Order Number',
            widget.orderNumber,
            isDark,
            isOrderNumber: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              height: 1,
            ),
          ),
          _buildDetailRowWithWidget(
            'Amount Paid',
            StyledPriceText(
              amount: widget.totalAmount,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isOrderNumber = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isOrderNumber ? 16 : 14,
            fontWeight: FontWeight.bold,
            fontFamily: isOrderNumber ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithWidget(
    String label,
    Widget valueWidget,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        valueWidget,
      ],
    );
  }

  Widget _buildBottomButtons(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2632) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View Order Details Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to order details
                Navigator.pushNamed(
                  context,
                  '/order-detail',
                  arguments: {
                    'orderNumber': widget.orderNumber,
                    'orderDate': 'Placed on ${DateTime.now().toString().substring(0, 10)} at ${TimeOfDay.now().format(context)}',
                    'orderStatus': 'Processing',
                    'totalAmount': widget.totalAmount,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Order Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Continue Shopping Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                // Pop all routes and return to home with refresh flag
                Navigator.of(context).popUntil((route) {
                  if (route.isFirst) {
                    // Trigger cart refresh on the main screen
                    return true;
                  }
                  return false;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
