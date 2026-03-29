import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(const ProductState()) {
    on<ProductsLoadRequested>(_onProductsLoadRequested);
    on<FeaturedProductsLoadRequested>(_onFeaturedProductsLoadRequested);
    on<ProductsByCategoryLoadRequested>(_onProductsByCategoryLoadRequested);
    on<ProductSearchRequested>(_onProductSearchRequested);
    on<CategoriesLoadRequested>(_onCategoriesLoadRequested);
    on<CategorySelectionCleared>(_onCategorySelectionCleared);
  }

  Future<void> _onProductsLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    
    try {
      final products = _productRepository.getAllProducts();
      final featuredProducts = _productRepository.getFeaturedProducts();
      final categories = _productRepository.getCategories();
      
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        featuredProducts: featuredProducts,
        categories: categories,
        clearSelectedCategory: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFeaturedProductsLoadRequested(
    FeaturedProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final featuredProducts = _productRepository.getFeaturedProducts();
      emit(state.copyWith(featuredProducts: featuredProducts));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onProductsByCategoryLoadRequested(
    ProductsByCategoryLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    // Don't show loading state to avoid flickering - keep existing products visible
    try {
      final products = _productRepository.getProductsByCategory(event.category);
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onProductSearchRequested(
    ProductSearchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: event.query,
    ));
    
    try {
      final products = event.query.isEmpty
          ? _productRepository.getAllProducts()
          : _productRepository.searchProducts(event.query);
      
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCategoriesLoadRequested(
    CategoriesLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = _productRepository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCategorySelectionCleared(
    CategorySelectionCleared event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategory: null,
      searchQuery: '',
    ));
  }
}
