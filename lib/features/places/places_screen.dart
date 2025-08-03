import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_image.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/places/functions/show_place_bottom_sheet.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesState = ref.watch(routesProvider);
    final convertedRoutes = ref.watch(convertedRoutesProvider);

    // Получаем места синхронно
    final activePlaces = _getActivePlaces(routesState, convertedRoutes);

    return SafeArea(
      child: AppScaffold(
        appBar: AppAppBar(title: 'Открытые места', hideLeading: true),
        body: routesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : activePlaces.isEmpty
                ? const Center(
                    child: Text('Ещё нет фото для мест', style: TextStyle(fontSize: 18)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 8,
                      childAspectRatio: 158 / 213,
                    ),
                    itemCount: activePlaces.length,
                    itemBuilder: (context, index) {
                      final (route, point) = activePlaces[index];
                      return AppGestureDetector(
                        onTap: () {
                          showPlaceBottomSheet(
                            context: context,
                            point: point,
                            routeTitle: route.title,
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration:
                                  BoxDecoration(color: AppColor.bgText200, borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: AppImage(
                                        point.photos.first,
                                        backgroundColor: AppColor.bgText00,
                                        key: ValueKey('${route.id}_${point.name}_${point.photos.first}'),
                                      ),
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
                            if (point.photos.length > 1)
                              Positioned(
                                top: 14,
                                right: 14,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${point.photos.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  // Синхронный метод для получения активных мест
  // ignore: strict_top_level_inference
  List<(RouteModel, RoutePoint)> _getActivePlaces(routesState, convertedRoutes) {
    final activePlaces = <(RouteModel, RoutePoint)>[];

    // Пробегаемся по всем роутерам
    for (final route in routesState.activeRoutes) {
      // Сначала проверяем кэш
      final convertedRoute = convertedRoutes[route.id];
      if (convertedRoute != null) {
        // Добавляем точки с фото из кэша
        for (final point in convertedRoute.points) {
          if (point.photos.isNotEmpty) {
            activePlaces.add((convertedRoute, point));
          }
        }
      } else {
        // Если нет в кэше, используем быстрое преобразование
        try {
          final routeModel = route.toRouteModelFast();
          for (final point in routeModel.points) {
            if (point.photos.isNotEmpty) {
              activePlaces.add((routeModel, point));
            }
          }
        } catch (e) {
          // Игнорируем ошибки
        }
      }
    }

    return activePlaces;
  }
}
