enum PaymentType { creditCard, wechat, alipay, paypal, cashOnDelivery }

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String name; // Display name for the payment method
  final String? lastFourDigits; // For credit card
  final String? cardType; // For credit card (Visa, Mastercard, etc.)
  final String? expiryDate; // For credit card
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.lastFourDigits,
    this.cardType,
    this.expiryDate,
    this.isDefault = false,
  });

  String get displayName {
    switch (type) {
      case PaymentType.creditCard:
        return '$cardType ending in $lastFourDigits';
      default:
        return name;
    }
  }
}
