import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_image.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/places/functions/show_place_bottom_sheet.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем маршруты из провайдера
    final routes = ref.watch(routesProvider).activeRoutes;
    // Получаем преобразованные маршруты из кэша
    final convertedRoutes = ref.watch(convertedRoutesProvider);

    // Преобразуем маршруты, которых нет в кэше
    for (final route in routes) {
      if (!convertedRoutes.containsKey(route.id)) {
        Logger.i('PlacesScreen: Маршрут ${route.id} не найден в кэше, преобразуем');
        // Запускаем преобразование асинхронно
        Future(() async {
          try {
            final routeModel = await route.toRouteModel();
            // Сохраняем преобразованный маршрут
            final updatedRoutes = Map<String, RouteModel>.from(convertedRoutes);
            updatedRoutes[route.id] = routeModel;
            ref.read(convertedRoutesProvider.notifier).state = updatedRoutes;
            Logger.i('PlacesScreen: Маршрут ${route.id} преобразован и сохранен в кэш');
          } catch (e) {
            Logger.e('PlacesScreen: Ошибка при преобразовании маршрута ${route.id}: $e');
          }
        });
      } else {
        // Проверяем, есть ли изменения в фотографиях
        final cachedRoute = convertedRoutes[route.id]!;
        bool hasPhotoChanges = false;

        // Сравниваем количество точек и фотографий
        if (route.points.length != cachedRoute.points.length) {
          hasPhotoChanges = true;
        } else {
          for (int i = 0; i < route.points.length; i++) {
            final adminPoint = route.points[i];
            final cachedPoint = cachedRoute.points[i];

            if (adminPoint.photos.length != cachedPoint.photos.length) {
              hasPhotoChanges = true;
              break;
            }
          }
        }

        if (hasPhotoChanges) {
          Logger.i('PlacesScreen: Обнаружены изменения в фотографиях маршрута ${route.id}, пересоздаем');
          // Удаляем из кэша и пересоздаем
          final updatedRoutes = Map<String, RouteModel>.from(convertedRoutes);
          updatedRoutes.remove(route.id);
          ref.read(convertedRoutesProvider.notifier).state = updatedRoutes;

          // Пересоздаем маршрут
          Future(() async {
            try {
              final routeModel = await route.toRouteModel();
              final newUpdatedRoutes = Map<String, RouteModel>.from(updatedRoutes);
              newUpdatedRoutes[route.id] = routeModel;
              ref.read(convertedRoutesProvider.notifier).state = newUpdatedRoutes;
              Logger.i('PlacesScreen: Маршрут ${route.id} пересоздан с новыми фотографиями');
            } catch (e) {
              Logger.e('PlacesScreen: Ошибка при пересоздании маршрута ${route.id}: $e');
            }
          });
        }
      }
    }

    // Собираем активные места из преобразованных маршрутов
    final activePlaces = <(RouteModel, RoutePoint)>[];
    for (final route in routes) {
      final convertedRoute = convertedRoutes[route.id];
      if (convertedRoute != null) {
        for (final point in convertedRoute.points) {
          if (point.photos.isNotEmpty) {
            activePlaces.add((convertedRoute, point));
          }
        }
      }
    }

    return SafeArea(
      child: AppScaffold(
        appBar: AppAppBar(title: 'Открытые места', hideLeading: true),
        body: (() {
          final filteredPlaces = activePlaces
              .where(
                (data) =>
                    data.$2.photos.isNotEmpty &&
                    !data.$2.photos.first.contains('https://firebasestorage.googleapis.com'),
              )
              .toList();
          if (filteredPlaces.isEmpty) {
            return const Center(
              child: Text('Ещё нет фото для мест', style: TextStyle(fontSize: 18)),
            );
          }
          return GridView.count(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 158 / 213,
            children: filteredPlaces.map(
              (data) {
                final (route, point) = data;
                return AppGestureDetector(
                  onTap: () => showPlaceBottomSheet(
                    context: context,
                    point: point,
                    routeTitle: route.title,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColor.bgText200, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AppImage(point.photos.first, backgroundColor: AppColor.bgText00),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            point.name,
                            style: AppStyle.subtext.bgText900,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          );
        })(),
      ),
    );
  }
}
