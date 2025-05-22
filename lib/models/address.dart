class Address {
  final String id;
  final String name; // Recipient name
  final String phoneNumber;
  final String address1; // Street address, P.O. box, company name
  final String address2; // Apartment, suite, unit, building, floor, etc.
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address1,
    this.address2 = '',
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  String get fullAddress {
    String addr = '$address1';
    if (address2.isNotEmpty) addr += ', $address2';
    return '$addr, $city, $state $postalCode, $country';
  }

  Address copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
