import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/provider/routes_state.dart';
import 'package:notable_moments/features/routes/service/routes_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final routesProvider = StateNotifierProvider<RoutesNotifier, RoutesState>((ref) {
  return RoutesNotifier(ref);
});

// Провайдер для хранения преобразованных маршрутов
final convertedRoutesProvider = StateProvider<Map<String, RouteModel>>((ref) => {});

// Метод для очистки кэша маршрута
void clearRouteCache(String routeId) {
  try {
    final container = ProviderContainer();
    final convertedRoutes = container.read(convertedRoutesProvider);
    if (convertedRoutes.containsKey(routeId)) {
      final updatedConvertedRoutes = Map<String, RouteModel>.from(convertedRoutes);
      updatedConvertedRoutes.remove(routeId);
      container.read(convertedRoutesProvider.notifier).state = updatedConvertedRoutes;
      Logger.i('clearRouteCache: Кэш для маршрута $routeId очищен');
    }
    container.dispose();
  } catch (e) {
    Logger.e('clearRouteCache: Ошибка при очистке кэша: $e');
  }
}

class RoutesNotifier extends StateNotifier<RoutesState> {
  final _routesService = RoutesService();
  final Ref _ref;

  RoutesNotifier(this._ref) : super(RoutesState.initial()) {
    state = state.copyWith(isLoading: true);

    // Инициализируем сервис
    _routesService.init().then((_) {}).catchError((e) {
      Logger.e('routesProvider: Error initializing RoutesService: $e');
    });

    _routesService.watchRoutes().listen(
      (routes) async {
        Logger.i('routesProvider watchRoutes: получено ${routes.length} маршрутов');

        // Проверяем, есть ли изменения в маршрутах
        final hasChanges = _checkForChanges(state.allRoutes, routes);
        if (hasChanges) {}

        state = state.copyWith(allRoutes: routes, isLoading: false);

        // ПЕРВАЯ ФАЗА: Быстрое преобразование для показа заглушек
        if (routes.isNotEmpty) {
          Logger.i('routesProvider: Первая фаза - быстрое преобразование для заглушек');
          try {
            for (final route in routes) {
              // Быстрое преобразование с путями на Яндекс.Диск
              final routeModel = route.toRouteModelFast();

              // Сохраняем в кэш для немедленного показа
              final currentConvertedRoutes = _ref.read(convertedRoutesProvider);
              final updatedRoutes = Map<String, RouteModel>.from(currentConvertedRoutes);
              updatedRoutes[route.id] = routeModel;
              _ref.read(convertedRoutesProvider.notifier).state = updatedRoutes;
            }
            Logger.i('routesProvider: Первая фаза завершена - заглушки готовы');
          } catch (e) {
            Logger.e('routesProvider: Ошибка в первой фазе: $e');
          }
        }

        // ВТОРАЯ ФАЗА: Загрузка реальных фото в фоне
        if (routes.isNotEmpty) {
          Logger.i('routesProvider: Вторая фаза - загрузка реальных фото в фоне');
          _loadPhotosInBackground(routes);
        }
      },
      onError: (error) {
        Logger.e('routesProvider watchRoutes error: $error');
        state = state.copyWith(isLoading: false);
        // Не обновляем состояние при ошибке, чтобы сохранить предыдущие данные
      },
    );
  }

  // Вспомогательный метод для проверки изменений в маршрутах
  bool _checkForChanges(List<RouteAdminModel> oldRoutes, List<RouteAdminModel> newRoutes) {
    if (oldRoutes.length != newRoutes.length) return true;

    for (int i = 0; i < oldRoutes.length; i++) {
      if (oldRoutes[i].id != newRoutes[i].id) return true;

      // Проверяем изменения в точках
      if (oldRoutes[i].points.length != newRoutes[i].points.length) return true;

      for (int j = 0; j < oldRoutes[i].points.length; j++) {
        final oldPoint = oldRoutes[i].points[j];
        final newPoint = newRoutes[i].points[j];

        // Проверяем изменения в тестах
        if (oldPoint.tests.length != newPoint.tests.length) return true;

        // Проверяем изменения в фотографиях
        if (oldPoint.photos.length != newPoint.photos.length) return true;

        // Проверяем, изменились ли сами фотографии
        for (int k = 0; k < oldPoint.photos.length; k++) {
          if (k >= newPoint.photos.length || oldPoint.photos[k] != newPoint.photos[k]) {
            return true;
          }
        }

        // Проверяем, добавились ли новые фотографии
        for (int k = oldPoint.photos.length; k < newPoint.photos.length;) {
          return true;
        }
      }
    }

    return false;
  }

  Future<bool> createRoute({
    required String title,
    required String description,
    required String url,
    required String whyThisRoute,
    required List<PointAdminModel> points,
    required bool isDraft,
    required Polyline polyline,
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
        Logger.e('routesProvider createRoute error: ${routeResp.left}');
        return false;
      }
      state = state.copyWith(allRoutes: [...state.allRoutes, routeResp.right]);
      return true;
    } catch (e) {
      Logger.e('routesProvider createRoute exception: $e');
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
      Logger.e('routesProvider removeRoute error: $e');
      // Можно добавить уведомление пользователя об ошибке
    }
  }

  Future<void> updateRoute(RouteAdminModel route) async {
    try {
      await _routesService.updateRoute(route);
      // Обновляем маршрут в локальном состоянии
      final updatedRoutes = state.allRoutes.map((r) => r.id == route.id ? route : r).toList();
      state = state.copyWith(allRoutes: updatedRoutes);

      // Очищаем кэш преобразованных маршрутов для этого маршрута
      // чтобы принудительно пересоздать RouteModel с новыми фотографиями
      clearRouteCache(route.id);
    } catch (e) {
      Logger.e('routesProvider updateRoute error: $e');
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
      Logger.e('routesProvider reorderRoutes error: $e');
      // Можно добавить уведомление пользователя об ошибке
    }
  }

  Future<void> clearAllPhotos() async {
    try {
      await _routesService.clearAllPhotos();

      // Обновляем состояние, чтобы отобразить изменения
      final updatedRoutes = state.allRoutes.map((route) {
        final updatedPoints = route.points.map((point) => point.copyWith(photos: [])).toList();
        return route.copyWith(points: updatedPoints);
      }).toList();

      state = state.copyWith(allRoutes: updatedRoutes);
    } catch (e) {
      Logger.e('routesProvider clearAllPhotos error: $e');
      // Можно добавить уведомление пользователя об ошибке
    }
  }

  // Асинхронная загрузка фото в фоне (вторая фаза)
  Future<void> _loadPhotosInBackground(List<RouteAdminModel> routes) async {
    for (final route in routes) {
      try {
        Logger.i('routesProvider: Загружаем фото для маршрута ${route.id}');

        // Загружаем фото с заменой путей на локальные
        final routeModelWithLocalPhotos = await route.toRouteModelWithLocalPhotos();

        // Обновляем провайдер с новым маршрутом
        final currentConvertedRoutes = _ref.read(convertedRoutesProvider);
        final updatedRoutes = Map<String, RouteModel>.from(currentConvertedRoutes);
        updatedRoutes[route.id] = routeModelWithLocalPhotos;

        _ref.read(convertedRoutesProvider.notifier).state = updatedRoutes;

        Logger.i('routesProvider: Фото загружены для маршрута ${route.id}');
      } catch (e) {
        Logger.e('routesProvider: Ошибка при загрузке фото для маршрута ${route.id}: $e');
      }
    }
  }
}
