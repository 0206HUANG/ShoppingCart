import 'package:shoppingcart/models/address.dart';

class User {
  final String id;
  final String? email;
  final String? name;
  final List<Address> addresses;
  final int loyaltyPoints;
  bool isLoggedIn;

  User({
    required this.id,
    this.email,
    this.name,
    this.addresses = const [],
    this.loyaltyPoints = 0,
    this.isLoggedIn = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    List<Address>? addresses,
    int? loyaltyPoints,
    bool? isLoggedIn,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      addresses: addresses ?? this.addresses,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  Address? get defaultAddress {
    for (var address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isNotEmpty ? addresses.first : null;
  }

  bool get isGuest => !isLoggedIn;
}
