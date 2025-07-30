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
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем маршруты из провайдера
    final routes = ref.watch(routesProvider).activeRoutes;

    Logger.d('PlacesScreen: Маршрутов: ${routes.length}');

    return SafeArea(
      child: AppScaffold(
        appBar: AppAppBar(title: 'Открытые места', hideLeading: true),
        body: FutureBuilder<List<(RouteModel, RoutePoint)>>(
          future: _loadActivePlaces(routes),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              Logger.e('PlacesScreen: Ошибка загрузки: ${snapshot.error}');
              return const Center(child: Text('Ошибка загрузки'));
            }

            final activePlaces = snapshot.data ?? [];
            Logger.d('PlacesScreen: Всего активных мест: ${activePlaces.length}');

            if (activePlaces.isEmpty) {
              return const Center(
                child: Text('Ещё нет фото для мест', style: TextStyle(fontSize: 18)),
              );
            }

            return GridView.builder(
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
                        decoration: BoxDecoration(color: AppColor.bgText200, borderRadius: BorderRadius.circular(8)),
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
            );
          },
        ),
      ),
    );
  }

  Future<List<(RouteModel, RoutePoint)>> _loadActivePlaces(List<RouteAdminModel> routes) async {
    final activePlaces = <(RouteModel, RoutePoint)>[];

    for (final route in routes) {
      try {
        // Преобразуем RouteAdminModel в RouteModel
        final routeModel = await route.toRouteModel();

        // Собираем точки с фото
        for (final point in routeModel.points) {
          if (point.photos.isNotEmpty) {
            activePlaces.add((routeModel, point));
          }
        }
      } catch (e) {
        Logger.e('PlacesScreen: Ошибка преобразования маршрута ${route.id}: $e');
      }
    }

    return activePlaces;
  }
}
