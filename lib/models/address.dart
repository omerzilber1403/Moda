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
  });

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
    );
  }
}
