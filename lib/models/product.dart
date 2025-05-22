class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double originalPrice; // For discounts
  final String imageUrl;
  final Map<String, List<String>>
  specifications; // For size, color, package options
  final Map<String, int> inventory; // Inventory for each variant
  final double weight; // For shipping calculation
  final double volume; // For shipping calculation
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice = 0,
    required this.imageUrl,
    this.specifications = const {},
    this.inventory = const {},
    this.weight = 0,
    this.volume = 0,
    this.isAvailable = true,
  });

  bool hasDiscount() {
    return originalPrice > 0 && originalPrice > price;
  }

  double getDiscountPercentage() {
    if (!hasDiscount()) return 0;
    return ((originalPrice - price) / originalPrice) * 100;
  }

  bool hasSpecifications() {
    return specifications.isNotEmpty;
  }

  bool checkInventory(String variant, int quantity) {
    if (!inventory.containsKey(variant)) return false;
    return inventory[variant]! >= quantity;
  }
}
