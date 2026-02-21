import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/services/order_service.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final OrderService _orderService = OrderService();

  // Shimmer animation for skeleton loader
  late AnimationController _shimmerController;

  // Tab labels and their corresponding API status filter values
  final List<String> _tabs = [
    'All Orders',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  // null = no status filter (all orders)
  final List<String?> _statusFilters = [
    null,
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  // Per-tab state
  final Map<int, List<Order>> _ordersCache = {};
  final Map<int, bool> _loadingMap = {};
  final Map<int, bool> _errorMap = {};
  final Map<int, String> _errorMessages = {};
  final Map<int, bool> _hasMoreMap = {};
  final Map<int, int> _pageMap = {};

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final idx = _tabController.index;
        
        // Lazily load the tab the first time it is selected
        if (!_ordersCache.containsKey(idx)) {
          _loadOrdersForTab(idx);
        }
      }
    });
    // Load the first tab immediately
    _loadOrdersForTab(0);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ data --

  Future<void> _loadOrdersForTab(int tabIndex, {bool refresh = false}) async {
    if (_loadingMap[tabIndex] == true) return;

    if (refresh) {
      setState(() {
        _ordersCache.remove(tabIndex);
        _pageMap.remove(tabIndex);
        _hasMoreMap.remove(tabIndex);
        _errorMap.remove(tabIndex);
      });
    }

    // Nothing more to load for this tab
    if (_ordersCache.containsKey(tabIndex) &&
        _hasMoreMap[tabIndex] != true &&
        _hasMoreMap.containsKey(tabIndex) &&
        !refresh) {
      return;
    }

    final page = (_pageMap[tabIndex] ?? 0) + 1;
    final status = _statusFilters[tabIndex];

    setState(() {
      _loadingMap[tabIndex] = true;
      _errorMap[tabIndex] = false;
    });

    try {
      final result = await _orderService.getOrders(status: status, page: page);
      if (!mounted) return;
      setState(() {
        _loadingMap[tabIndex] = false;
        _pageMap[tabIndex] = page;
        final existing = List<Order>.from(_ordersCache[tabIndex] ?? []);
        _ordersCache[tabIndex] = [...existing, ...result.orders];
        // Use server-provided pagination info to stop the loader accurately
        _hasMoreMap[tabIndex] = result.hasMore;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMap[tabIndex] = false;
        _errorMap[tabIndex] = true;
        _errorMessages[tabIndex] =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ---------------------------------------------------------------- helpers --

  Color _statusBgColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'pending':
        return isDark
            ? Colors.amber.shade900.withOpacity(0.4)
            : Colors.amber.shade100;
      case 'processing':
        return isDark
            ? Colors.blue.shade900.withOpacity(0.4)
            : Colors.blue.shade100;
      case 'shipped':
        return isDark
            ? Colors.indigo.shade900.withOpacity(0.4)
            : Colors.indigo.shade100;
      case 'delivered':
        return isDark
            ? Colors.green.shade900.withOpacity(0.4)
            : Colors.green.shade100;
      case 'cancelled':
      case 'canceled':
        return isDark
            ? Colors.red.shade900.withOpacity(0.4)
            : Colors.red.shade100;
      default:
        return isDark
            ? Colors.grey.shade900.withOpacity(0.4)
            : Colors.grey.shade100;
    }
  }

  Color _statusTextColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'pending':
        return isDark ? Colors.amber.shade300 : Colors.amber.shade800;
      case 'processing':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'shipped':
        return isDark ? Colors.indigo.shade300 : Colors.indigo.shade700;
      case 'delivered':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'cancelled':
      case 'canceled':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('MMM dd, yyyy').format(dt.toLocal());
    } catch (_) {
      return rawDate;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ------------------------------------------------------------------- build --

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: (isDark
                      ? const Color(0xFF101922)
                      : const Color(0xFFF6F7F8))
                  .withOpacity(0.95),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
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
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
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
                    // Refresh button
                    IconButton(
                      onPressed: () => _loadOrdersForTab(
                        _tabController.index,
                        refresh: true,
                      ),
                      icon: const Icon(Icons.refresh),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
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
              unselectedLabelColor:
                  isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              labelStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (tabIndex) {
                return _buildTabContent(tabIndex, isDark);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int tabIndex, bool isDark) {
    final isLoading = _loadingMap[tabIndex] == true;
    final hasError = _errorMap[tabIndex] == true;
    final orders = _ordersCache[tabIndex];

    // Initial loading — show skeleton cards.
    // Also covers the brief frame before _loadingMap is set to true.
    if (orders == null && !hasError) {
      // Trigger load if not already in flight
      if (_loadingMap[tabIndex] != true) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _loadOrdersForTab(tabIndex));
      }
      return _buildSkeletonList(isDark);
    }

    // Initial error
    if (orders == null && hasError) {
      return _buildErrorState(
        _errorMessages[tabIndex] ?? 'Something went wrong',
        isDark,
        onRetry: () => _loadOrdersForTab(tabIndex, refresh: true),
      );
    }

    // Empty
    if (orders != null && orders.isEmpty && !isLoading) {
      return _buildEmptyState(isDark);
    }

    // Order list
    final list = orders ?? [];
    // hasMore: only true once we've received a response saying there are more pages
    final hasMore = _hasMoreMap[tabIndex] == true;
    // Show bottom spinner only when actively fetching the next page
    final showBottomLoader = isLoading && list.isNotEmpty;
    return RefreshIndicator(
      onRefresh: () => _loadOrdersForTab(tabIndex, refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (hasMore &&
              !isLoading &&
              notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            _loadOrdersForTab(tabIndex);
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length + (showBottomLoader ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == list.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return _buildOrderCard(list[index], isDark);
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------- order card --

  Widget _buildOrderCard(Order order, bool isDark) {
    final isCancelled = order.status.toLowerCase() == 'cancelled' ||
        order.status.toLowerCase() == 'canceled';
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2A36) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
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
            // ---- header ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC))
                    .withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0))
                        .withOpacity(0.5),
                  ),
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order ${order.orderNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBgColor(order.status, isDark),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(order.status),
                          size: 14,
                          color: _statusTextColor(order.status, isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _capitalize(order.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusTextColor(order.status, isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---- body ----
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: firstItem?.productImage != null
                          ? Image.network(
                              firstItem!.productImage!,
                              fit: BoxFit.cover,
                              colorBlendMode: isCancelled
                                  ? BlendMode.saturation
                                  : null,
                              color: isCancelled ? Colors.grey : null,
                              errorBuilder: (context, _, __) => Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.grey.shade400,
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
                          firstItem?.productName ?? 'Order Items',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCancelled
                                ? (isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600)
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (order.itemsCount > 1)
                          Text(
                            '+ ${order.itemsCount - 1} other item${order.itemsCount - 1 > 1 ? "s" : ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        const SizedBox(height: 12),
                        StyledPriceText(
                          amount: order.total,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCancelled
                              ? Colors.grey.shade500
                              : AppColors.primary,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---- actions ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildActionButton(order, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(Order order, bool isDark) {
    final status = order.status.toLowerCase();

    if (status == 'cancelled' || status == 'canceled') {
      return SizedBox(
        width: double.infinity,
        height: 36,
        child: OutlinedButton(
          onPressed: () => _navigateToDetail(order),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            side: BorderSide(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('View Details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      );
    }

    if (status == 'delivered') {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () => _navigateToDetail(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Details',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leave Review coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Leave Review',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () => _navigateToDetail(order),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          status == 'shipped' ? 'Track Order' : 'View Details',
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _navigateToDetail(Order order) {
    Navigator.pushNamed(context, '/order-detail', arguments: {
      'orderId': order.id,
      'orderNumber': order.orderNumber,
      'orderDate': _formatDate(order.createdAt),
      'orderStatus': _capitalize(order.status),
      'totalAmount': order.total,
    });
  }

  // --------------------------------------------------------- empty / error --

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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ skeleton ---

  Widget _buildSkeletonList(bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (context, _) => _buildSkeletonCard(isDark),
        );
      },
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    final base =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlight =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final color = Color.lerp(base, highlight, _shimmerController.value)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2A36) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC))
                  .withValues(alpha: 0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 80, height: 11, color: color),
                    const SizedBox(height: 6),
                    _SkeletonBox(width: 150, height: 14, color: color),
                  ],
                ),
                _SkeletonBox(
                    width: 72,
                    height: 26,
                    color: color,
                    radius: 20),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _SkeletonBox(
                    width: 80, height: 80, color: color, radius: 8),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(
                          width: double.infinity,
                          height: 14,
                          color: color),
                      const SizedBox(height: 8),
                      _SkeletonBox(width: 100, height: 12, color: color),
                      const SizedBox(height: 14),
                      _SkeletonBox(width: 72, height: 16, color: color),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SkeletonBox(
                width: double.infinity,
                height: 36,
                color: color,
                radius: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    bool isDark, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable shimmer placeholder block used by the skeleton loader.
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
