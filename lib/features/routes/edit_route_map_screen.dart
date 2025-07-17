// lib/features/routes/edit_route_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class EditRouteMapScreen extends ConsumerStatefulWidget {
  final RouteAdminModel route;

  const EditRouteMapScreen({
    super.key,
    required this.route,
  });

  @override
  ConsumerState<EditRouteMapScreen> createState() => _EditRouteMapScreenState();
}

class _EditRouteMapScreenState extends ConsumerState<EditRouteMapScreen> {
  YandexMapController? mapController;
  List<MapObject> mapObjects = [];
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _drawRouteAndPoints();
  }

  Future<Polyline> buildRoutePolyline(List<Point> points) async {
    if (points.length < 2) return Polyline(points: points);
    try {
      final requestPoints =
          points.map((point) => RequestPoint(point: point, requestPointType: RequestPointType.wayPoint)).toList();
      final drivingSession = await YandexDriving.requestRoutes(
        points: requestPoints,
        drivingOptions: DrivingOptions(),
      );
      final drivingResult = await drivingSession.$2;
      if (drivingResult.routes != null && drivingResult.routes!.isNotEmpty) {
        return drivingResult.routes!.first.geometry;
      }
    } catch (e) {
      // ignore
    }
    return Polyline(points: points);
  }

  static const krasnoyarskPoint = Point(latitude: 56.0267294, longitude: 92.865734);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Просмотр маршрута'),
      body: Stack(
        children: [
          YandexMap(
            mapObjects: mapObjects,
            onMapCreated: (controller) async {
              if (_mapInitialized) return;
              mapController = controller;
              _mapInitialized = true;
              // Сначала центрируем на Красноярске
              await controller.moveCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    target: krasnoyarskPoint,
                    zoom: 12,
                  ),
                ),
              );
              await Future.delayed(const Duration(milliseconds: 300));
              _drawRouteAndPoints();
              await Future.delayed(const Duration(milliseconds: 300));
              // Если есть хотя бы одна точка — fitBounds
              final points = widget.route.points;
              if (points.length == 1) {
                await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: Point(latitude: points.first.latitude, longitude: points.first.longitude),
                      zoom: 15,
                    ),
                  ),
                );
              } else if (points.length > 1) {
                await _fitBoundsToAllPoints();
              }
            },
          ),
          // Кнопки управления картой
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
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
                    onTap: () async {
                      await mapController?.moveCamera(
                        CameraUpdate.newCameraPosition(
                          const CameraPosition(
                            target: krasnoyarskPoint,
                            zoom: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _drawRouteAndPoints() async {
    final points = widget.route.points;
    final List<MapObject> objects = [];

    if (points.isNotEmpty) {
      final routePoints = points.map((p) => Point(latitude: p.latitude, longitude: p.longitude)).toList();
      if (routePoints.length >= 2) {
        final routePolyline = await buildRoutePolyline(routePoints);
        objects.add(
          PolylineMapObject(
            mapId: const MapObjectId('edit_route_polyline'),
            polyline: routePolyline,
            strokeColor: const Color(0xFF466BFF),
            strokeWidth: 4,
            dashLength: 12.0,
            gapLength: 6.0,
            zIndex: 1000,
          ),
        );
      }
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        objects.add(
          PlacemarkMapObject(
            mapId: MapObjectId('edit_route_point_$i'),
            point: Point(latitude: point.latitude, longitude: point.longitude),
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
                scale: 1.0,
              ),
            ),
            onTap: (_, __) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              final pointInfo = 'Точка ${i + 1}';
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
    }

    setState(() {
      mapObjects = objects;
    });
  }

  Future<void> _fitBoundsToAllPoints() async {
    final points = widget.route.points;
    if (points.length < 2 || mapController == null) return;

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

    // Паддинг 15 по всем сторонам
    await mapController!.moveCamera(
      CameraUpdate.newGeometry(
        Geometry.fromBoundingBox(BoundingBox(northEast: northEast, southWest: southWest)),
      ),
    );
  }
}
