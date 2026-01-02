import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/razorpay_service.dart';

/// Test screen for Razorpay integration
/// This is a sample screen to test the payment flow
class RazorpayTestScreen extends StatefulWidget {
  const RazorpayTestScreen({super.key});

  @override
  State<RazorpayTestScreen> createState() => _RazorpayTestScreenState();
}

class _RazorpayTestScreenState extends State<RazorpayTestScreen> {
  final _razorpayService = RazorpayService();
  final _amountController = TextEditingController(text: '100');
  final _nameController = TextEditingController(text: 'Test Product');
  final _descriptionController = TextEditingController(text: 'Test Payment');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // TODO: Replace with your actual Razorpay Test Key from dashboard
  final _razorpayTestKey = 'rzp_test_YOUR_KEY_HERE';
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    // Set up payment callbacks
    _razorpayService.onSuccess = _handlePaymentSuccess;
    _razorpayService.onError = _handlePaymentError;
    _razorpayService.onExternalWallet = _handleExternalWallet;
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _amountController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    // TODO: Verify payment on your backend using response.paymentId
    // Send to your backend: paymentId, orderId, signature for verification
    
    _showDialog(
      title: 'Payment Successful!',
      message: 'Payment ID: ${response.paymentId}\nOrder ID: ${response.orderId}',
      isSuccess: true,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    final errorMessage = _razorpayService.getErrorMessage(response.code);
    
    _showDialog(
      title: 'Payment Failed',
      message: '$errorMessage\n\nCode: ${response.code}\nMessage: ${response.message}',
      isSuccess: false,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    _showDialog(
      title: 'External Wallet',
      message: 'Wallet: ${response.walletName}',
      isSuccess: true,
    );
  }

  void _showDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startPayment() {
    if (_razorpayTestKey == 'rzp_test_YOUR_KEY_HERE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please update _razorpayTestKey with your actual Razorpay Test Key'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Amount should be in smallest currency unit (paise for INR)
    // For example: ₹100 = 10000 paise
    final amountInPaise = amount * 100;

    _razorpayService.openCheckout(
      amount: amountInPaise,
      key: _razorpayTestKey,
      name: _nameController.text,
      description: _descriptionController.text,
      prefillEmail: _emailController.text.isNotEmpty ? _emailController.text : null,
      prefillContact: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      // orderId: 'order_xyz123', // TODO: Generate order ID from your backend
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay Test'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Test Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is a test screen for Razorpay integration. Update the Razorpay Test Key in the code before testing.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            _buildTextField(
              controller: _amountController,
              label: 'Amount (₹)',
              hint: 'Enter amount in rupees',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.currency_rupee,
            ),
            const SizedBox(height: 16),

            // Product Name
            _buildTextField(
              controller: _nameController,
              label: 'Product/Service Name',
              hint: 'Enter product name',
              prefixIcon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter payment description',
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: 16),

            // Email (Optional)
            _buildTextField(
              controller: _emailController,
              label: 'Email (Optional)',
              hint: 'customer@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),

            // Phone (Optional)
            _buildTextField(
              controller: _phoneController,
              label: 'Phone (Optional)',
              hint: '9876543210',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 32),

            // Pay Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _startPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Pay with Razorpay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Test Cards Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Card Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTestCardInfo('Card Number', '4111 1111 1111 1111'),
                  _buildTestCardInfo('CVV', 'Any 3 digits'),
                  _buildTestCardInfo('Expiry', 'Any future date'),
                  const SizedBox(height: 8),
                  const Text(
                    'More test cards: razorpay.com/docs/payments/payments/test-card-upi-details/',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade200 : const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(prefixIcon, size: 20),
            filled: true,
            fillColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTestCardInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
