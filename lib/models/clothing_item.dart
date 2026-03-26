enum ClothingType {
  top('top', 'Top', '\u{1F455}'),
  bottom('bottom', 'Bottom', '\u{1F456}'),
  dress('dress', 'Dress', '\u{1F457}'),
  outerwear('outerwear', 'Outerwear', '\u{1F9E5}'),
  shoes('shoes', 'Shoes', '\u{1F45F}'),
  accessory('accessory', 'Accessory', '\u{1F392}');

  final String value;
  final String label;
  final String icon;
  const ClothingType(this.value, this.label, this.icon);
}

class ClothingItem {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? brand;
  final String? size; // XS/S/M/L/XL/XXL for apparel, null for shoes/accessories
  final ClothingType clothingType;
  final int categoryId;
  final String condition;
  final String? color;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final int priceInCoins;
  final Map<String, String> attributes; // type-specific extra fields

  const ClothingItem({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.brand,
    this.size,
    this.clothingType = ClothingType.top,
    required this.categoryId,
    required this.condition,
    this.color,
    required this.images,
    this.isActive = true,
    required this.priceInCoins,
    required this.createdAt,
    this.attributes = const {},
  });

  /// Returns a display-friendly size string based on clothing type.
  String get displaySize {
    if (clothingType == ClothingType.shoes) {
      return attributes['shoe_size'] ?? '?';
    }
    return size ?? 'One Size';
  }

  ClothingItem copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? brand,
    String? size,
    ClothingType? clothingType,
    int? categoryId,
    String? condition,
    String? color,
    List<String>? images,
    bool? isActive,
    int? priceInCoins,
    DateTime? createdAt,
    Map<String, String>? attributes,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      clothingType: clothingType ?? this.clothingType,
      categoryId: categoryId ?? this.categoryId,
      condition: condition ?? this.condition,
      color: color ?? this.color,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      priceInCoins: priceInCoins ?? this.priceInCoins,
      createdAt: createdAt ?? this.createdAt,
      attributes: attributes ?? this.attributes,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String? icon;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });
}

enum ItemCondition {
  newWithTags('new_with_tags', 'New with Tags'),
  likeNew('like_new', 'Like New'),
  good('good', 'Good'),
  fair('fair', 'Fair');

  final String value;
  final String label;
  const ItemCondition(this.value, this.label);
}

const List<String> clothingSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
