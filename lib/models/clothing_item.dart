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

  static ClothingType fromValue(String value) {
    return ClothingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClothingType.top,
    );
  }
}

class ClothingItem {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? brand;
  final String? size;
  final ClothingType clothingType;
  final int categoryId;
  final String condition;
  final String? color;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final int priceInCoins;
  final Map<String, dynamic> attributes;
  final DateTime? uploadDate;
  final String? gender;
  final String? pickupAddress;
  final AppUserRef? owner;

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
    this.uploadDate,
    this.gender,
    this.pickupAddress,
    this.owner,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      clothingType: ClothingType.fromValue(
          json['clothing_type'] as String? ?? 'top'),
      categoryId: json['category_id'] as int? ?? 0,
      condition: json['condition'] as String? ?? 'good',
      color: json['color'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? true,
      priceInCoins: json['price_in_coins'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      attributes: json['attributes'] is Map
          ? Map<String, dynamic>.from(json['attributes'] as Map)
          : {},
      uploadDate: json['upload_date'] != null
          ? DateTime.parse(json['upload_date'] as String)
          : null,
      gender: json['gender'] as String?,
      pickupAddress: json['pickup_address'] as String?,
      owner: json['owner'] is Map<String, dynamic>
          ? AppUserRef.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'owner_id': ownerId,
        'title': title,
        if (description != null) 'description': description,
        if (brand != null) 'brand': brand,
        if (size != null) 'size': size,
        'clothing_type': clothingType.value,
        'category_id': categoryId,
        'condition': condition,
        if (color != null) 'color': color,
        'images': images,
        'is_active': isActive,
        'price_in_coins': priceInCoins,
        'attributes': attributes,
        if (gender != null) 'gender': gender,
        if (pickupAddress != null) 'pickup_address': pickupAddress,
      };

  /// Returns a display-friendly size string based on clothing type.
  String get displaySize {
    if (clothingType == ClothingType.shoes) {
      return (attributes['shoe_size'] as String?) ?? '?';
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
    Map<String, dynamic>? attributes,
    DateTime? uploadDate,
    String? gender,
    String? pickupAddress,
    AppUserRef? owner,
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
      uploadDate: uploadDate ?? this.uploadDate,
      gender: gender ?? this.gender,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      owner: owner ?? this.owner,
    );
  }
}

/// Lightweight user reference embedded in clothing item joins.
class AppUserRef {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? city;

  const AppUserRef({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.city,
  });

  factory AppUserRef.fromJson(Map<String, dynamic> json) {
    return AppUserRef(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String?,
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

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
    );
  }
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
