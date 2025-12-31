import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'All Orders',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  // Mock order data
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '12345',
      'date': 'Oct 24, 2023 at 4:30 PM',
      'status': 'Processing',
      'statusColor': 'blue',
      'icon': Icons.sync,
      'productImage': 'https://via.placeholder.com/80x80/4A90E2/FFFFFF?text=Shoe',
      'productName': 'Nike Air Max 270',
      'itemCount': '+ 2 other items',
      'totalPrice': 145.00,
      'actions': ['View Details'],
    },
    {
      'id': '12344',
      'date': 'Oct 10, 2023 at 10:15 AM',
      'status': 'Delivered',
      'statusColor': 'green',
      'icon': Icons.check_circle,
      'productImage': 'https://via.placeholder.com/80x80/7CB342/FFFFFF?text=KB',
      'productName': 'Keychron K2 Pro',
      'itemCount': '1 item',
      'totalPrice': 89.50,
      'actions': ['Leave Review', 'Buy Again'],
    },
    {
      'id': '12342',
      'date': 'Sep 28, 2023 at 2:20 PM',
      'status': 'Cancelled',
      'statusColor': 'red',
      'icon': Icons.cancel,
      'productImage': 'https://via.placeholder.com/80x80/999999/FFFFFF?text=Mug',
      'productName': 'Ceramic Coffee Mug',
      'itemCount': '+ 1 other item',
      'totalPrice': 24.00,
      'actions': ['View Details'],
      'isCancelled': true,
    },
    {
      'id': '12350',
      'date': 'Yesterday at 9:00 AM',
      'status': 'Pending',
      'statusColor': 'amber',
      'icon': Icons.schedule,
      'productImage': 'https://via.placeholder.com/80x80/000000/FFFFFF?text=HP',
      'productName': 'Sony WH-1000XM5',
      'itemCount': '1 item',
      'totalPrice': 348.00,
      'actions': ['Track Order'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredOrders() {
    if (_selectedTabIndex == 0) return _orders; // All Orders
    
    final selectedStatus = _tabs[_selectedTabIndex];
    return _orders.where((order) => order['status'] == selectedStatus).toList();
  }

  Color _getStatusColor(String colorName, bool isDark) {
    switch (colorName) {
      case 'blue':
        return isDark ? Colors.blue.shade900.withOpacity(0.4) : Colors.blue.shade100;
      case 'green':
        return isDark ? Colors.green.shade900.withOpacity(0.4) : Colors.green.shade100;
      case 'red':
        return isDark ? Colors.red.shade900.withOpacity(0.4) : Colors.red.shade100;
      case 'amber':
        return isDark ? Colors.amber.shade900.withOpacity(0.4) : Colors.amber.shade100;
      default:
        return isDark ? Colors.grey.shade900.withOpacity(0.4) : Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String colorName, bool isDark) {
    switch (colorName) {
      case 'blue':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'green':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'red':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'amber':
        return isDark ? Colors.amber.shade300 : Colors.amber.shade700;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredOrders = _getFilteredOrders();
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8)).withOpacity(0.95),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark 
                            ? const Color(0xFF1E293B).withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'My Orders',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),

          // Order List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((_) {
                return filteredOrders.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredOrders.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          return _buildOrderCard(filteredOrders[index], isDark);
                        },
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark) {
    final isCancelled = order['isCancelled'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2A36) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isCancelled ? 0.8 : 1.0,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)).withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withOpacity(0.5),
                  ),
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order #${order['id']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['statusColor'] as String, isDark),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order['icon'] as IconData,
                          size: 14,
                          color: _getStatusTextColor(order['statusColor'] as String, isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order['status'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusTextColor(order['statusColor'] as String, isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order['productImage'] as String,
                        fit: BoxFit.cover,
                        colorBlendMode: isCancelled ? BlendMode.saturation : null,
                        color: isCancelled ? Colors.grey : null,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['productName'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCancelled
                                ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                : (isDark ? Colors.white : const Color(0xFF0F172A)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['itemCount'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '\$${order['totalPrice'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isCancelled
                                ? (isDark ? Colors.grey.shade500 : Colors.grey.shade500)
                                : AppColors.primary,
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildActionButtons(order['actions'] as List<String>, order['status'] as String, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(List<String> actions, String status, bool isDark) {
    if (actions.length == 1) {
      final action = actions[0];
      return SizedBox(
        width: double.infinity,
        height: 36,
        child: ElevatedButton(
          onPressed: () {
            if (action == 'Track Order') {
              Navigator.pushNamed(context, '/order-detail', arguments: {
                'orderNumber': '12350',
                'orderDate': 'Yesterday at 9:00 AM',
                'orderStatus': 'Pending',
                'totalAmount': 348.00,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$action coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: action == 'Track Order'
                ? AppColors.primary
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            foregroundColor: action == 'Track Order'
                ? Colors.white
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
            elevation: action == 'Track Order' ? 2 : 0,
            shadowColor: action == 'Track Order' ? AppColors.primary.withOpacity(0.3) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${actions[0]} coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actions[0],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${actions[1]} coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actions[1],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
