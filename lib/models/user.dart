class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? city;
  final List<String>? preferredSizes;
  final List<String>? preferredCategories;
  final int styleCoinBalance;
  final DateTime createdAt;
  final String? phone;
  final String? gender;
  final String? adId;
  final String? deviceType;
  final String? operatingSystem;
  final String? preferredGender;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.city,
    this.preferredSizes,
    this.preferredCategories,
    this.styleCoinBalance = 50,
    required this.createdAt,
    this.phone,
    this.gender,
    this.adId,
    this.deviceType,
    this.operatingSystem,
    this.preferredGender,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      preferredSizes: (json['preferred_sizes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredCategories: (json['preferred_categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      styleCoinBalance: json['style_coin_balance'] as int? ?? 50,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      adId: json['ad_id'] as String?,
      deviceType: json['device_type'] as String?,
      operatingSystem: json['operating_system'] as String?,
      preferredGender: json['preferred_gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (bio != null) 'bio': bio,
        if (city != null) 'city': city,
        if (preferredSizes != null) 'preferred_sizes': preferredSizes,
        if (preferredCategories != null)
          'preferred_categories': preferredCategories,
        'style_coin_balance': styleCoinBalance,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (adId != null) 'ad_id': adId,
        if (deviceType != null) 'device_type': deviceType,
        if (operatingSystem != null) 'operating_system': operatingSystem,
        if (preferredGender != null) 'preferred_gender': preferredGender,
      };

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? city,
    List<String>? preferredSizes,
    List<String>? preferredCategories,
    int? styleCoinBalance,
    DateTime? createdAt,
    String? phone,
    String? gender,
    String? adId,
    String? deviceType,
    String? operatingSystem,
    String? preferredGender,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      preferredSizes: preferredSizes ?? this.preferredSizes,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      styleCoinBalance: styleCoinBalance ?? this.styleCoinBalance,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      adId: adId ?? this.adId,
      deviceType: deviceType ?? this.deviceType,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      preferredGender: preferredGender ?? this.preferredGender,
    );
  }
}
