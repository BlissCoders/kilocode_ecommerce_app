import 'package:equatable/equatable.dart';
import '../../../data/models/cart_model.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  error,
}

class CartState extends Equatable {
  final CartStatus status;
  final CartModel cart;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cart = const CartModel(items: []),
    this.errorMessage,
  });

  int get itemCount => cart.itemCount;
  double get subtotal => cart.subtotal;
  double get tax => cart.tax;
  double get total => cart.total;
  bool get isEmpty => cart.items.isEmpty;

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage];
}
