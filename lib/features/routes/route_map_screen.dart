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

class RouteMapScreen extends ConsumerWidget {
  final RouteModel route;

  const RouteMapScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(progressProvider);
    final lastUnlockedIndex = unlocked.unlockedIndexes[route.id] ?? -1;
    final points = route.points;
    final title = route.title;
    final description = route.description;
    final routePoints = points
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => yandex.Point(latitude: p.latitude!, longitude: p.longitude!))
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
                      final overlay = Overlay.of(context);
                      final overlayEntry = OverlayEntry(
                        builder: (context) => Positioned(
                          top: MediaQuery.of(context).padding.top + 16,
                          left: 16,
                          right: 16,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF757B83),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Пройди все места выше, чтобы открыть доступ!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      );
                      overlay.insert(overlayEntry);
                      Future.delayed(const Duration(seconds: 6), () => overlayEntry.remove());
                    }
                  },
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
