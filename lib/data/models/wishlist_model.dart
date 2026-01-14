import 'product_model.dart';

class WishlistItemModel {
  final int id;
  final ProductModel product;
  final DateTime addedAt;

  WishlistItemModel({
    required this.id,
    required this.product,
    required this.addedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as int? ?? 0,
      product:
          ProductModel.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'added_at': addedAt.toIso8601String(),
    };
  }
}

class WishlistModel {
  final List<WishlistItemModel> items;
  final int count;

  WishlistModel({
    required this.items,
    required this.count,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final itemsList = data['items'] as List<dynamic>? ?? [];

    final List<WishlistItemModel> wishlistItems = [];
    for (var item in itemsList) {
      wishlistItems
          .add(WishlistItemModel.fromJson(item as Map<String, dynamic>));
    }

    return WishlistModel(
      items: wishlistItems,
      count: (data['count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'count': count,
    };
  }
}
