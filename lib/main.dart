import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'config/router.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/cart/cart_event.dart';
import 'presentation/blocs/product/product_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await setupDependencies();
  
  runApp(const EcommerceApp());
}

class EcommerceApp extends StatefulWidget {
  const EcommerceApp({super.key});

  @override
  State<EcommerceApp> createState() => _EcommerceAppState();
}

class _EcommerceAppState extends State<EcommerceApp> {
  late final AuthBloc _authBloc;
  late final CartBloc _cartBloc;
  late final ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _cartBloc = getIt<CartBloc>();
    _productBloc = getIt<ProductBloc>();
    
    // Check auth status and load cart on startup
    _authBloc.add(AuthCheckRequested());
    _cartBloc.add(CartLoadRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    _cartBloc.close();
    _productBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<CartBloc>.value(value: _cartBloc),
        BlocProvider<ProductBloc>.value(value: _productBloc),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Create router after auth state is known
          final router = createRouter(_authBloc);
          
          return MaterialApp.router(
            title: 'BlissCoders',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
