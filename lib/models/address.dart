class Address {
  final String id;
  final String userId;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String zipCode;
  final String country;
  final bool isDefault;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;
  final String? deliveryId;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.zipCode,
    this.country = 'Israel',
    this.isDefault = false,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.deliveryId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      country: json['country'] as String? ?? 'Israel',
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      deliveryId: json['delivery_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'zip_code': zipCode,
        'country': country,
        'is_default': isDefault,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (deliveryId != null) 'delivery_id': deliveryId,
      };

  Address copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? zipCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    String? deliveryId,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryId: deliveryId ?? this.deliveryId,
    );
  }
}
