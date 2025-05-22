import 'package:flutter/foundation.dart';
import 'package:shoppingcart/models/cart_item.dart';
import 'package:shoppingcart/models/product.dart';
import 'package:shoppingcart/models/address.dart';
import 'package:shoppingcart/models/coupon.dart';
import 'package:shoppingcart/models/invoice.dart';
import 'package:shoppingcart/models/payment_method.dart';
import 'package:shoppingcart/models/shipping_method.dart';
import 'package:shoppingcart/models/user.dart';
import 'package:shoppingcart/models/order.dart'; // Added import for Order and OrderStatus

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items =
      {}; // Changed to String key for better flexibility (e.g., productID + specs)
  Map<String, CartItem> _savedForLaterItems = {};
  Map<String, CartItem> _wishlistItems = {};

  User _currentUser = User(id: 'guest'); // Default guest user
  Address? _selectedShippingAddress;
  ShippingMethod? _selectedShippingMethod;
  PaymentMethod? _selectedPaymentMethod;
  Invoice? _selectedInvoice;
  Coupon? _appliedCoupon;
  int _usedLoyaltyPoints = 0;

  Map<String, CartItem> get items => {..._items};
  Map<String, CartItem> get savedForLaterItems => {..._savedForLaterItems};
  Map<String, CartItem> get wishlistItems => {..._wishlistItems};

  User get currentUser => _currentUser;
  Address? get selectedShippingAddress => _selectedShippingAddress;
  ShippingMethod? get selectedShippingMethod => _selectedShippingMethod;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  Invoice? get selectedInvoice => _selectedInvoice;
  Coupon? get appliedCoupon => _appliedCoupon;
  int get usedLoyaltyPoints => _usedLoyaltyPoints;

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => _items.length;

  // Helper to generate a unique key for cart items based on product ID and specifications
  String _generateCartItemKey(
    int productId,
    Map<String, String> specifications,
  ) {
    if (specifications.isEmpty) {
      return productId.toString();
    }
    var sortedKeys = specifications.keys.toList()..sort();
    var specString = sortedKeys
        .map((key) => '$key:${specifications[key]}')
        .join('|');
    return '$productId-$specString';
  }

  // Core cart functions
  void addItem(
    Product product, {
    int quantity = 1,
    Map<String, String> specifications = const {},
  }) {
    if (!product.isAvailable) {
      // Optionally, notify the user that the product is unavailable
      print('${product.name} is currently unavailable.');
      return;
    }

    String itemKey = _generateCartItemKey(product.id, specifications);

    // Check inventory for the specific variant if specifications are present
    if (product.hasSpecifications()) {
      String variantKey = specifications.entries
          .map((e) => e.value)
          .join('-'); // Example variant key
      if (!product.checkInventory(variantKey, quantity)) {
        // Optionally, notify user about insufficient stock for this variant
        print(
          'Insufficient stock for ${product.name} with selected specifications.',
        );
        return;
      }
    } else if (!product.checkInventory(product.id.toString(), quantity)) {
      // Check general inventory if no specs
      print('Insufficient stock for ${product.name}.');
      return;
    }

    if (_items.containsKey(itemKey)) {
      _items.update(itemKey, (existingCartItem) {
        int newQuantity = existingCartItem.quantity + quantity;
        // Re-check inventory for increased quantity
        if (product.hasSpecifications()) {
          String variantKey = specifications.entries
              .map((e) => e.value)
              .join('-');
          if (!product.checkInventory(variantKey, newQuantity)) {
            print(
              'Cannot add more. Insufficient stock for ${product.name} with selected specifications.',
            );
            return existingCartItem; // Return original item if stock is insufficient
          }
        } else if (!product.checkInventory(
          product.id.toString(),
          newQuantity,
        )) {
          print('Cannot add more. Insufficient stock for ${product.name}.');
          return existingCartItem;
        }
        return existingCartItem.copyWith(quantity: newQuantity);
      });
    } else {
      _items.putIfAbsent(
        itemKey,
        () => CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          originalPrice: product.originalPrice,
          imageUrl: product.imageUrl,
          quantity: quantity,
          selectedSpecifications: specifications,
        ),
      );
    }
    notifyListeners();
  }

  void updateItemQuantity(String itemKey, int newQuantity) {
    if (!_items.containsKey(itemKey) || newQuantity <= 0) {
      if (newQuantity <= 0) {
        removeItem(itemKey); // Remove if quantity is zero or less
      }
      return;
    }

    CartItem currentItem = _items[itemKey]!;
    Product? product = _findProductById(
      currentItem.id,
    ); // Assume you have a way to get product details

    if (product != null) {
      String variantKey = currentItem.selectedSpecifications.entries
          .map((e) => e.value)
          .join('-');
      if (product.hasSpecifications() &&
          !product.checkInventory(variantKey, newQuantity)) {
        print('Insufficient stock to update quantity for ${currentItem.name}.');
        // Optionally, set to max available stock instead of doing nothing
        // _items.update(itemKey, (item) => item.copyWith(quantity: product.inventory[variantKey]));
        notifyListeners();
        return;
      } else if (!product.hasSpecifications() &&
          !product.checkInventory(product.id.toString(), newQuantity)) {
        print('Insufficient stock to update quantity for ${currentItem.name}.');
        notifyListeners();
        return;
      }
    }

    _items.update(itemKey, (item) => item.copyWith(quantity: newQuantity));
    notifyListeners();
  }

  // Placeholder for finding a product - in a real app, this might come from a ProductProvider
  Product? _findProductById(int productId) {
    // This is a simplified placeholder.
    // You'd typically fetch this from a list of all available products.
    // For now, returning a dummy product for inventory check to proceed.
    // Replace this with actual product fetching logic.
    print("Warning: _findProductById is using placeholder logic.");
    return Product(
      id: productId,
      name: "Dummy Product",
      description: "Dummy Description",
      price: 0.0, // Price not relevant for inventory check here
      imageUrl: "",
      inventory: {
        productId.toString(): 100,
        "S-Red": 10,
        "M-Blue": 5,
      }, // Sample inventory
      specifications: {
        "Color": ["Red", "Blue"],
        "Size": ["S", "M", "L"],
      },
      isAvailable: true,
    );
  }

  void updateItemSpecifications(
    String itemKey,
    Map<String, String> newSpecifications,
  ) {
    if (!_items.containsKey(itemKey)) return;

    CartItem oldItem = _items[itemKey]!;
    String newItemKey = _generateCartItemKey(oldItem.id, newSpecifications);

    // If new specifications result in a different item key (meaning it's a different variant)
    if (itemKey != newItemKey) {
      // Check if the new variant already exists in the cart
      if (_items.containsKey(newItemKey)) {
        // Merge quantities: add old item's quantity to the existing new variant
        int totalQuantity = _items[newItemKey]!.quantity + oldItem.quantity;
        _items.update(
          newItemKey,
          (item) => item.copyWith(quantity: totalQuantity),
        );
        _items.remove(itemKey); // Remove the old item
      } else {
        // New variant doesn't exist, so "move" the item by changing its key and specs
        _items.remove(itemKey);
        _items[newItemKey] = oldItem.copyWith(
          selectedSpecifications: newSpecifications,
        );
      }
    } else {
      // Specifications changed but itemKey remains the same (should not happen if key generation is robust)
      // Or, it's just an update to the same item (e.g. if specs were empty and now they are not, but ID is the same)
      _items.update(
        itemKey,
        (item) => item.copyWith(selectedSpecifications: newSpecifications),
      );
    }
    notifyListeners();
  }

  void removeItem(String itemKey) {
    _items.remove(itemKey);
    notifyListeners();
  }

  void removeSingleItem(String itemKey) {
    if (!_items.containsKey(itemKey)) {
      return;
    }
    if (_items[itemKey]!.quantity > 1) {
      _items.update(
        itemKey,
        (item) => item.copyWith(quantity: item.quantity - 1),
      );
    } else {
      _items.remove(itemKey);
    }
    notifyListeners();
  }

  void moveToSavedForLater(String itemKey) {
    if (_items.containsKey(itemKey)) {
      CartItem item = _items[itemKey]!;
      item.isSavedForLater = true;
      _savedForLaterItems[itemKey] = item;
      _items.remove(itemKey);
      notifyListeners();
    }
  }

  void moveToWishlist(String itemKey) {
    if (_items.containsKey(itemKey)) {
      CartItem item = _items[itemKey]!;
      item.isWishlisted = true; // Assuming CartItem has isWishlisted
      _wishlistItems[itemKey] = item;
      _items.remove(itemKey);
      notifyListeners();
    }
  }

  void moveFromSavedToCart(String itemKey) {
    if (_savedForLaterItems.containsKey(itemKey)) {
      CartItem item = _savedForLaterItems[itemKey]!;
      item.isSavedForLater = false;
      // Potentially merge if item with same ID/specs already in cart
      addItem(
        _findProductById(
          item.id,
        )!, // This needs a robust way to get the Product
        quantity: item.quantity,
        specifications: item.selectedSpecifications,
      );
      _savedForLaterItems.remove(itemKey);
      notifyListeners();
    }
  }

  void moveFromWishlistToCart(String itemKey) {
    if (_wishlistItems.containsKey(itemKey)) {
      CartItem item = _wishlistItems[itemKey]!;
      item.isWishlisted = false;
      addItem(
        _findProductById(
          item.id,
        )!, // This needs a robust way to get the Product
        quantity:
            item.quantity, // Typically wishlist items are added with quantity 1
        specifications: item.selectedSpecifications,
      );
      _wishlistItems.remove(itemKey);
      notifyListeners();
    }
  }

  void clear() {
    _items = {};
    _appliedCoupon = null;
    _usedLoyaltyPoints = 0;
    // _selectedShippingAddress = null; // Keep address? Or clear? Depends on UX.
    // _selectedShippingMethod = null;
    notifyListeners();
  }

  // Price Calculation
  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.total);
  }

  double get discountAmount {
    double couponDiscount = 0;
    if (_appliedCoupon != null) {
      List<int> productIdsInCart =
          _items.values.map((item) => item.id).toList();
      couponDiscount = _appliedCoupon!.calculateDiscount(
        subtotal,
        productIdsInCart,
      );
    }
    // Add other discount types here (e.g., loyalty points)
    double loyaltyDiscount = calculateLoyaltyDiscount();
    return couponDiscount + loyaltyDiscount;
  }

  double calculateLoyaltyDiscount() {
    // Example: 100 points = $1 discount
    // Max usage could be capped, e.g., by subtotal or a percentage
    return _usedLoyaltyPoints * 0.01;
  }

  double get shippingCost {
    if (_selectedShippingMethod == null || _selectedShippingAddress == null)
      return 0.0;
    double totalWeight = _items.values.fold(0.0, (sum, item) {
      Product? p = _findProductById(item.id);
      return sum + (p?.weight ?? 0.0) * item.quantity;
    });
    double totalVolume = _items.values.fold(0.0, (sum, item) {
      Product? p = _findProductById(item.id);
      return sum + (p?.volume ?? 0.0) * item.quantity;
    });
    return _selectedShippingMethod!.calculateShippingCost(
      totalWeight: totalWeight,
      totalVolume: totalVolume,
      destinationRegion:
          _selectedShippingAddress!.state, // Or city, country, postalCode
    );
  }

  double get taxAmount {
    // Example: 10% tax on (subtotal - discount)
    // Tax calculation can be very complex based on region, product type, etc.
    const taxRate = 0.10;
    return (subtotal - discountAmount) * taxRate;
  }

  double get totalAmount {
    double calculatedTotal =
        subtotal - discountAmount + shippingCost + taxAmount;
    return calculatedTotal > 0
        ? calculatedTotal
        : 0.0; // Ensure total is not negative
  }

  // User and Checkout Management
  void setUser(User user) {
    _currentUser = user;
    if (!user.isLoggedIn) {
      // Guest user, clear sensitive info
      _selectedShippingAddress = null;
      _selectedPaymentMethod = null;
      _selectedInvoice = null;
      _usedLoyaltyPoints = 0;
    } else {
      // If user logged in, try to load their default address etc.
      _selectedShippingAddress = user.defaultAddress;
    }
    notifyListeners();
  }

  void selectShippingAddress(Address address) {
    _selectedShippingAddress = address;
    notifyListeners();
  }

  void selectShippingMethod(ShippingMethod method) {
    _selectedShippingMethod = method;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void selectInvoice(Invoice invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }

  void applyCoupon(Coupon coupon) {
    if (coupon.isValid(DateTime.now(), subtotal)) {
      _appliedCoupon = coupon;
    } else {
      // Notify user coupon is invalid or not applicable
      print(
        "Coupon ${coupon.code} is not valid or does not meet requirements.",
      );
      _appliedCoupon = null;
    }
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void applyLoyaltyPoints(int pointsToUse) {
    if (!_currentUser.isLoggedIn || pointsToUse < 0) {
      _usedLoyaltyPoints = 0;
      notifyListeners();
      return;
    }

    if (pointsToUse > _currentUser.loyaltyPoints) {
      // Notify user: not enough points
      print(
        "Not enough loyalty points. Available: ${_currentUser.loyaltyPoints}",
      );
      _usedLoyaltyPoints =
          _currentUser.loyaltyPoints; // Use all available if requested more
    } else {
      _usedLoyaltyPoints = pointsToUse;
    }

    // Ensure loyalty discount doesn't exceed subtotal (or other rules)
    if (calculateLoyaltyDiscount() > subtotal) {
      // Adjust points to not exceed subtotal (approximate)
      // This logic might need refinement based on how points convert to currency
      _usedLoyaltyPoints = (subtotal / 0.01).floor();
      print("Adjusted loyalty points to not exceed subtotal.");
    }
    notifyListeners();
  }

  // Checkout
  Future<Order?> placeOrder() async {
    if (_items.isEmpty) {
      print("Cart is empty. Cannot place order.");
      return null;
    }
    if (!_currentUser.isLoggedIn && _selectedShippingAddress == null) {
      // Guest checkout needs address
      print("Shipping address is required for guest checkout.");
      return null;
    }
    if (_currentUser.isLoggedIn &&
        _currentUser.defaultAddress == null &&
        _selectedShippingAddress == null) {
      print("Shipping address is required.");
      return null;
    }
    if (_selectedShippingMethod == null) {
      print("Shipping method is required.");
      return null;
    }
    if (_selectedPaymentMethod == null) {
      print("Payment method is required.");
      return null;
    }

    // Create order object
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Example ID
      userId: _currentUser.id,
      items: _items.values.toList(),
      createdAt: DateTime.now(),
      subtotal: subtotal,
      discount: discountAmount,
      shipping: shippingCost,
      tax: taxAmount,
      total: totalAmount,
      shippingAddress: _selectedShippingAddress ?? _currentUser.defaultAddress!,
      shippingMethod: _selectedShippingMethod!,
      paymentMethod: _selectedPaymentMethod!,
      invoice: _selectedInvoice,
      status: OrderStatus.pending, // Initial status
      usedLoyaltyPoints: _usedLoyaltyPoints,
      loyaltyPointsDiscount: calculateLoyaltyDiscount(),
    );

    // Here you would typically:
    // 1. Process payment
    // 2. Save order to a database
    // 3. Update inventory
    // 4. Clear the cart

    print("Order placed: ${order.id}");
    // Simulate successful order placement
    clear(); // Clear cart after successful order

    notifyListeners(); // Notify listeners that cart is cleared and order might be processed
    return order;
  }
}
