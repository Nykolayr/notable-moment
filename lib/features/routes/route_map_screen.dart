import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_on_map.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex;
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';

// final progressProvider = StateNotifierProvider<RouteProgressNotifier, Set<int>>(
//   (_) => RouteProgressNotifier(),
// );

// class RouteProgressNotifier extends StateNotifier<Set<int>> {
//   RouteProgressNotifier() : super({0});

//   void unlockNext(int index) {
//     state = {...state, index + 1};
//   }
// }

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
      appBar: AppAppBar(title: 'Карта маршрута'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
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
                    const Gap(12),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                PointsOnMap(points: points),
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
                      Text(description),
                      const Gap(24),
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
                      const Gap(24),
                      // --- Кнопка с динамическим текстом ---
                      Builder(
                        builder: (context) {
                          final routeId = route.id;
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
