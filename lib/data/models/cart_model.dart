import 'product_model.dart';

/// Cart Model
class CartModel {
  final int id;
  final List<CartItemModel> items;
  final CartSummary summary;
  final CartCoupon coupon;
  final String createdAt;
  final String updatedAt;

  CartModel({
    required this.id,
    required this.items,
    required this.summary,
    required this.coupon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: CartSummary.fromJson(json['summary'] as Map<String, dynamic>),
      coupon: CartCoupon.fromJson(json['coupon'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

/// Cart Item Model
class CartItemModel {
  final int id;
  final int productId;
  final int? variantId;
  final ProductModel product;
  final int quantity;
  final double price;
  final double subtotal;
  final String currency;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.currency,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      variantId: json['variant_id'] as int?,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

/// Cart Summary
class CartSummary {
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double total;
  final String currency;

  CartSummary({
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.currency,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      itemsCount: json['items_count'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

/// Cart Coupon
class CartCoupon {
  final String? code;
  final double discountAmount;

  CartCoupon({
    required this.code,
    required this.discountAmount,
  });

  factory CartCoupon.fromJson(Map<String, dynamic> json) {
    return CartCoupon(
      code: json['code'] as String?,
      discountAmount: (json['discount_amount'] as num).toDouble(),
    );
  }
}
