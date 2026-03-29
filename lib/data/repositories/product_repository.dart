import '../datasources/mock_data_source.dart';
import '../models/product_model.dart';

class ProductRepository {
  final MockProductDataSource _dataSource;

  ProductRepository({MockProductDataSource? dataSource})
      : _dataSource = dataSource ?? MockProductDataSource();

  List<ProductModel> getAllProducts() {
    return _dataSource.getAllProducts();
  }

  List<ProductModel> getFeaturedProducts() {
    return _dataSource.getFeaturedProducts();
  }

  List<ProductModel> getProductsByCategory(String category) {
    return _dataSource.getProductsByCategory(category);
  }

  ProductModel? getProductById(String id) {
    return _dataSource.getProductById(id);
  }

  List<String> getCategories() {
    return _dataSource.getCategories();
  }

  List<ProductModel> searchProducts(String query) {
    return _dataSource.searchProducts(query);
  }
}
