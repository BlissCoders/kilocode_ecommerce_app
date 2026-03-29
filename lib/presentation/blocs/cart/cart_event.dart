import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {}

class CartItemAdded extends CartEvent {
  final ProductModel product;
  final int quantity;

  const CartItemAdded({
    required this.product,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [product, quantity];
}

class CartItemUpdated extends CartEvent {
  final String productId;
  final int quantity;

  const CartItemUpdated({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemRemoved extends CartEvent {
  final String productId;

  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CartCleared extends CartEvent {}
