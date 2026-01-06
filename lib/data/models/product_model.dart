/// Product Dimensions Model
class ProductDimensions {
  final double? length;
  final double? width;
  final double? height;

  ProductDimensions({
    this.length,
    this.width,
    this.height,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      length: json['length'] != null ? (json['length'] as num).toDouble() : null,
      width: json['width'] != null ? (json['width'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'width': width,
      'height': height,
    };
  }
}

/// Product Reviews Summary Model
class ReviewsSummary {
  final double averageRating;
  final int totalReviews;

  ReviewsSummary({
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  factory ReviewsSummary.fromJson(Map<String, dynamic> json) {
    return ReviewsSummary(
      averageRating: json['average_rating'] != null ? (json['average_rating'] as num).toDouble() : 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}

/// Product Meta Model
class ProductMeta {
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;

  ProductMeta({
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      metaKeywords: json['meta_keywords'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
    };
  }
}

/// Product Model
class ProductModel {
  final int id;
  final String sku;
  final String name;
  final String slug;
  final String? description;
  final String? shortDescription;
  final double price;
  final double? specialPrice;
  final double finalPrice;
  final double discountPercentage;
  final String currency;
  final String stockStatus;
  final int quantity;
  final bool inStock;
  final bool isFeatured;
  final bool isNew;
  final String? weight;
  final ProductDimensions dimensions;
  final dynamic brand;
  final List<dynamic> categories;
  final List<dynamic> images;
  final ReviewsSummary reviewsSummary;
  final ProductMeta meta;
  final String createdAt;
  final String updatedAt;

  ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.slug,
    this.description,
    this.shortDescription,
    required this.price,
    this.specialPrice,
    required this.finalPrice,
    required this.discountPercentage,
    required this.currency,
    required this.stockStatus,
    required this.quantity,
    required this.inStock,
    required this.isFeatured,
    required this.isNew,
    this.weight,
    required this.dimensions,
    this.brand,
    required this.categories,
    required this.images,
    required this.reviewsSummary,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Product',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      specialPrice: json['special_price'] != null ? (json['special_price'] as num).toDouble() : null,
      finalPrice: json['final_price'] != null ? (json['final_price'] as num).toDouble() : 0.0,
      discountPercentage: json['discount_percentage'] != null ? (json['discount_percentage'] as num).toDouble() : 0.0,
      currency: json['currency'] as String? ?? 'USD',
      stockStatus: json['stock_status'] as String? ?? 'out_of_stock',
      quantity: json['quantity'] as int? ?? 0,
      inStock: json['in_stock'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      weight: json['weight'] as String?,
      dimensions: json['dimensions'] != null 
          ? ProductDimensions.fromJson(json['dimensions'] as Map<String, dynamic>) 
          : ProductDimensions(),
      brand: json['brand'],
      categories: (json['categories'] as List<dynamic>?) ?? [],
      images: (json['images'] as List<dynamic>?) ?? [],
      reviewsSummary: json['reviews_summary'] != null
          ? ReviewsSummary.fromJson(json['reviews_summary'] as Map<String, dynamic>)
          : ReviewsSummary(averageRating: 0.0, totalReviews: 0),
      meta: json['meta'] != null
          ? ProductMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : ProductMeta(),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'slug': slug,
      'description': description,
      'short_description': shortDescription,
      'price': price,
      'special_price': specialPrice,
      'final_price': finalPrice,
      'discount_percentage': discountPercentage,
      'currency': currency,
      'stock_status': stockStatus,
      'quantity': quantity,
      'in_stock': inStock,
      'is_featured': isFeatured,
      'is_new': isNew,
      'weight': weight,
      'dimensions': dimensions.toJson(),
      'brand': brand,
      'categories': categories,
      'images': images,
      'reviews_summary': reviewsSummary.toJson(),
      'meta': meta.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Pagination Meta Model
class PaginationMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;
  final String timestamp;
  final String version;

  PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
    required this.timestamp,
    required this.version,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
      from: json['from'] as int,
      to: json['to'] as int,
      timestamp: json['timestamp'] as String,
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
      'from': from,
      'to': to,
      'timestamp': timestamp,
      'version': version,
    };
  }
}

/// Pagination Links Model
class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }
}

/// Products Response Model
class ProductsResponse {
  final bool success;
  final String message;
  final List<ProductModel> data;
  final PaginationMeta meta;
  final PaginationLinks links;

  ProductsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
    required this.links,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      links: PaginationLinks.fromJson(json['links'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
      'links': links.toJson(),
    };
  }
}
