import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/questions/page_test_screen.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_on_map.dart';
import 'package:notable_moments/features/routes/utils/route_builder.dart';

class RouteMapScreen extends ConsumerStatefulWidget {
  final RouteModel route;

  const RouteMapScreen({super.key, required this.route});

  @override
  ConsumerState<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends ConsumerState<RouteMapScreen> {
  YandexMapController? mapController;
  List<MapObject> mapObjects = [];
  int? selectedPointIndex;
  bool mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _drawRouteAndPoints();
  }

  void _drawRouteAndPoints() async {
    final route = widget.route;
    final points = route.points.where((p) => p.latitude != null && p.longitude != null).toList();

    if (points.isEmpty) {
      setState(() {
        mapObjects = [];
      });
      return;
    }

    final List<MapObject> objects = [];

    // Получаем точки маршрута
    final routePoints = points
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => Point(latitude: p.latitude!, longitude: p.longitude!))
        .toList();

    // Строим настоящий пеший маршрут через YandexPedestrian
    Polyline? routePolyline;
    if (routePoints.length >= 2) {
      try {
        // Создаем RequestPoint для каждой точки
        final requestPoints = routePoints
            .map((point) => RequestPoint(point: point, requestPointType: RequestPointType.wayPoint))
            .toList();

        // Запрос на построение пешего маршрута
        final pedestrianSession = await YandexPedestrian.requestRoutes(
          points: requestPoints,
          avoidSteep: false,
          timeOptions: TimeOptions(),
        );

        // Обработка результата
        final pedestrianResult = await pedestrianSession.$2;
        if (pedestrianResult.routes != null && pedestrianResult.routes!.isNotEmpty) {
          routePolyline = pedestrianResult.routes!.first.geometry;
        }
      } catch (e) {
        Logger.e('_drawRouteAndPoints: Error building pedestrian route: $e');
      }
    }

    // Если не удалось построить маршрут, используем прямую линию
    routePolyline ??= Polyline(points: routePoints);

    objects.add(
      PolylineMapObject(
        mapId: const MapObjectId('route_polyline'),
        polyline: routePolyline,
        strokeColor: const Color(0xFF466BFF),
        strokeWidth: 4,
        dashLength: 12.0,
        gapLength: 6.0,
        zIndex: 1000,
      ),
    );

    // Добавляем точки маршрута
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isSelected = i == selectedPointIndex;

