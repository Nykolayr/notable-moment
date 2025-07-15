// lib/features/routes/edit_route_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
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

  @override
  Widget build(BuildContext context) {
    final points = widget.route.polyline.points;
    final List<MapObject> mapObjects = [];
    if (points.isNotEmpty) {
      mapObjects.add(
        PolylineMapObject(
          mapId: const MapObjectId('edit_route_polyline'),
          polyline: Polyline(points: points),
          strokeColor: const Color(0xFF466BFF),
          strokeWidth: 4,
        ),
      );
      mapObjects.add(
        PlacemarkMapObject(
          mapId: const MapObjectId('edit_route_start'),
          point: points.first,
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/svg/placemark.svg'),
              scale: 1,
            ),
          ),
        ),
      );
    }
    return AppScaffold(
      appBar: const AppAppBar(title: 'Просмотр маршрута'),
      body: AppMap(
        onMapCreated: (controller) async {
          mapController = controller;
        },
        mapObjects: mapObjects,
        showEditButton: false,
      ),
    );
  }
}
