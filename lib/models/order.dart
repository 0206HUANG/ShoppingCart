import 'package:shoppingcart/models/address.dart';
import 'package:shoppingcart/models/cart_item.dart';
import 'package:shoppingcart/models/invoice.dart';
import 'package:shoppingcart/models/payment_method.dart';
import 'package:shoppingcart/models/shipping_method.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final Address shippingAddress;
  final ShippingMethod shippingMethod;
  final PaymentMethod paymentMethod;
  final Invoice? invoice;
  final OrderStatus status;
  final int usedLoyaltyPoints;
  final double loyaltyPointsDiscount;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    this.invoice,
    this.status = OrderStatus.pending,
    this.usedLoyaltyPoints = 0,
    this.loyaltyPointsDiscount = 0,
  });
}
