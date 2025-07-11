// lib/features/routes/edit_route_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;

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
  late yandex_map.MapWindow _mapWindow;
  yandex_map.Map get map => _mapWindow.map;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Просмотр маршрута'),
      body: AppMap(
        onMapCreated: (mapWindow) async {
          _mapWindow = mapWindow;

          // Добавляем маршрут на карту
          map.addRoute(widget.route);

          if (widget.route.polyline.points.isNotEmpty) {
            // Вычисляем границы polyline
            final points = widget.route.polyline.points;
            double minLat = points.first.latitude;
            double maxLat = points.first.latitude;
            double minLon = points.first.longitude;
            double maxLon = points.first.longitude;

            for (var point in points) {
              if (point.latitude < minLat) minLat = point.latitude;
              if (point.latitude > maxLat) maxLat = point.latitude;
              if (point.longitude < minLon) minLon = point.longitude;
              if (point.longitude > maxLon) maxLon = point.longitude;
            }

            final centerPoint = yandex_map.Point(
              latitude: (minLat + maxLat) / 2,
              longitude: (minLon + maxLon) / 2,
            );

            map.animateToPoint(
              centerPoint,
              zoom: 12,
              duration: const Duration(milliseconds: 700),
            );
          } else {
            // Плавная анимация к Красноярску
            map.animateToPoint(
              const yandex_map.Point(latitude: 56.010569, longitude: 92.852572),
              zoom: 12,
              duration: const Duration(milliseconds: 700),
            );
          }
        },
        disableTaps: true,
      ),
    );
  }
}
