import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex;

import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';

final progressProvider = StateNotifierProvider<RouteProgressNotifier, Set<int>>(
  (_) => RouteProgressNotifier(),
);

class RouteProgressNotifier extends StateNotifier<Set<int>> {
  RouteProgressNotifier() : super({0});

  void unlockNext(int index) {
    state = {...state, index + 1};
  }
}

class RouteMapScreen extends ConsumerWidget {
  final RouteModel route;

  const RouteMapScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(progressProvider);
    final points = route.points;
    final title = route.title;
    final description = route.description;
    final routePoints = points
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => yandex.Point(latitude: p.latitude!, longitude: p.longitude!))
        .toList();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Карта маршрута',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EDFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildRouteVisual(context, ref, unlocked, points),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(description),
                    const SizedBox(height: 24),
                    const Text(
                      'Почему этот маршрут',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(description),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: AppMap(
                          onMapCreated: (mapWindow) {
                            final map = mapWindow.map;
                            final polyline = yandex.Polyline(routePoints);
                            map.addPolyline(polyline);
                            if (routePoints.isNotEmpty) {
                              map.addPlacemark(routePoints.first);
                            }
                          },
                          disableTaps: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.showSnack('Повтор маршрута скоро будет доступен');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Повторить',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _buildRouteVisual(BuildContext context, WidgetRef ref, Set<int> unlocked, List<RoutePoint> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(points.length, (index) {
        final isLocked = !unlocked.contains(index);
        final color = isLocked ? Colors.grey : Colors.blue;
        final icon = isLocked ? '🔒' : '';
        final point = points[index];
        final label = point.name;
        return Row(
          children: [
            Icon(Icons.location_on, color: color),
            const SizedBox(width: 8),
            Text('$label $icon', style: TextStyle(color: color)),
          ],
        );
      }),
    );
  }
}
