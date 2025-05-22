enum CouponType {
  percentage, // e.g., 10% off
  fixedAmount, // e.g., $5 off
  shipping, // Free shipping
  buyXGetY, // Buy X get Y free
}

class Coupon {
  final String id;
  final String code;
  final String description;
  final CouponType type;
  final double value; // Amount or percentage
  final double minimumPurchase; // Minimum purchase amount to apply
  final DateTime expiryDate;
  final bool isActive;
  final List<int>
  applicableProductIds; // Empty means applicable to all products

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    this.minimumPurchase = 0,
    required this.expiryDate,
    this.isActive = true,
    this.applicableProductIds = const [],
  });

  bool isValid(DateTime currentDate, double cartTotal) {
    return isActive &&
        currentDate.isBefore(expiryDate) &&
        cartTotal >= minimumPurchase;
  }

  double calculateDiscount(double subtotal, List<int> productIds) {
    if (!isActive) return 0;

    // Check if coupon can be applied to the products
    if (applicableProductIds.isNotEmpty &&
        !productIds.any((id) => applicableProductIds.contains(id))) {
      return 0;
    }

    switch (type) {
      case CouponType.percentage:
        return subtotal * (value / 100);
      case CouponType.fixedAmount:
        return value > subtotal ? subtotal : value;
      case CouponType.shipping:
        // Logic for shipping coupon will be applied separately
        return 0;
      case CouponType.buyXGetY:
        // Complex logic for Buy X Get Y will be implemented in the cart provider
        return 0;
    }
  }
}
