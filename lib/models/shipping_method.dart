class ShippingMethod {
  final String id;
  final String name;
  final String description;
  final double baseRate;
  final double ratePerKg;
  final double ratePerVolume; // Rate per cubic meter
  final int estimatedDays; // Estimated delivery days
  final bool isExpress;

  ShippingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.baseRate,
    this.ratePerKg = 0,
    this.ratePerVolume = 0,
    required this.estimatedDays,
    this.isExpress = false,
  });

  double calculateShippingCost({
    required double totalWeight,
    required double totalVolume,
    required String destinationRegion,
  }) {
    // A simplified shipping cost calculation
    double cost = baseRate;
    cost += totalWeight * ratePerKg;
    cost += totalVolume * ratePerVolume;

    // Additional logic could adjust rates based on destination
    // This is a simplified version

    return cost;
  }

  String get deliveryEstimate {
    if (estimatedDays == 1) {
      return 'Delivery in 1 day';
    }
    return 'Delivery in $estimatedDays days';
  }
}
