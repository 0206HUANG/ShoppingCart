import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppingcart/models/product.dart';
import 'package:shoppingcart/providers/cart_provider.dart';
import 'package:shoppingcart/screens/cart_screen.dart';
import 'package:badges/badges.dart' as badges;

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, String> _selectedSpecifications = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Pre-select the first option for each specification if available
    if (widget.product.hasSpecifications()) {
      widget.product.specifications.forEach((key, values) {
        if (values.isNotEmpty) {
          _selectedSpecifications[key] = values.first;
        }
      });
    }
  }

  String _generateVariantKey() {
    if (_selectedSpecifications.isEmpty) return widget.product.id.toString();
    // Ensure consistent order for variant key generation
    var sortedKeys = _selectedSpecifications.keys.toList()..sort();
    return sortedKeys.map((key) => _selectedSpecifications[key]).join('-');
  }

  int _getAvailableStock() {
    if (!widget.product.hasSpecifications()) {
      return widget.product.inventory[widget.product.id.toString()] ?? 0;
    }
    final variantKey = _generateVariantKey();
    return widget.product.inventory[variantKey] ?? 0;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final availableStock = _getAvailableStock();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Consumer<CartProvider>(
            builder:
                (_, cartData, ch) => Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: 0, end: 0),
                    badgeContent: Text(
                      cartData.itemCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.red,
                      padding: EdgeInsets.all(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag:
                    widget
                        .product
                        .id, // Ensure this tag is unique and used in ProductItem
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (ctx, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.product.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (widget.product.hasDiscount())
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '\$${widget.product.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (widget.product.hasSpecifications())
              ...widget.product.specifications.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select ${entry.key}:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children:
                          entry.value.map((option) {
                            final isSelected =
                                _selectedSpecifications[entry.key] == option;
                            return ChoiceChip(
                              label: Text(option),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSpecifications[entry.key] = option;
                                  _quantity =
                                      1; // Reset quantity when spec changes
                                });
                              },
                              selectedColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer
                                        : null,
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),

            Text(
              'Stock: ${availableStock > 0 ? availableStock : "Out of Stock"}',
              style: TextStyle(
                fontSize: 16,
                color: availableStock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          _quantity > 1
                              ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                              : null,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed:
                          _quantity < availableStock
                              ? () {
                                setState(() {
                                  _quantity++;
                                });
                              }
                              : null,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Add to Cart'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed:
              availableStock > 0 && _quantity <= availableStock
                  ? () {
                    cart.addItem(
                      widget.product,
                      quantity: _quantity,
                      specifications: _selectedSpecifications,
                    );
                    _showSnackBar('${widget.product.name} added to cart!');
                  }
                  : () {
                    _showSnackBar(
                      availableStock == 0
                          ? 'This item is out of stock.'
                          : 'Not enough stock available for the selected quantity.',
                      isError: true,
                    );
                  },
        ),
      ),
    );
  }
}
