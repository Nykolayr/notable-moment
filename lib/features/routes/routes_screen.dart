import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
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

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedRouteProvider = StateProvider<RouteModel?>((ref) => null);

RouteModel toRouteModel(RouteAdminModel admin) {
  return RouteModel(
    id: admin.id,
    title: admin.title,
    description: admin.description,
    points: admin.points.map((p) {
      return RoutePoint(
        name: p.title, // ← Исправлено: теперь берём название точки
        description: p.description,
        latitude: p.latitude,
        longitude: p.longitude,
        tests: p.tests,
      );
    }).toList(),
    taskCount: admin.points.length,
  );
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
  static const double _collapsedHeightFactor = 0.106;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    mapController = null;
    super.dispose();
  }

  @override
  void didPopNext() {
    // Вернулись на экран — обновить точки и маршруты
    _drawRoutesAndPoints();
  }

  @override
  bool get wantKeepAlive => true;

  void _expandPanel() {
    _animationController.forward();
    isExpanded = true;
  }

  void _collapsePanel() {
    _animationController.reverse();
    isExpanded = false;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final fractionDelta = -delta / (screenHeight * (_expandedHeightFactor - _collapsedHeightFactor));
    _animationController.value = (_animationController.value + fractionDelta).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      _expandPanel();
    } else if (velocity > 300) {
      _collapsePanel();
    } else {
      if (_animationController.value > 0.5) {
        _expandPanel();
      } else {
        _collapsePanel();
      }
    }
  }

  void _drawRoutesAndPoints() async {
    final allRoutes = ref.watch(routesProvider).allRoutes;

    if (allRoutes.isEmpty) {
      setState(() {
        mapObjects = [];
      });
      return;
    }

    int globalIndex = 0;
    final List<MapObject> objects = [];

    for (final route in allRoutes) {
      if (route.points.isEmpty) continue;

      // Получаем точки маршрута
      final points = route.points.map((p) => Point(latitude: p.point.latitude, longitude: p.point.longitude)).toList();

      // Строим настоящий автомобильный маршрут через YandexDriving
      Polyline? routePolyline;
      if (points.length >= 2) {
        try {
          // Создаем RequestPoint для каждой точки
          final requestPoints =
              points.map((point) => RequestPoint(point: point, requestPointType: RequestPointType.wayPoint)).toList();

          // Запрос на построение маршрута
          final drivingSession = await YandexDriving.requestRoutes(
            points: requestPoints,
            drivingOptions: DrivingOptions(),
          );

          // Обработка результата
          final drivingResult = await drivingSession.$2;
          if (drivingResult.routes != null && drivingResult.routes!.isNotEmpty) {
            routePolyline = drivingResult.routes!.first.geometry;
          }
        } catch (e) {
          Logger.e('_drawRoutesAndPoints: Error building driving route: $e');
        }
      }

      // Если не удалось построить маршрут, используем прямую линию
      routePolyline ??= Polyline(points: points);

      objects.add(
        PolylineMapObject(
          mapId: MapObjectId('polyline_${route.id}'),
          polyline: routePolyline,
          strokeColor: const Color(0xFF466BFF), // Всегда синий
          strokeWidth: 4, // Всегда толстая линия
          dashLength: 12.0, // Штрих
          gapLength: 6.0, // Промежуток
          zIndex: 1000, // Высокий zIndex чтобы маршруты были поверх всего
        ),
      );

      for (int i = 0; i < route.points.length; i++) {
        final point = route.points[i];
        final isSelected = globalIndex == selectedPointIndex;

        objects.add(
          PlacemarkMapObject(
            mapId: MapObjectId('placemark_${route.id}_$i'),
            point: Point(latitude: point.point.latitude, longitude: point.point.longitude),
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
                scale: isSelected ? 1.4 : 1.0,
              ),
            ),
            onTap: (_, __) {
              Logger.i(
                'Point tapped: ${point.title} | Description: ${point.description} | Tests: ${point.tests.length} | Draft: ${point.isDraft} | Current index: $selectedPointIndex, new: $globalIndex | Scale: ${isSelected ? 1.4 : 1.0}',
              );

              setState(() {
                selectedPointIndex = globalIndex;
                Logger.i('Updated selectedPointIndex to: $selectedPointIndex');

                // Обновляем все точки с новыми размерами
                for (int j = 0; j < mapObjects.length; j++) {
                  final obj = mapObjects[j];
                  if (obj is PlacemarkMapObject && obj.mapId.value.startsWith('placemark_')) {
                    final isThisSelected = obj.mapId.value == 'placemark_${route.id}_$i';
                    final newScale = isThisSelected ? 1.2 : 1.0;

                    mapObjects[j] = PlacemarkMapObject(
                      mapId: obj.mapId,
                      point: obj.point,
                      opacity: obj.opacity,
                      icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                          image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
                          scale: newScale,
                        ),
                      ),
                      onTap: obj.onTap,
                      zIndex: obj.zIndex,
                    );
                  }
                }
              });

              // Показываем окно маршрута при нажатии на точку
              ref.read(selectedRouteProvider.notifier).state = toRouteModel(route);

              // Закрываем предыдущие SnackBar перед показом нового
              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              // Показываем информацию о точке через SnackBar на 3 секунды
              final taskCount = point.tests.length;
              final isOpen = !point.isDraft;
              final pointInfo = '${point.title}\n(заданий - $taskCount) ${isOpen ? 'Открыто' : 'Закрыто'}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(pointInfo),
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            zIndex: 2000, // Еще выше zIndex для точек
          ),
        );
        globalIndex++;
      }
    }

    setState(() {
      mapObjects = objects;
    });
  }

  /// Генерирует маршрут с отклонениями между точками
  Polyline generateRouteWithDeviations(List<Point> waypoints) {
    if (waypoints.length < 2) {
      return Polyline(points: waypoints);
    }

    final List<Point> routePoints = [];
    final random = Random();

    for (int i = 0; i < waypoints.length - 1; i++) {
      final start = waypoints[i];
      final end = waypoints[i + 1];

      // Добавляем начальную точку
      routePoints.add(start);

      // Создаем промежуточные точки с большими отклонениями
      for (int j = 1; j <= 5; j++) {
        final progress = j / 6.0;

        // Линейная интерполяция между точками
        final lat = start.latitude + (end.latitude - start.latitude) * progress;
        final lng = start.longitude + (end.longitude - start.longitude) * progress;

        // Добавляем большое случайное отклонение (до 200 метров)
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
                  // Прозрачный фон для закрытия карточки
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        // Закрываем карточку при нажатии на фон
                        ref.read(selectedRouteProvider.notifier).state = null;
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  // Карточка маршрута
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: RouteTooltipCard(route: selectedRoute),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, List<RouteAdminModel> routes) {
    final query = ref.watch(searchQueryProvider);
    final filtered = routes.where((r) {
      return r.title.toLowerCase().contains(query) || (r.description.toLowerCase()).contains(query);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value.trim().toLowerCase();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Ничего не найдено'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final route = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedRouteProvider.notifier).state = toRouteModel(route);
                          _collapsePanel();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(route.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                'Локаций: ${route.points.length}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              if (route.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    route.description,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
