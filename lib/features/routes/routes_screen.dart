import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/route_tooltip_card.dart';
import 'package:notable_moments/features/routes/edit_routes_screen.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'dart:math';
import '../../../main.dart';
import 'package:notable_moments/features/routes/route_map_screen.dart';
import 'package:notable_moments/features/routes/widgets/route_search_modal.dart';
import 'package:notable_moments/features/routes/utils/route_builder.dart';

final selectedRouteProvider = StateProvider<RouteModel?>((ref) => null);

// Используем метод расширения из route_admin_model.dart
Future<RouteModel> toRouteModel(RouteAdminModel admin) {
  // Исправлено: если admin.toRouteModel() возвращает Future<RouteModel>, то функция должна быть async и возвращать Future<RouteModel>
  return admin.toRouteModel();
}

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key, required this.isActive});
  final bool isActive;

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, RouteAware {
  static const double _expandedHeightFactor = 0.5;
  bool isExpanded = false;
  DraggableScrollableController controllerDrag = DraggableScrollableController();

  YandexMapController? mapController;
  List<MapObject> mapObjects = [];
  int? selectedPointIndex;
  bool _mapInitialized = false;

  // Добавлено для отслеживания изменений маршрутов
  final List<RouteAdminModel> _previousRoutes = [];

  @override
  void initState() {
    super.initState();

    // Первый раз строим карту
    _drawRoutesAndPoints();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    mapController = null;
    // Сброс выбранного маршрута при уходе со страницы
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(selectedRouteProvider.notifier).state = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    // Подписка на обновления маршрутов
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _drawRoutesAndPoints();
  }

  void _drawRoutesAndPoints() async {
    if (mapController == null) return;

    final routesState = ref.read(routesProvider);
    final routes = routesState.activeRoutes;

    if (routes.isEmpty) return;

    // Сохраняем текущие маршруты для сравнения
    _previousRoutes.clear();
    _previousRoutes.addAll(routes);

    // Убираем автоматическое преобразование - теперь это делается только по требованию
    Logger.d('_drawRoutesAndPoints: Отрисовываем ${routes.length} маршрутов');

    final List<MapObject> objects = [];
    final List<Point> allPoints = [];

    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];
      final routePoints = <Point>[];

      // Добавляем точки маршрута
      for (final point in route.points) {
        if (point.isDraft) continue; // Пропускаем черновики

        final mapPoint = Point(latitude: point.latitude, longitude: point.longitude);
        routePoints.add(mapPoint);
        allPoints.add(mapPoint);

        objects.add(
          PlacemarkMapObject(
            mapId: MapObjectId('route_${route.id}_point_${point.id}'),
            point: mapPoint,
            opacity: 1.0,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'), scale: 1.0),
            ),
            onTap: (_, __) async {
              // При нажатии на точку показываем карточку маршрута
              final convertedRoutes = ref.read(convertedRoutesProvider);
              RouteModel? routeModel = convertedRoutes[route.id];

              if (routeModel == null) {
                Logger.w('routes_screen: Маршрут ${route.id} не найден в кэше');
                return;
              }

              ref.read(selectedRouteProvider.notifier).state = routeModel;
            },
          ),
        );
      }

      // Добавляем линию маршрута, если есть хотя бы 2 точки
      if (routePoints.length >= 2) {
        final polyline = await RouteBuilder.buildRoutePolyline(routePoints);
        objects.add(
          PolylineMapObject(
            mapId: MapObjectId('route_${route.id}_line'),
            polyline: polyline,
            strokeColor: const Color(0xFF466BFF),
            strokeWidth: 3.0,
            onTap: (_, __) async {
              // При нажатии на линию показываем карточку маршрута
              final convertedRoutes = ref.read(convertedRoutesProvider);
              RouteModel? routeModel = convertedRoutes[route.id];

              if (routeModel == null) {
                Logger.w('routes_screen: Маршрут ${route.id} не найден в кэше');
                return;
              }

              ref.read(selectedRouteProvider.notifier).state = routeModel;
            },
          ),
        );
      }
    }

    setState(() {
      mapObjects = objects;
    });

    // Если есть точки, центрируем карту
    if (allPoints.isNotEmpty) {
      await mapController?.moveCamera(
        CameraUpdate.newBounds(
          BoundingBox(
            northEast: Point(
              latitude: allPoints.map((p) => p.latitude).reduce(max) + 0.01,
              longitude: allPoints.map((p) => p.longitude).reduce(max) + 0.01,
            ),
            southWest: Point(
              latitude: allPoints.map((p) => p.latitude).reduce(min) - 0.01,
              longitude: allPoints.map((p) => p.longitude).reduce(min) - 0.01,
            ),
          ),
        ),
      );
    }
  }

  bool hasRoutesChanged(List<RouteAdminModel> currentRoutes) {
    if (currentRoutes.length != _previousRoutes.length) {
      return true;
    }
    for (int i = 0; i < currentRoutes.length; i++) {
      final currentRoute = currentRoutes[i];
      final previousRoute = _previousRoutes[i];

      // Проверяем основные изменения
      if (currentRoute.id != previousRoute.id ||
          currentRoute.title != previousRoute.title ||
          currentRoute.description != previousRoute.description ||
          currentRoute.points.length != previousRoute.points.length) {
        return true;
      }

      // Проверяем изменения в calculatedRoute
      final currentCalculated = currentRoute.calculatedRoute;
      final previousCalculated = previousRoute.calculatedRoute;

      if (currentCalculated != null && previousCalculated == null) {
        return true; // Добавился calculatedRoute
      }
      if (currentCalculated == null && previousCalculated != null) {
        return true; // Удалился calculatedRoute
      }
      if (currentCalculated != null && previousCalculated != null) {
        if (currentCalculated.points.length != previousCalculated.points.length) {
          return true; // Изменилось количество точек в calculatedRoute
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profileState = ref.watch(profileProvider);
    final routesState = ref.watch(routesProvider);
    final selectedRoute = ref.watch(selectedRouteProvider);

    // Если карта инициализирована, маршруты загружены, mapObjects пустой и есть маршруты — строим точки
    if (_mapInitialized && !routesState.isLoading && mapObjects.isEmpty && routesState.allRoutes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _drawRoutesAndPoints();
      });
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * _expandedHeightFactor;

    return AppScaffold(
      useSafeAreaTop: false,
      useSafeAreaBottom: false,
      body: Stack(
        children: [
          AppMap(
            onMapCreated: (controller) async {
              if (_mapInitialized) return;
              mapController = controller;
              _mapInitialized = true;
              await Future.delayed(const Duration(milliseconds: 500));
              final routesState = ref.read(routesProvider);
              if (!routesState.isLoading && routesState.allRoutes.isNotEmpty) {
                _drawRoutesAndPoints();
              }
            },
            mapObjects: mapObjects,
            disableTaps: false, // Теперь карта интерактивна
            showControls: false, // Отключаем встроенные кнопки управления
          ),
          if (routesState.isLoading) const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              height: maxHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 60, right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton.icon(icon: AppIcon.plus, onTap: () => mapController?.moveCamera(CameraUpdate.zoomIn())),
                    const SizedBox(height: 8),
                    AppButton.icon(icon: AppIcon.minus, onTap: () => mapController?.moveCamera(CameraUpdate.zoomOut())),
                    const SizedBox(height: 8),
                    AppButton.icon(
                      icon: AppIcon.location,
                      onTap: () => mapController?.moveCamera(
                        CameraUpdate.newCameraPosition(
                          const CameraPosition(target: Point(latitude: 56.0267294, longitude: 92.865734), zoom: 12),
                        ),
                      ),
                    ),
                    if (profileState.isAdmin) ...[
                      const SizedBox(height: 8),
                      AppButton.icon(
                        icon: AppIcon.edit,
                        onTap: () async {
                          await context.push(EditRoutesScreen());

                          // После редактирования маршрутов, преобразуем первый маршрут для скачивания фотографий
                          final routesState = ref.read(routesProvider);
                          if (routesState.allRoutes.isNotEmpty) {
                            Logger.i('routes_screen: Преобразуем маршруты после редактирования');
                            try {
                              final convertedRoutes = ref.read(convertedRoutesProvider);

                              // Преобразуем все маршруты и сохраняем их
                              for (final route in routesState.allRoutes) {
                                Logger.i('routes_screen: Преобразуем маршрут ${route.id} (${route.title})');
                                final routeModel = await toRouteModel(route);

                                // Сохраняем преобразованный маршрут
                                final updatedRoutes = Map<String, RouteModel>.from(convertedRoutes);
                                updatedRoutes[route.id] = routeModel;
                                ref.read(convertedRoutesProvider.notifier).state = updatedRoutes;
                              }

                              Logger.i('routes_screen: Все маршруты преобразованы и сохранены после редактирования');
                            } catch (e) {
                              Logger.e('routes_screen: Ошибка при преобразовании маршрутов после редактирования: $e');
                            }
                          }

                          _drawRoutesAndPoints();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (selectedRoute != null)
            Positioned.fill(
              child: Stack(
                children: [
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: Dismissible(
                      key: ValueKey(selectedRoute.id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (_) {
                        ref.read(selectedRouteProvider.notifier).state = null;
                      },
                      child: RouteTooltipCard(route: selectedRoute),
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              controller: controllerDrag,
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 0.9,
              snap: true,
              snapSizes: const [0.12, 0.9],
              expand: false,
              builder: (context, scrollController) {
                return RouteSearchModal(
                  onRouteTap: (routeModel) {
                    context.pop();
                    context.push(RouteMapScreen(route: routeModel));
                  },
                  scrollController: scrollController,
                  controllerDrag: controllerDrag,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
