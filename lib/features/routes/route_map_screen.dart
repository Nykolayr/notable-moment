import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/questions/page_test_screen.dart';
import 'package:notable_moments/features/routes/widget/route_map_frame.dart';

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
  bool _mapInitialized = false;

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
    final routePoints = points.map((p) => Point(latitude: p.latitude!, longitude: p.longitude!)).toList();

    // Строим настоящий автомобильный маршрут через YandexDriving
    Polyline? routePolyline;
    if (routePoints.length >= 2) {
      try {
        // Создаем RequestPoint для каждой точки
        final requestPoints = routePoints
            .map((point) => RequestPoint(point: point, requestPointType: RequestPointType.wayPoint))
            .toList();

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
        Logger.e('_drawRouteAndPoints: Error building driving route: $e');
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

            // Показываем информацию о точке через SnackBar
            final taskCount = point.tests.length;
            final isOpen = point.isUnlocked;
            final pointInfo = '${point.name}\n(заданий - ${taskCount}) ${isOpen ? 'Открыто' : 'Закрыто'}';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(pointInfo),
                duration: const Duration(seconds: 3),
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

  Future<void> _fitBoundsToAllPoints() async {
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
      CameraUpdate.newBounds(
        BoundingBox(northEast: northEast, southWest: southWest),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description),
                      const Gap(24),
                      const Text(
                        'Почему этот маршрут',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Gap(8),
                      Text(whyThisRoute),
                      const Gap(24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: RouteMapFrame(route: widget.route),
                      ),
                      const Gap(24),
                      // --- Кнопка с динамическим текстом ---
                      Builder(
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
                            child: ElevatedButton(
                              onPressed: () {
                                context.showSnack('$buttonText скоро будет доступен');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                buttonText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // --- конец правки ---
                    ],
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
