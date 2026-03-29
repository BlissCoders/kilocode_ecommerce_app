import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show File;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_state.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductsLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ProductBloc>().add(ProductSearchRequested(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlissCoders'),
        leading: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final hasUser = state.user != null;
            final avatarUrl = state.user?.avatarUrl;
            
            return IconButton(
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green,
                child: hasUser
                    ? _buildAvatarContent(context, avatarUrl, state)
                    : const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              onPressed: () => context.push('/profile'),
            );
          },
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (state.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${state.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              } else if (value == 'orders') {
                context.push('/orders');
              } else if (value == 'profile') {
                context.push('/profile');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'orders',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long),
                    SizedBox(width: 8),
                    Text('My Orders'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onSearch,
                ),
              ),
              // Categories Dropdown
              if (state.categories.isNotEmpty && state.searchQuery.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: state.selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text('All Categories'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...state.categories.map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      )),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        context.read<ProductBloc>().add(ProductsLoadRequested());
                      } else {
                        context.read<ProductBloc>().add(ProductsByCategoryLoadRequested(value));
                      }
                    },
                  ),
                ),
              const SizedBox(height: 8),
              // Products Grid
              Expanded(
                child: state.status == ProductStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.products.isEmpty
                        ? const Center(child: Text('No products found'))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive grid
                              int crossAxisCount = 2;
                              if (constraints.maxWidth > 900) {
                                crossAxisCount = 4;
                              } else if (constraints.maxWidth > 600) {
                                crossAxisCount = 3;
                              }
                              return GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: state.products.length,
                                itemBuilder: (context, index) {
                                  final product = state.products[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () => context.push('/product/${product.id}'),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildDefaultAvatar(BuildContext context, AuthState state) {
  final initial = state.user?.name.isNotEmpty == true ? state.user!.name[0].toUpperCase() : '?';
  return Text(
    initial,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
}

// Helper to build avatar content - needs context for error builder
Widget _buildAvatarContent(BuildContext context, String? avatarUrl, AuthState state) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return _buildDefaultAvatar(context, state);
  }
  
  if (avatarUrl.startsWith('/')) {
    return Image.file(
      File(avatarUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _buildDefaultAvatar(context, state),
    );
  }
  
  return Image.network(
    avatarUrl,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stack) => _buildDefaultAvatar(context, state),
  );
}