      objects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('placemark_$i'),
          point: Point(latitude: point.latitude!, longitude: point.longitude!),
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
              scale: isSelected ? 1.2 : 1.0,
            ),
          ),
          onTap: (_, __) {
            Logger.i('Point tapped: ${point.name} | Tests: ${point.tests.length}');

            setState(() {
              selectedPointIndex = i;

              // Обновляем все точки с новыми размерами
              for (int j = 0; j < mapObjects.length; j++) {
                final obj = mapObjects[j];
                if (obj is PlacemarkMapObject && obj.mapId.value.startsWith('placemark_')) {
                  final isThisSelected = obj.mapId.value == 'placemark_$i';
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

            // Закрываем предыдущие SnackBar перед показом нового
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // Показываем информацию о точке через SnackBar на 1 секунду
            final taskCount = point.tests.length;
            final isOpen = point.isUnlocked;
            final pointInfo = '${point.name}\n(заданий - $taskCount) ${isOpen ? 'Открыто' : 'Закрыто'}';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(pointInfo),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          zIndex: 2000,
        ),
      );
    }

    setState(() {
      mapObjects = objects;
    });
  }

  Future<void> fitBoundsToAllPoints() async {
    final points = widget.route.points.where((p) => p.latitude != null && p.longitude != null).toList();
    if (points.length < 2 || mapController == null) return;
    final latitudes = points.map((p) => p.latitude!).toList();
    final longitudes = points.map((p) => p.longitude!).toList();
    double minLat = latitudes.reduce((a, b) => a < b ? a : b);
    double maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    double minLng = longitudes.reduce((a, b) => a < b ? a : b);
    double maxLng = longitudes.reduce((a, b) => a > b ? a : b);
    // Добавляем небольшой отступ (примерно 0.01 градуса, можно скорректировать)
    const double padding = 0.01;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;
    final southWest = Point(latitude: minLat, longitude: minLng);
    final northEast = Point(latitude: maxLat, longitude: maxLng);
    await mapController!.moveCamera(
      CameraUpdate.newGeometry(
        Geometry.fromBoundingBox(BoundingBox(northEast: northEast, southWest: southWest)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = ref.watch(progressProvider);
    final lastUnlockedIndex = unlocked.unlockedIndexes[widget.route.id] ?? -1;
    final points = widget.route.points;
    final title = widget.route.title;
    final description = widget.route.description;
    final whyThisRoute = widget.route.whyThisRoute ?? '';

    final routePoints = points
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => Point(latitude: p.latitude!, longitude: p.longitude!))
        .toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppAppBar(title: 'Карта маршрута'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                PointsOnMap(
                  points: points,
                  lastUnlockedIndex: lastUnlockedIndex,
                  onPointTap: (index, isLocked) {
                    if (isLocked) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PageTestScreen(
                            route: widget.route,
                            currentIndex: index,
                          ),
                        ),
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Text(description),
                ),
                if (whyThisRoute.trim().isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: const Text(
                      'Почему этот маршрут',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text(whyThisRoute),
                  ),
                ],
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: AbsorbPointer(
                        absorbing: true,
                        child: _RouteMapView(routePoints: routePoints),
                      ),
                    ),
                  ),
                ),
                const Gap(24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Builder(
                    builder: (context) {
                      final routeId = widget.route.id;
                      final totalPoints = points.length;
                      final lastUnlocked = unlocked.unlockedIndexes[routeId] ?? -1;
                      final passedCount = lastUnlocked + 1;
                      String buttonText;
                      if (passedCount <= 0) {
                        buttonText = 'Пройти маршрут';
                      } else if (passedCount < totalPoints) {
                        buttonText = 'Продолжить';
                      } else {
                        buttonText = 'Повторить';
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          title: buttonText,
                          onTap: () {
                            // Находим первую неоткрытую точку
                            int firstLockedIndex = 0;

                            // Если есть открытые точки, начинаем с первой закрытой
                            if (lastUnlocked >= 0) {
                              firstLockedIndex = lastUnlocked + 1;
                            }

                            // Проверяем, что индекс не выходит за границы массива
                            if (firstLockedIndex < totalPoints) {
                              // Переходим к прохождению тестов для этой точки
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PageTestScreen(
                                    route: widget.route,
                                    currentIndex: firstLockedIndex,
                                  ),
                                ),
                              );
                            } else {
                              // Если все точки пройдены, начинаем сначала
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PageTestScreen(
                                    route: widget.route,
                                    currentIndex: 0,
                                  ),
                                ),
                              );
                            }
                          },
                          style: AppButtonStyle.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteMapView extends StatefulWidget {
  final List<Point> routePoints;
  const _RouteMapView({required this.routePoints});

  @override
  State<_RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<_RouteMapView> {
  List<MapObject> _mapObjects = [];
  YandexMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _buildMapObjects();
  }

  void _buildMapObjects() async {
    final points = widget.routePoints;
    final List<MapObject> objects = [];

    if (points.length >= 2) {
      final routePolyline = await RouteBuilder.buildRoutePolyline(points);
      objects.add(
        PolylineMapObject(
          mapId: const MapObjectId('route_polyline'),
          polyline: routePolyline,
          strokeColor: const Color(0xFF466BFF),
          strokeWidth: 4,
          dashLength: 12.0,
          gapLength: 6.0,
        ),
      );
    }

    for (int i = 0; i < points.length; i++) {
      objects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('point_$i'),
          point: points[i],
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
              scale: 1,
            ),
          ),
          zIndex: 2000,
        ),
      );
    }

    setState(() {
      _mapObjects = objects;
    });
  }

  Future<void> _fitBoundsToAllPoints() async {
    // Собираем все точки: и точки маршрута, и точки линии
    final points = <Point>[];
    points.addAll(widget.routePoints);
    // Найти PolylineMapObject
    final polylineObj = _mapObjects.whereType<PolylineMapObject>().firstOrNull;
    if (polylineObj is PolylineMapObject) {
      points.addAll(polylineObj.polyline.points);
    }
    if (points.length < 2 || _mapController == null) return;

    final latitudes = points.map((p) => p.latitude).toList();
    final longitudes = points.map((p) => p.longitude).toList();

    double minLat = latitudes.reduce((a, b) => a < b ? a : b);
    double maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    double minLng = longitudes.reduce((a, b) => a < b ? a : b);
    double maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    // Добавляем минимальный отступ для всех точек от краёв экрана
    const double padding = 0.01;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    final southWest = Point(latitude: minLat, longitude: minLng);
    final northEast = Point(latitude: maxLat, longitude: maxLng);

    await _mapController!.moveCamera(
      CameraUpdate.newGeometry(
        Geometry.fromBoundingBox(BoundingBox(northEast: northEast, southWest: southWest)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YandexMap(
      mapObjects: _mapObjects,
      onMapCreated: (controller) async {
        _mapController = controller;

        // Сначала центрируем на Красноярске
        await controller.moveCamera(
          CameraUpdate.newCameraPosition(
            const CameraPosition(
              target: Point(latitude: 56.0267294, longitude: 92.865734),
              zoom: 12,
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 300));

        // Если есть точки - делаем fitBounds
        if (widget.routePoints.length >= 2) {
          await _fitBoundsToAllPoints();
        } else if (widget.routePoints.length == 1) {
          await controller.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: widget.routePoints.first,
                zoom: 15,
              ),
            ),
          );
        }
      },
    );
  }
}
