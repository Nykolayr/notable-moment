import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes_repository.dart';
import 'route_model.dart';

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository();
});

final routesProvider = FutureProvider<List<RouteModel>>((ref) async {
  final repository = ref.read(routesRepositoryProvider);
  return await repository.fetchRoutes();
});
