import 'package:flutter/foundation.dart';
import 'package:shoppingcart/models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [
    Product(
      id: 1,
      name: 'Fashion T-shirt',
      description:
          'Soft and comfortable cotton T-shirt, perfect for daily wear.',
      price: 99.0,
      originalPrice: 129.0,
      imageUrl:
          'https://img.freepik.com/free-photo/white-t-shirts-with-copy-space_53876-102012.jpg',
      specifications: {
        'Size': ['S', 'M', 'L', 'XL'],
        'Color': ['White', 'Black', 'Blue', 'Red'],
      },
      inventory: {
        'S-White': 10,
        'S-Black': 8,
        'S-Blue': 5,
        'S-Red': 7,
        'M-White': 12,
        'M-Black': 10,
        'M-Blue': 6,
        'M-Red': 8,
        'L-White': 15,
        'L-Black': 12,
        'L-Blue': 4,
        'L-Red': 9,
        'XL-White': 8,
        'XL-Black': 7,
        'XL-Blue': 3,
        'XL-Red': 5,
      },
      weight: 0.2,
      volume: 0.001,
    ),
    Product(
      id: 2,
      name: 'Casual Jeans',
      description:
          'Classic style jeans with a tailored fit, comfortable and durable.',
      price: 199.0,
      originalPrice: 249.0,
      imageUrl: 'https://img.freepik.com/free-photo/jeans_1203-8093.jpg',
      specifications: {
        'Size': ['28', '29', '30', '31', '32', '33', '34'],
        'Style': ['Straight', 'Slim', 'Relaxed'],
      },
      inventory: {
        '28-Straight': 5,
        '28-Slim': 8,
        '28-Relaxed': 6,
        '29-Straight': 7,
        '29-Slim': 10,
        '29-Relaxed': 5,
        '30-Straight': 12,
        '30-Slim': 15,
        '30-Relaxed': 8,
        '31-Straight': 10,
        '31-Slim': 12,
        '31-Relaxed': 7,
        '32-Straight': 9,
        '32-Slim': 11,
        '32-Relaxed': 6,
        '33-Straight': 7,
        '33-Slim': 9,
        '33-Relaxed': 5,
        '34-Straight': 6,
        '34-Slim': 8,
        '34-Relaxed': 4,
      },
      weight: 0.5,
      volume: 0.003,
    ),
    Product(
      id: 3,
      name: 'Running Shoes',
      description:
          'Lightweight and breathable running shoes, perfect for daily jogging and fitness.',
      price: 299.0,
      originalPrice: 399.0,
      imageUrl:
          'https://img.freepik.com/free-photo/sport-running-shoes_1203-3414.jpg',
      specifications: {
        'Size': ['39', '40', '41', '42', '43', '44'],
        'Color': ['Black', 'White', 'Gray', 'Blue'],
      },
      inventory: {
        '39-Black': 6,
        '39-White': 7,
        '39-Gray': 5,
        '39-Blue': 4,
        '40-Black': 8,
        '40-White': 10,
        '40-Gray': 7,
        '40-Blue': 6,
        '41-Black': 12,
        '41-White': 14,
        '41-Gray': 10,
        '41-Blue': 9,
        '42-Black': 15,
        '42-White': 13,
        '42-Gray': 11,
        '42-Blue': 10,
        '43-Black': 10,
        '43-White': 9,
        '43-Gray': 8,
        '43-Blue': 7,
        '44-Black': 8,
        '44-White': 6,
        '44-Gray': 5,
        '44-Blue': 4,
      },
      weight: 0.7,
      volume: 0.004,
    ),
    Product(
      id: 4,
      name: 'Smart Watch',
      description:
          'Multifunctional smart watch with heart rate monitoring, activity tracking, and more.',
      price: 599.0,
      originalPrice: 699.0,
      imageUrl:
          'https://img.freepik.com/free-vector/realistic-fitness-trackers_23-2148530529.jpg',
      specifications: {
        'Color': ['Black', 'Silver', 'Gold', 'Rose Gold'],
      },
      inventory: {'Black': 12, 'Silver': 10, 'Gold': 8, 'Rose Gold': 6},
      weight: 0.1,
      volume: 0.0005,
    ),
    Product(
      id: 5,
      name: 'Stylish Backpack',
      description:
          'Lightweight and durable backpack, perfect for daily commuting and short trips.',
      price: 259.0,
      originalPrice: 299.0,
      imageUrl: 'https://img.freepik.com/free-photo/backpack_1203-8307.jpg',
      specifications: {
        'Color': ['Black', 'Gray', 'Blue', 'Red'],
      },
      inventory: {'Black': 15, 'Gray': 12, 'Blue': 10, 'Red': 8},
      weight: 0.8,
      volume: 0.015,
    ),
  ];

  List<Product> get products {
    return [..._products];
  }

  Product findById(int id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> searchByName(String query) {
    if (query.isEmpty) {
      return products;
    }
    return _products
        .where(
          (product) => product.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
