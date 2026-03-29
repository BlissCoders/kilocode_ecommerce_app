import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductsLoadRequested extends ProductEvent {}

class FeaturedProductsLoadRequested extends ProductEvent {}

class ProductsByCategoryLoadRequested extends ProductEvent {
  final String category;

  const ProductsByCategoryLoadRequested(this.category);

  @override
  List<Object?> get props => [category];
}

class ProductSearchRequested extends ProductEvent {
  final String query;

  const ProductSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class CategoriesLoadRequested extends ProductEvent {}

class CategorySelectionCleared extends ProductEvent {}
