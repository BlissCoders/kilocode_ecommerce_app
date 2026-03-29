import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

class CartModel extends Equatable {
  final List<CartItemModel> items;

  const CartModel({
    required this.items,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.1; // 10% tax

  double get total => subtotal + tax;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  CartModel copyWith({
    List<CartItemModel>? items,
  }) {
    return CartModel(
      items: items ?? this.items,
    );
  }

  CartModel addItem(ProductModel product, {int quantity = 1}) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      final updatedItems = List<CartItemModel>.from(items);
      updatedItems[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + quantity,
      );
      return copyWith(items: updatedItems);
    } else {
      return copyWith(
        items: [...items, CartItemModel(product: product, quantity: quantity)],
      );
    }
  }

  CartModel updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }
    
    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    
    return copyWith(items: updatedItems);
  }

  CartModel removeItem(String productId) {
    return copyWith(
      items: items.where((item) => item.product.id != productId).toList(),
    );
  }

  CartModel clear() {
    return const CartModel(items: []);
  }

  @override
  List<Object?> get props => [items];
}
