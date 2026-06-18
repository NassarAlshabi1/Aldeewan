enum PersonRole {
  customer,
  supplier,
}

class Person {
  final String id;
  final PersonRole role;
  final String name;
  final String? phone;
  final DateTime createdAt;
  final bool isArchived;
  /// Currency code for this person (ISO 4217: 'SDG', 'USD', 'SAR', etc.).
  /// When null, falls back to the global app currency from `currencyProvider`.
  /// Each transaction linked to this person inherits this currency at creation time.
  final String? currencyCode;

  Person({
    required this.id,
    required this.role,
    required this.name,
    this.phone,
    required this.createdAt,
    this.isArchived = false,
    this.currencyCode,
  });

  Person copyWith({
    String? id,
    PersonRole? role,
    String? name,
    String? phone,
    DateTime? createdAt,
    bool? isArchived,
    String? currencyCode,
  }) {
    return Person(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
