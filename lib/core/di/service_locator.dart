import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/cart/cart_bloc.dart';
import '../../presentation/blocs/product/product_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepository(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepository(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>()),
  );
  getIt.registerFactory<CartBloc>(
    () => CartBloc(getIt<CartRepository>()),
  );
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(getIt<ProductRepository>()),
  );
}
