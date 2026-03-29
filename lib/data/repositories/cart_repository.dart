import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../../core/constants/app_constants.dart';

class CartRepository {
  final SharedPreferences _prefs;

  CartRepository(this._prefs);

  CartModel getCart() {
    final cartJson = _prefs.getString(AppConstants.cartKey);
    if (cartJson != null) {
      return CartModel.fromJson(jsonDecode(cartJson));
    }
    return const CartModel(items: []);
  }

  Future<void> saveCart(CartModel cart) async {
    await _prefs.setString(AppConstants.cartKey, jsonEncode(cart.toJson()));
  }

  Future<CartModel> addToCart(ProductModel product, {int quantity = 1}) async {
    final cart = getCart();
    final updatedCart = cart.addItem(product, quantity: quantity);
    await saveCart(updatedCart);
    return updatedCart;
  }

  Future<CartModel> updateQuantity(String productId, int quantity) async {
    final cart = getCart();
    final updatedCart = cart.updateQuantity(productId, quantity);
    await saveCart(updatedCart);
    return updatedCart;
  }

  Future<CartModel> removeFromCart(String productId) async {
    final cart = getCart();
    final updatedCart = cart.removeItem(productId);
    await saveCart(updatedCart);
    return updatedCart;
  }

  Future<CartModel> clearCart() async {
    const emptyCart = CartModel(items: []);
    await saveCart(emptyCart);
    return emptyCart;
  }
}
