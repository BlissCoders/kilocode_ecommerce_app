import '../models/product_model.dart';

class MockProductDataSource {
  // Mock product data - Using picsum.photos for real images
  static final List<ProductModel> products = [
    const ProductModel(
      id: '1',
      name: 'Wireless Headphones',
      description: 'Premium noise-cancelling wireless headphones with 30-hour battery life. Features Bluetooth 5.0, active noise cancellation, and premium sound quality.',
      price: 149.99,
      imageUrl: 'https://picsum.photos/seed/headphones/300/300',
      category: 'Electronics',
      stock: 50,
      rating: 4.5,
      reviewCount: 128,
      isFeatured: true,
    ),
    const ProductModel(
      id: '2',
      name: 'Smart Watch',
      description: 'Fitness tracker with heart rate monitor, GPS, and 7-day battery life. Water-resistant up to 50 meters.',
      price: 199.99,
      imageUrl: 'https://picsum.photos/seed/smartwatch/300/300',
      category: 'Electronics',
      stock: 30,
      rating: 4.3,
      reviewCount: 95,
      isFeatured: true,
    ),
    const ProductModel(
      id: '3',
      name: 'Running Shoes',
      description: 'Lightweight running shoes with responsive cushioning and breathable mesh upper. Perfect for daily runs.',
      price: 89.99,
      imageUrl: 'https://picsum.photos/seed/shoes/300/300',
      category: 'Sports',
      stock: 100,
      rating: 4.7,
      reviewCount: 256,
      isFeatured: false,
    ),
    const ProductModel(
      id: '4',
      name: 'Laptop Backpack',
      description: 'Durable laptop backpack with USB charging port. Fits up to 15.6" laptops with multiple compartments.',
      price: 49.99,
      imageUrl: 'https://picsum.photos/seed/backpack/300/300',
      category: 'Accessories',
      stock: 75,
      rating: 4.4,
      reviewCount: 89,
      isFeatured: false,
    ),
    const ProductModel(
      id: '5',
      name: 'Wireless Mouse',
      description: 'Ergonomic wireless mouse with precision tracking. Long battery life up to 18 months.',
      price: 29.99,
      imageUrl: 'https://picsum.photos/seed/mouse/300/300',
      category: 'Electronics',
      stock: 200,
      rating: 4.2,
      reviewCount: 312,
      isFeatured: false,
    ),
    const ProductModel(
      id: '6',
      name: 'Bluetooth Speaker',
      description: 'Portable Bluetooth speaker with 360-degree sound. Waterproof design with 12-hour playtime.',
      price: 79.99,
      imageUrl: 'https://picsum.photos/seed/speaker/300/300',
      category: 'Electronics',
      stock: 45,
      rating: 4.6,
      reviewCount: 178,
      isFeatured: true,
    ),
    const ProductModel(
      id: '7',
      name: 'Yoga Mat',
      description: 'Non-slip yoga mat with alignment lines. Eco-friendly material, 6mm thickness.',
      price: 34.99,
      imageUrl: 'https://picsum.photos/seed/yogamat/300/300',
      category: 'Sports',
      stock: 150,
      rating: 4.5,
      reviewCount: 203,
      isFeatured: false,
    ),
    const ProductModel(
      id: '8',
      name: 'Phone Case',
      description: 'Premium protective phone case with kickstand. Military-grade drop protection.',
      price: 19.99,
      imageUrl: 'https://picsum.photos/seed/phonecase/300/300',
      category: 'Accessories',
      stock: 300,
      rating: 4.1,
      reviewCount: 456,
      isFeatured: false,
    ),
  ];

  List<ProductModel> getAllProducts() {
    return products;
  }

  List<ProductModel> getFeaturedProducts() {
    return products.where((p) => p.isFeatured).toList();
  }

  List<ProductModel> getProductsByCategory(String category) {
    return products.where((p) => p.category == category).toList();
  }

  ProductModel? getProductById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getCategories() {
    return products.map((p) => p.category).toSet().toList();
  }

  List<ProductModel> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return products.where((p) =>
        p.name.toLowerCase().contains(lowerQuery) ||
        p.description.toLowerCase().contains(lowerQuery) ||
        p.category.toLowerCase().contains(lowerQuery)).toList();
  }
}
