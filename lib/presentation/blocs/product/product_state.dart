import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';

enum ProductStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductModel> products;
  final List<ProductModel> featuredProducts;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.featuredProducts = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<ProductModel>? products,
    List<ProductModel>? featuredProducts,
    List<String>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        featuredProducts,
        categories,
        selectedCategory,
        searchQuery,
        errorMessage,
      ];
}
