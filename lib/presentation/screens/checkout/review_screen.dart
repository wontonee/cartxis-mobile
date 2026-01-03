import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/services/checkout_service.dart';
import 'package:vortex_app/data/services/cart_service.dart';
import 'package:vortex_app/data/services/razorpay_service.dart';
import 'package:vortex_app/data/services/stripe_service.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';

class ReviewScreen extends StatefulWidget {
  final Map<String, dynamic> checkoutSummary;
  final Map<String, dynamic> selectedAddress;
  final Map<String, dynamic> selectedShippingMethod;
  final Map<String, dynamic> selectedPaymentMethod;
  
  const ReviewScreen({
    super.key,
    required this.checkoutSummary,
    required this.selectedAddress,
    required this.selectedShippingMethod,
    required this.selectedPaymentMethod,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final CheckoutService _checkoutService = CheckoutService();
  final CartService _cartService = CartService();
  final RazorpayService _razorpayService = RazorpayService();
  final StripeService _stripeService = StripeService();
  final TextEditingController _notesController = TextEditingController();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final cartModel = await _cartService.getCart();
      setState(() {
        _cartItems = cartModel.items.map((item) => {
          'product': {
            'name': item.product.name,
            'image_url': item.product.images.isNotEmpty 
                ? (item.product.images[0] is String 
                    ? item.product.images[0] 
                    : item.product.images[0]['url'] ?? '')
                : '',
            'price': item.price,
          },
          'quantity': item.quantity,
          'price': item.price,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double get _subtotal => (widget.checkoutSummary['subtotal'] as num?)?.toDouble() ?? 0.0;
  double get _shipping => (widget.checkoutSummary['shipping_cost'] as num?)?.toDouble() ?? 0.0;
  double get _tax => (widget.checkoutSummary['tax'] as num?)?.toDouble() ?? 0.0;
  double get _discount => (widget.checkoutSummary['discount'] as num?)?.toDouble() ?? 0.0;
  double get _total => (widget.checkoutSummary['total'] as num?)?.toDouble() ?? 0.0;

  @override
  void dispose() {
    _notesController.dispose();
    _razorpayService.dispose();
    _stripeService.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Extract required data
      
      final shippingAddressId = widget.selectedAddress['id'] as int?;
      final paymentMethodCode = widget.selectedPaymentMethod['code'] as String?;
      final notes = _notesController.text.trim();
      
      if (shippingAddressId == null) {
        throw Exception('Shipping address is required');
      }
      if (paymentMethodCode == null) {
        throw Exception('Payment method is required');
      }
      
      // Check if Razorpay payment
      if (paymentMethodCode.toLowerCase() == 'razorpay') {
        await _processRazorpayPayment(
          shippingAddressId: shippingAddressId,
          notes: notes.isNotEmpty ? notes : null,
        );
      } else if (paymentMethodCode.toLowerCase() == 'stripe') {
        // Handle Stripe payment
        await _processStripePayment(
          shippingAddressId: shippingAddressId,
          notes: notes.isNotEmpty ? notes : null,
        );
      } else {
        // For other payment methods (COD, etc), place order directly
        await _placeOrderDirect(
          shippingAddressId: shippingAddressId,
          paymentMethod: paymentMethodCode,
          notes: notes.isNotEmpty ? notes : null,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  Future<void> _processRazorpayPayment({
    required int shippingAddressId,
    String? notes,
  }) async {
    try {
      // First, set the payment method to get gateway configuration
      final paymentMethodData = await _checkoutService.setPaymentMethod('razorpay');
      
      final gatewayConfig = paymentMethodData['gateway_config'] as Map<String, dynamic>?;
      
      if (gatewayConfig == null) {
        throw Exception('Gateway configuration not available for Razorpay');
      }
      
      final razorpayKey = gatewayConfig['key_id'] as String?;
      final businessName = gatewayConfig['name'] as String? ?? 'Vortex';
      final themeColor = gatewayConfig['theme_color'] as String? ?? '#3399cc';
      
      if (razorpayKey == null || razorpayKey.isEmpty) {
        throw Exception('Razorpay key not found in gateway configuration');
      }
      
      // Setup Razorpay callbacks
      _razorpayService.onSuccess = (PaymentSuccessResponse response) async {
        
        // Place order with payment ID
        try {
          final result = await _checkoutService.placeOrder(
            shippingAddressId: shippingAddressId,
            paymentMethod: 'razorpay',
            notes: notes,
            paymentId: response.paymentId,
            orderId: response.orderId,
            signature: response.signature,
          );
          
          final orderNumber = result['order_number'] ?? '#VX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
          
          // Clear cart after successful order
          await _cartService.clearCart();
          
          // Navigate to success screen
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/order-success',
              arguments: {
                'orderNumber': orderNumber,
                'totalAmount': _total,
                'estimatedDelivery': 'Mon, Aug 24',
              },
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order placement failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isPlacingOrder = false;
            });
          }
        }
      };

      _razorpayService.onError = (PaymentFailureResponse response) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_razorpayService.getErrorMessage(response.code ?? 0)),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isPlacingOrder = false;
          });
        }
      };

      _razorpayService.onExternalWallet = (ExternalWalletResponse response) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('External wallet selected: ${response.walletName}'),
            ),
          );
        }
      };

      // Open Razorpay checkout
      final amountInPaise = (_total * 100).toInt(); // Convert to paise
      final customerPhone = widget.selectedAddress['phone']?.toString() ?? '';
      final customerEmail = widget.selectedAddress['email']?.toString() ?? '';
      
      
      _razorpayService.openCheckout(
        amount: amountInPaise,
        key: razorpayKey,
        name: businessName,
        description: 'Order Payment',
        prefillContact: customerPhone,
        prefillEmail: customerEmail,
        themeColor: themeColor,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment initialization failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  Future<void> _processStripePayment({
    required int shippingAddressId,
    String? notes,
  }) async {
    try {
      // First, set the payment method to get gateway configuration
      final paymentMethodData = await _checkoutService.setPaymentMethod('stripe');
      
      final gatewayConfig = paymentMethodData['gateway_config'] as Map<String, dynamic>?;
      
      if (gatewayConfig == null) {
        throw Exception('Gateway configuration not available for Stripe');
      }
      
      // Try multiple possible key names for publishable key
      final publishableKey = gatewayConfig['publishable_key'] as String? ?? 
                            gatewayConfig['key'] as String? ?? 
                            gatewayConfig['stripe_key'] as String? ??
                            gatewayConfig['public_key'] as String?;
      
      // Try multiple possible key names for client secret
      final clientSecret = gatewayConfig['client_secret'] as String? ?? 
                          gatewayConfig['payment_intent_client_secret'] as String?;
      
      final paymentIntentId = gatewayConfig['payment_intent_id'] as String?;
      
      final merchantName = gatewayConfig['name'] as String? ?? 
                          gatewayConfig['merchant_name'] as String? ?? 
                          'Vortex';
      
      final currency = gatewayConfig['currency'] as String? ?? 'USD';
      
      if (publishableKey == null || publishableKey.isEmpty) {
        throw Exception('Stripe publishable key not found in gateway configuration. Available keys: ${gatewayConfig.keys.join(", ")}');
      }
      
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Payment intent client secret not found. Backend must create a Payment Intent and return the client_secret.');
      }
      
      // Initialize Stripe with publishable key
      await _stripeService.initialize(publishableKey);
      
      // Small delay to ensure Stripe SDK is fully initialized
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Setup Stripe callbacks
      _stripeService.onSuccess = (String paymentIntentId) async {
        
        // Place order with payment intent ID
        try {
          final result = await _checkoutService.placeOrder(
            shippingAddressId: shippingAddressId,
            paymentMethod: 'stripe',
            notes: notes,
            paymentId: paymentIntentId,
          );
          
          final orderNumber = result['order_number'] ?? '#VX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
          
          // Clear cart after successful order
          await _cartService.clearCart();
          
          // Navigate to success screen
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/order-success',
              arguments: {
                'orderNumber': orderNumber,
                'totalAmount': _total,
                'estimatedDelivery': 'Mon, Aug 24',
              },
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order placement failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isPlacingOrder = false;
            });
          }
        }
      };

      _stripeService.onError = (String errorMessage) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isPlacingOrder = false;
          });
        }
      };

      _stripeService.onCancelled = () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isPlacingOrder = false;
          });
        }
      };

      // Present Stripe payment sheet
      // Get billing address from checkout summary
      final billingAddressData = widget.checkoutSummary['billing_address'];
      
      // Determine which address to use for billing
      Map<String, dynamic> addressToUse;
      
      if (billingAddressData is Map<String, dynamic>) {
        // Check if it's a flag indicating to use shipping address
        final useShippingAddress = billingAddressData['use_shipping_address'] == true;
        
        // Check if billing address has street address (try both field name formats)
        final hasAddress = (billingAddressData['address1']?.toString() ?? 
                           billingAddressData['address_line1']?.toString() ?? 
                           billingAddressData['address_line_1']?.toString() ?? '').isNotEmpty;
        
        if (useShippingAddress || !hasAddress) {
          // Backend says to use shipping address OR billing address is incomplete
          addressToUse = widget.selectedAddress;
        } else {
          // Use the billing address from checkout summary
          addressToUse = billingAddressData;
        }
      } else {
        // No billing address in summary, use shipping address
        addressToUse = widget.selectedAddress;
      }
      
      // Map the address fields - API uses different field names (address1, address_line1, or address_line_1)
      final customerEmail = addressToUse['email']?.toString() ?? widget.selectedAddress['email']?.toString();
      final customerName = (addressToUse['full_name']?.toString() ?? 
                           '${addressToUse['first_name'] ?? ''} ${addressToUse['last_name'] ?? ''}'.trim());
      final customerPhone = addressToUse['phone']?.toString();
      final addressLine1 = addressToUse['address1']?.toString() ?? 
                          addressToUse['address_line1']?.toString() ?? 
                          addressToUse['address_line_1']?.toString();
      final addressLine2 = addressToUse['address2']?.toString() ?? 
                          addressToUse['address_line2']?.toString() ?? 
                          addressToUse['address_line_2']?.toString();
      final city = addressToUse['city']?.toString();
      final state = addressToUse['state']?.toString();
      final postalCode = addressToUse['zip_code']?.toString() ?? 
                        addressToUse['postal_code']?.toString() ?? 
                        addressToUse['zipcode']?.toString();
      final country = addressToUse['country']?.toString() ?? 'IN';
      
      // Validate required fields for Indian regulations
      if (customerName.isEmpty) {
        throw Exception('Customer name is required. Please update your address.');
      }
      if (addressLine1 == null || addressLine1.isEmpty) {
        throw Exception('Street address is required. Please update your address with complete street address.');
      }
      if (city == null || city.isEmpty) {
        throw Exception('City is required. Please update your address.');
      }
      if (postalCode == null || postalCode.isEmpty) {
        throw Exception('Postal/ZIP code is required. Please update your address with postal code.');
      }
      
      await _stripeService.presentPaymentSheet(
        clientSecret: clientSecret,
        merchantDisplayName: merchantName,
        customerEmail: customerEmail,
        customerName: customerName,
        phone: customerPhone,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment initialization failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  Future<void> _placeOrderDirect({
    required int shippingAddressId,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      // Place the order via API
      final result = await _checkoutService.placeOrder(
        shippingAddressId: shippingAddressId,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      
      final orderNumber = result['order_number'] ?? '#VX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Clear cart after successful order
      await _cartService.clearCart();
      
      // Navigate to success screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/order-success',
          arguments: {
            'orderNumber': orderNumber,
            'totalAmount': _total,
            'estimatedDelivery': 'Mon, Aug 24',
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
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
                  'Review Order',
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Steps
                      _buildProgressSteps(isDark),

                      const SizedBox(height: 24),

                      _buildCartItemsSection(),
                      const SizedBox(height: 24),
                      _buildShippingPaymentSection(),
                      const SizedBox(height: 24),
                      _buildOrderNotesSection(),
                      const SizedBox(height: 24),
                      _buildOrderSummarySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressSteps(bool isDark) {
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
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Review',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
            widthFactor: 1.0, // 3/3 progress - completed
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Step indicator
        Text(
          'Step 3 of 3',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items in your cart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_cartItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No items in cart'),
            ),
          )
        else
          ..._cartItems.map((item) => _buildCartItem(item)).toList(),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final product = item['product'] ?? {};
    final productName = product['name'] ?? item['name'] ?? 'Product';
    final productImage = product['image_url'] ?? item['image'] ?? '';
    final quantity = item['quantity'] ?? 1;
    final variant = item['variant'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
              image: productImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(productImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: productImage.isEmpty
                ? const Icon(Icons.image, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: $quantity',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (variant != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Size: ${variant['size'] ?? ''} • ${variant['color'] ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          StyledPriceText(
            amount: (item['price'] as num?)?.toDouble() ?? 0.0,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping & Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.location_on,
          title: 'SHIPPING ADDRESS',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.selectedAddress['name'] ?? 'Shipping Address',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.selectedAddress['address'] ?? ''}\n${widget.selectedAddress['city'] ?? ''}, ${widget.selectedAddress['state'] ?? ''} ${widget.selectedAddress['postal_code'] ?? ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.receipt_long,
          title: 'BILLING ADDRESS',
          child: Text(
            'Same as shipping address',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.local_shipping,
          title: 'SHIPPING METHOD',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedShippingMethod['name'] ?? 'Standard Shipping',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.selectedShippingMethod['description'] ?? 'Delivery information',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              StyledPriceText(
                amount: (widget.checkoutSummary['shipping_cost'] as num?)?.toDouble() ?? 0.0,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.credit_card,
          title: 'PAYMENT METHOD',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (widget.selectedPaymentMethod['code'] ?? 'PAYMENT').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F71),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.selectedPaymentMethod['name'] ?? 'Selected payment method',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Handle edit action
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F1F1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note to your order (optional)',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F1F1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal', _subtotal),
              const SizedBox(height: 12),
              _buildSummaryRow('Shipping', _shipping),
              const SizedBox(height: 12),
              _buildSummaryRow(
                  'Tax (Estimated)', _tax),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Discount (SummerSale)',
                -_discount,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: const Color(0xFFF1F1F1),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  StyledPriceText(
                    amount: _total,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.grey[600],
            fontWeight: color != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        StyledPriceText(
          amount: value,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
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
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPlacingOrder)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          StyledPriceText(
                            amount: _total,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
