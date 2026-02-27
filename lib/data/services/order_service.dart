import 'package:vortex_app/core/config/api_config.dart';
import 'package:vortex_app/core/network/api_client.dart';

/// Represents a single order item (one product line inside an order).
class OrderItem {
  final int id;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double subtotal;

  const OrderItem({
    required this.id,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final images = product['images'] as List<dynamic>?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      imageUrl = images.first['url'] as String?;
    } else {
      imageUrl = product['image'] as String?;
    }

    return OrderItem(
      id: json['id'] as int? ?? 0,
      productName: product['name'] as String? ?? 'Product',
      productImage: imageUrl,
      quantity: json['quantity'] as int? ?? 1,
      price: _toDouble(json['price']),
      subtotal: _toDouble(json['subtotal']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

/// Represents a customer order.
class Order {
  final int id;
  final String orderNumber;
  final String status;
  final double total;
  final String currency;
  final String createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.currency,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    // API returns totals as a nested object: { grand_total, currency, currency_symbol, ... }
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    return Order(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ??
          json['order_no'] as String? ??
          '#${json['id']}',
      status: json['status'] as String? ?? 'pending',
      total: _toDouble(
          totals['grand_total'] ?? json['total'] ?? json['grand_total']),
      currency: totals['currency'] as String? ??
          json['currency'] as String? ??
          'USD',
      // API uses ordered_at; fall back to created_at for other shapes
      createdAt:
          json['ordered_at'] as String? ?? json['created_at'] as String? ?? '',
      items: rawItems
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

/// Paginated result returned by [OrderService.getOrders].
class OrdersResult {
  final List<Order> orders;
  final bool hasMore;

  const OrdersResult({required this.orders, required this.hasMore});
}

/// Service for fetching the authenticated user's orders.
class OrderService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch paginated orders for the currently logged-in user.
  ///
  /// [status] — optional filter: 'pending', 'processing', 'shipped',
  ///            'delivered', 'cancelled' (null = all orders)
  /// [page]   — page number for pagination (1-based)
  Future<OrdersResult> getOrders({String? status, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _apiClient.get(
        ApiConfig.customerOrders,
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );

      if (response['success'] == true) {
        final data = response['data'];
        List<dynamic> rawOrders;

        // Handle both { data: { orders: [...] } } and { data: [...] } shapes.
        if (data is List) {
          rawOrders = data;
        } else if (data is Map) {
          rawOrders = data['orders'] as List<dynamic>? ??
              data['data'] as List<dynamic>? ??
              [];
        } else {
          rawOrders = [];
        }

        final orders = rawOrders
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();

        // Use meta.current_page / meta.last_page when available.
        final meta = response['meta'] as Map<String, dynamic>?;
        bool hasMore;
        if (meta != null) {
          final currentPage = meta['current_page'] as int? ?? page;
          final lastPage = meta['last_page'] as int? ?? 1;
          hasMore = currentPage < lastPage;
        } else {
          // Fallback: if a full page came back assume there might be more.
          hasMore = orders.isNotEmpty;
        }

        return OrdersResult(orders: orders, hasMore: hasMore);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch full detail of a single order by [orderId].
  Future<Order> getOrderDetail(int orderId) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.customerOrderDetail(orderId),
      );

      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return Order.fromJson(data);
        }
        throw Exception('Unexpected response structure');
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch order details');
      }
    } catch (e) {
      rethrow;
    }
  }
}
