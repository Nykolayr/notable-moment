import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/provider/routes_state.dart';
import 'package:notable_moments/features/routes/service/routes_service.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;

final routesProvider = StateNotifierProvider<RoutesNotifier, RoutesState>((ref) {
  return RoutesNotifier();
});

class RoutesNotifier extends StateNotifier<RoutesState> {
  final _routesService = RoutesService();

  RoutesNotifier() : super(RoutesState.initial()) {
    _routesService.watchRoutes().listen(
      (routes) {
        debugPrint('routesProvider watchRoutes: routes.length: ${routes.length}');
        for (final route in routes) {
          route.debugPrint('routesProvider watchRoutes: route.points.length: ${route.points.length}');
        }
        state = state.copyWith(allRoutes: routes);
      },
      onError: (error) {
        debugPrint('routesProvider watchRoutes error: $error');
        // Не обновляем состояние при ошибке, чтобы сохранить предыдущие данные
      },
    );
  }

  Future<bool> createRoute({
    required String title,
    required String description,
    required String url,
    required String whyThisRoute,
    required List<PointAdminModel> points,
    required bool isDraft,
    required yandex_map.Polyline polyline,
  }) async {
    try {
      final routeResp = await _routesService.createRoute(
        title: title,
        description: description,
        url: url,
        whyThisRoute: whyThisRoute,
        points: points,
        isDraft: isDraft,
        polyline: polyline,
      );
      if (routeResp.isLeft) {
        debugPrint('routesProvider createRoute error: ${routeResp.left}');
        return false;
      }
      state = state.copyWith(allRoutes: [...state.allRoutes, routeResp.right]);
      return true;
    } catch (e) {
      debugPrint('routesProvider createRoute exception: $e');
      return false;
    }
  }

  Future<void> removeRoute(RouteAdminModel route) async {
    try {
      await _routesService.deleteRoute(route.id);
      state = state.copyWith(
        allRoutes: state.allRoutes.where((element) => element.id != route.id).toList(),
      );
    } catch (e) {
      debugPrint('routesProvider removeRoute error: $e');
      // Можно добавить уведомление пользователя об ошибке
    }
  }

  Future<void> updateRoute(RouteAdminModel route) async {
    try {
      print('RoutesProvider: обновляем маршрут ${route.id} с ${route.points.length} точками');
      for (int i = 0; i < route.points.length; i++) {
        print('Точка $i: ${route.points[i].title}, тестов: ${route.points[i].tests.length}');
      }
      await _routesService.updateRoute(route);
      // Обновляем маршрут в локальном состоянии
      final updatedRoutes = state.allRoutes.map((r) => r.id == route.id ? route : r).toList();
      state = state.copyWith(allRoutes: updatedRoutes);
      print('RoutesProvider: маршрут успешно обновлен');
    } catch (e) {
      debugPrint('routesProvider updateRoute error: $e');
      print('RoutesProvider: ошибка обновления маршрута: $e');
      // Можно добавить уведомление пользователя об ошибке
    }
  }

  Future<void> reorderRoutes(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final List<RouteAdminModel> newRoutes = List.from(state.allRoutes);
      final RouteAdminModel route = newRoutes.removeAt(oldIndex);
      newRoutes.insert(newIndex, route);

      // Update order values based on new positions
      final updatedRoutes = List<RouteAdminModel>.generate(
        newRoutes.length,
        (i) => newRoutes[i].copyWith(order: i),
      );

      // Find routes that actually changed order
      final routesToUpdate = updatedRoutes
          .where((route) => route.order != state.allRoutes[state.allRoutes.indexWhere((r) => r.id == route.id)].order)
          .toList();

      // Update UI immediately
      state = state.copyWith(allRoutes: updatedRoutes);

      // Perform batch update in the background only for changed routes
      if (routesToUpdate.isNotEmpty) {
        await _routesService.updateRoutesInBatch(routesToUpdate);
      }
    } catch (e) {
      debugPrint('routesProvider reorderRoutes error: $e');
      // Можно добавить уведомление пользователя об ошибке
    }
  }
}
