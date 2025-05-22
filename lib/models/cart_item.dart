class CartItem {
  final int id;
  final String name;
  final double price;
  final double originalPrice; // For discount calculation
  final String imageUrl;
  int quantity;
  Map<String, String>
  selectedSpecifications; // Selected specifications (size, color, etc.)
  bool isSavedForLater; // For "Save for later" feature
  bool isWishlisted; // For "Move to wishlist" feature

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice = 0,
    required this.imageUrl,
    this.quantity = 1,
    this.selectedSpecifications = const {},
    this.isSavedForLater = false,
    this.isWishlisted = false,
  });

  double get total => price * quantity;

  bool get hasDiscount => originalPrice > 0 && originalPrice > price;

  double get discountAmount =>
      hasDiscount ? (originalPrice - price) * quantity : 0;

  String get specificationString {
    if (selectedSpecifications.isEmpty) return '';
    List<String> specs = [];
    selectedSpecifications.forEach((key, value) {
      specs.add('$key: $value');
    });
    return specs.join(', ');
  }

  CartItem copyWith({
    int? id,
    String? name,
    double? price,
    double? originalPrice,
    String? imageUrl,
    int? quantity,
    Map<String, String>? selectedSpecifications,
    bool? isSavedForLater,
    bool? isWishlisted,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      selectedSpecifications:
          selectedSpecifications ?? this.selectedSpecifications,
      isSavedForLater: isSavedForLater ?? this.isSavedForLater,
      isWishlisted: isWishlisted ?? this.isWishlisted,
    );
  }
}
