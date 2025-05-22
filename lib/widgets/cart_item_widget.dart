import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppingcart/models/cart_item.dart';
import 'package:shoppingcart/providers/cart_provider.dart';
import 'package:shoppingcart/providers/product_provider.dart'; // To get product details if needed

class CartItemWidget extends StatelessWidget {
  final String itemKey; // Unique key for the cart item
  final CartItem cartItem;

  const CartItemWidget({
    super.key,
    required this.itemKey,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    // You might need ProductProvider to fetch product details if not all are in CartItem
    // final productProvider = Provider.of<ProductProvider>(context, listen: false);
    // final product = productProvider.findById(cartItem.id); // Example

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (ctx, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
              ),
            ),
            const SizedBox(width: 15),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    cartItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cartItem.selectedSpecifications.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        cartItem.specificationString,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${cartItem.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity and Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () {
                        cart.removeSingleItem(itemKey);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () {
                        // Consider stock check before adding
                        // For simplicity, directly adding here.
                        // In a real app, you'd get the product from ProductProvider
                        // and check inventory before calling addItem.
                        final product = Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        ).findById(cartItem.id);
                        cart.addItem(
                          product,
                          specifications: cartItem.selectedSpecifications,
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red[700],
                    size: 20,
                  ),
                  label: Text(
                    'Remove',
                    style: TextStyle(color: Colors.red[700], fontSize: 13),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: Text(
                              'Do you want to remove "${cartItem.name}" from the cart?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('No'),
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  Navigator.of(ctx).pop(true);
                                  cart.removeItem(itemKey);
                                },
                              ),
                            ],
                          ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30), // Adjust size as needed
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
