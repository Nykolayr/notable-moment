import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';

class RouteMapFrame extends StatefulWidget {
  final RouteModel route;
  const RouteMapFrame({super.key, required this.route});

  @override
  State<RouteMapFrame> createState() => _RouteMapFrameState();
}

class _RouteMapFrameState extends State<RouteMapFrame> {
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
    final routePoints = points.map((p) => Point(latitude: p.latitude!, longitude: p.longitude!)).toList();

    Polyline? routePolyline;
    if (routePoints.length >= 2) {
      try {
        final requestPoints = routePoints
            .map((point) => RequestPoint(point: point, requestPointType: RequestPointType.wayPoint))
            .toList();
        final drivingSession = await YandexDriving.requestRoutes(
          points: requestPoints,
          drivingOptions: DrivingOptions(),
        );
        final drivingResult = await drivingSession.$2;
        if (drivingResult.routes != null && drivingResult.routes!.isNotEmpty) {
          routePolyline = drivingResult.routes!.first.geometry;
        }
      } catch (e) {
        Logger.e('RouteMapFrame: Error building driving route: $e');
      }
    }
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
            setState(() {
              selectedPointIndex = i;
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
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          YandexMap(
            mapObjects: mapObjects,
            onMapCreated: (controller) async {
              if (_mapInitialized) return;
              mapController = controller;
              _mapInitialized = true;
              await Future.delayed(const Duration(milliseconds: 500));
              _drawRouteAndPoints();
              await Future.delayed(const Duration(milliseconds: 300));
              await _fitBoundsToAllPoints();
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.icon(
                    icon: AppIcon.plus,
                    onTap: () => mapController?.moveCamera(CameraUpdate.zoomIn()),
                  ),
                  const SizedBox(height: 4),
                  AppButton.icon(
                    icon: AppIcon.minus,
                    onTap: () => mapController?.moveCamera(CameraUpdate.zoomOut()),
                  ),
                  const SizedBox(height: 4),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
