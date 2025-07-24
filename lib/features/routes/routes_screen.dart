import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:notable_moments/features/routes/provider/routes_state.dart';
import '../../../main.dart';
import 'package:notable_moments/features/routes/route_map_screen.dart';
import 'package:notable_moments/features/routes/widgets/route_search_modal.dart';

final selectedRouteProvider = StateProvider<RouteModel?>((ref) => null);

// Используем метод расширения из route_admin_model.dart
RouteModel toRouteModel(RouteAdminModel admin) {
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;
  static const double _collapsedHeightFactor = 0.105;
  static const double _expandedHeightFactor = 0.5;
  bool isExpanded = false;

  YandexMapController? mapController;
  List<MapObject> mapObjects = [];
  int? selectedPointIndex;
  bool _mapInitialized = false;

  // Добавлено для отслеживания изменений маршрутов
  final List<RouteAdminModel> _previousRoutes = [];
  bool _subscribedToRoutes = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _expandPanel();
      }
    });

    _searchController.addListener(() {
      setState(() {
        // Обновляем состояние для фильтрации
      });
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
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
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (widget.isActive) {
      _drawRoutesAndPoints();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxDelta = screenHeight * (_expandedHeightFactor - _collapsedHeightFactor);
    final newValue = _animationController.value - delta / maxDelta;
    _animationController.value = newValue.clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.value > 0.5) {
      _expandPanel();
    } else {
      _collapsePanel();
    }
  }

  void _expandPanel() {
    _animationController.animateTo(1.0, curve: Curves.easeOut);
    setState(() {
      isExpanded = true;
    });
  }

  void _collapsePanel() {
    _animationController.animateTo(0.0, curve: Curves.easeIn);
    setState(() {
      isExpanded = false;
    });
  }

  void _drawRoutesAndPoints() async {
    if (mapController == null) return;

    final routesState = ref.read(routesProvider);
    final routes = routesState.activeRoutes;

    if (routes.isEmpty) return;

    // Сохраняем текущие маршруты для сравнения
    _previousRoutes.clear();
    _previousRoutes.addAll(routes);

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
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
                scale: 1.0,
              ),
            ),
            onTap: (_, __) {
              // При нажатии на точку показываем карточку маршрута
              ref.read(selectedRouteProvider.notifier).state = toRouteModel(route);
            },
          ),
        );
      }

      // Добавляем линию маршрута, если есть хотя бы 2 точки
      if (routePoints.length >= 2) {
        // Используем calculatedRoute, если есть, иначе используем обычный polyline
        final polyline = route.calculatedRoute ?? route.polyline;

        if (polyline.points.isNotEmpty) {
          objects.add(
            PolylineMapObject(
              mapId: MapObjectId('route_${route.id}_line'),
              polyline: polyline,
              strokeColor: const Color(0xFF466BFF),
              strokeWidth: 3.0,
              onTap: (_, __) {
                // При нажатии на линию показываем карточку маршрута
                ref.read(selectedRouteProvider.notifier).state = toRouteModel(route);
              },
            ),
          );
        } else {
          // Если нет polyline, создаем прямые линии между точками
          final simplifiedPolyline = _createSimplifiedPolyline(routePoints);
          objects.add(
            PolylineMapObject(
              mapId: MapObjectId('route_${route.id}_line'),
              polyline: simplifiedPolyline,
              strokeColor: const Color(0xFF466BFF),
              strokeWidth: 3.0,
              onTap: (_, __) {
                ref.read(selectedRouteProvider.notifier).state = toRouteModel(route);
              },
            ),
          );
        }
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

  Polyline _createSimplifiedPolyline(List<Point> waypoints) {
    if (waypoints.length <= 1) return Polyline(points: waypoints);

    final routePoints = <Point>[];
    final random = Random(42); // Фиксированное зерно для воспроизводимости

    for (int i = 0; i < waypoints.length - 1; i++) {
      final start = waypoints[i];
      final end = waypoints[i + 1];

      // Добавляем начальную точку
      routePoints.add(start);

      // Добавляем промежуточные точки для имитации кривой
      final segmentCount = 3; // Количество промежуточных точек
      for (int j = 1; j < segmentCount; j++) {
        final t = j / segmentCount;
        final lat = start.latitude + (end.latitude - start.latitude) * t;
        final lng = start.longitude + (end.longitude - start.longitude) * t;

        // Добавляем небольшое случайное отклонение для имитации кривой дороги
        final latOffset = (random.nextDouble() - 0.5) * 0.002; // примерно 200 метров
        final lngOffset = (random.nextDouble() - 0.5) * 0.002;

        routePoints.add(
          Point(
            latitude: lat + latOffset,
            longitude: lng + lngOffset,
          ),
        );
      }

      // Добавляем конечную точку (кроме последней итерации)
      if (i == waypoints.length - 2) {
        routePoints.add(end);
      }
    }

    return Polyline(points: routePoints);
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

  List<RouteAdminModel> _getFilteredRoutes(List<RouteAdminModel> routes) {
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isEmpty) {
      return routes;
    }

    return routes.where((route) {
      return route.title.toLowerCase().contains(searchQuery) || route.description.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profileState = ref.watch(profileProvider);
    final routesState = ref.watch(routesProvider);
    final selectedRoute = ref.watch(selectedRouteProvider);

    if (!_subscribedToRoutes) {
      _subscribedToRoutes = true;
      ref.listen<RoutesState>(routesProvider, (prev, next) {
        if (prev?.isLoading == true && next.isLoading == false) {
          _drawRoutesAndPoints();
        }
      });
    }

    // Если карта инициализирована, маршруты загружены, mapObjects пустой и есть маршруты — строим точки
    if (_mapInitialized && !routesState.isLoading && mapObjects.isEmpty && routesState.allRoutes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _drawRoutesAndPoints();
      });
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = screenHeight * _collapsedHeightFactor;
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
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.icon(
                    icon: AppIcon.plus,
                    onTap: () => mapController?.moveCamera(CameraUpdate.zoomIn()),
                  ),
                  const SizedBox(height: 8),
                  AppButton.icon(
                    icon: AppIcon.minus,
                    onTap: () => mapController?.moveCamera(CameraUpdate.zoomOut()),
                  ),
                  const SizedBox(height: 8),
                  AppButton.icon(
                    icon: AppIcon.location,
                    onTap: () => mapController?.moveCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          target: Point(latitude: 56.0267294, longitude: 92.865734),
                          zoom: 12,
                        ),
                      ),
                    ),
                  ),
                  if (profileState.isAdmin) ...[
                    const SizedBox(height: 8),
                    AppButton.icon(
                      icon: AppIcon.edit,
                      onTap: () {
                        context.push(EditRoutesScreen());
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final height = minHeight + (maxHeight - minHeight) * _animationController.value;
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: child!,
              );
            },
            child: GestureDetector(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: _buildBottomPanel(context, routesState.activeRoutes),
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
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, List<RouteAdminModel> routes) {
    final filteredRoutes = _getFilteredRoutes(routes);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          // Индикатор для перетаскивания
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Поле поиска
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                hintText: 'Найти маршрут',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          FocusScope.of(context).requestFocus(_focusNode);
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Список маршрутов
          Expanded(
            child: filteredRoutes.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Маршруты не найдены'
                          : 'По запросу "${_searchController.text}" ничего не найдено',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredRoutes.length,
                    itemBuilder: (context, index) {
                      final route = filteredRoutes[index];
                      return RouteCard(
                        route: route,
                        onTap: () {
                          final routeModel = toRouteModel(route);
                          context.push(RouteMapScreen(route: routeModel));
                          _collapsePanel();
                        },
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
