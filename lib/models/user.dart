class User {
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

  const User({
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
  });

  User copyWith({
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
  }) {
    return User(
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
    );
  }
}
