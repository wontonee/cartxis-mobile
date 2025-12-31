/// Category Meta Model
class CategoryMeta {
  final String? metaTitle;
  final String? metaDescription;

  CategoryMeta({
    this.metaTitle,
    this.metaDescription,
  });

  factory CategoryMeta.fromJson(Map<String, dynamic> json) {
    return CategoryMeta(
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta_title': metaTitle,
      'meta_description': metaDescription,
    };
  }
}

/// Category Model
class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String? icon;
  final int? position;
  final int productsCount;
  final int? parentId;
  final CategoryModel? parent;
  final List<CategoryModel> children;
  final CategoryMeta meta;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.icon,
    this.position,
    required this.productsCount,
    this.parentId,
    this.parent,
    required this.children,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      position: json['position'] as int?,
      productsCount: json['products_count'] as int,
      parentId: json['parent_id'] as int?,
      parent: json['parent'] != null 
          ? CategoryModel.fromJson(json['parent'] as Map<String, dynamic>) 
          : null,
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => CategoryModel.fromJson(child as Map<String, dynamic>))
              .toList() ?? [],
      meta: CategoryMeta.fromJson(json['meta'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'icon': icon,
      'position': position,
      'products_count': productsCount,
      'parent_id': parentId,
      'parent': parent?.toJson(),
      'children': children.map((child) => child.toJson()).toList(),
      'meta': meta.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Categories Response Model
class CategoriesResponse {
  final bool success;
  final String message;
  final List<CategoryModel> data;
  final Map<String, dynamic> meta;

  CategoriesResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((category) => CategoryModel.fromJson(category as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((category) => category.toJson()).toList(),
      'meta': meta,
    };
  }
}
