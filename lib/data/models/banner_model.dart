class BannerModel {
  final String identifier;
  final String imageUrl;
  final String badge;
  final String title;
  final String subtitle;
  final String? linkUrl;
  final String? placement;

  const BannerModel({
    required this.identifier,
    required this.imageUrl,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.linkUrl,
    this.placement,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    // Some backends wrap actual content in nested keys like `data`, `content`, or `block`.
    final Map<String, dynamic> root = _firstMap(json, const ['data', 'content', 'block']) ?? json;

    final identifier = _firstString(root, const ['identifier', 'slug', 'key', 'id']) ??
        _firstString(json, const ['identifier', 'slug', 'key', 'id']) ??
        '';

    final title = _firstString(root, const ['title', 'heading', 'name']) ?? '';
    final subtitle = _firstString(root, const ['subtitle', 'subheading', 'description', 'text']) ?? '';
    final badge = _firstString(root, const ['badge', 'label', 'tag']) ?? '';

    final imageUrl = _extractImageUrl(root) ?? _extractImageUrl(json) ?? '';

    final linkUrl = _firstString(root, const ['url', 'link', 'link_url', 'cta_url', 'target_url']) ??
        _firstString(_firstMap(root, const ['action', 'cta']) ?? const {}, const ['url', 'link', 'href']);

    final placement = _firstString(root, const ['placement', 'position', 'slot']);

    return BannerModel(
      identifier: identifier,
      imageUrl: imageUrl,
      badge: badge,
      title: title,
      subtitle: subtitle,
      linkUrl: linkUrl,
      placement: placement,
    );
  }

  static String? _extractImageUrl(Map<String, dynamic> json) {
    final dynamic raw = json['image_url'] ??
        json['imageUrl'] ??
        json['image'] ??
        json['banner_image'] ??
        json['background_image'] ??
        json['backgroundImage'] ??
        json['media'];

    if (raw is String) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      return (raw['url'] ?? raw['path'] ?? raw['src'] ?? raw['image'])?.toString();
    }
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is String) return first;
      if (first is Map<String, dynamic>) {
        return (first['url'] ?? first['path'] ?? first['src'] ?? first['image'])?.toString();
      }
    }

    // Some CMS blocks use nested image structures.
    final media = _firstMap(json, const ['media', 'background', 'hero_image', 'heroImage']);
    if (media != null) {
      final url = (media['url'] ?? media['path'] ?? media['src'] ?? media['image'])?.toString();
      if (url != null && url.isNotEmpty) return url;
    }

    return null;
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return null;
  }

  static Map<String, dynamic>? _firstMap(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
    }
    return null;
  }
}
