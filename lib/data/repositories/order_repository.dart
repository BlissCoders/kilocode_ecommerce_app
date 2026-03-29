import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/user_model.dart';

class OrderRepository {
  final SharedPreferences _prefs;
  static const _uuid = Uuid();
  static const String _ordersKey = 'orders';

  OrderRepository(this._prefs);

  List<OrderModel> getOrders() {
    final ordersJson = _prefs.getString(_ordersKey);
    if (ordersJson != null) {
      final List<dynamic> ordersList = jsonDecode(ordersJson);
      return ordersList.map((json) => OrderModel.fromJson(json)).toList();
    }
    return [];
  }

  List<OrderModel> getUserOrders(String userId) {
    return getOrders().where((order) => order.user.id == userId).toList();
  }

  Future<OrderModel> createOrder({
    required UserModel user,
    required CartModel cart,
    required ShippingAddress shippingAddress,
    String? paymentIntentId,
  }) async {
    final order = OrderModel(
      id: _uuid.v4(),
      user: user,
      items: cart.items,
      subtotal: cart.subtotal,
      tax: cart.tax,
      total: cart.total,
      shippingAddress: shippingAddress,
      status: OrderStatus.pending,
      paymentIntentId: paymentIntentId,
      createdAt: DateTime.now(),
    );

    // Save order
    final orders = getOrders();
    orders.insert(0, order); // Add to beginning (most recent first)
    await _prefs.setString(_ordersKey, jsonEncode(orders.map((o) => o.toJson()).toList()));

    return order;
  }

  Future<OrderModel?> updateOrderStatus(String orderId, OrderStatus status) async {
    final orders = getOrders();
    final index = orders.indexWhere((o) => o.id == orderId);
    
    if (index >= 0) {
      orders[index] = orders[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _prefs.setString(_ordersKey, jsonEncode(orders.map((o) => o.toJson()).toList()));
      return orders[index];
    }
    
    return null;
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return getOrders().firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }
}
