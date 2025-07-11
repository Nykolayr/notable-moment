import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex;

import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/beginning_quest_screen.dart';
import 'package:notable_moments/features/Quests/quest_onboarding_screen.dart';

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
  final String title;
  final String description;

  RouteMapScreen({
    super.key,
    required this.title,
    required this.description,
  });

  final List<String> routeLabels = [
    'река Енисей',
    'Музей-усадьба В.И. Сурикова',
    'Детская художественная школа №1 имени В.И. Сурикова',
    'Мурал',
    'Караульная гора',
    'Бывшее Кузнецовское подворье',
    'Красноярский художественный музей имени В. И. Сурикова',
  ];

  final List<yandex.Point> routePoints = [
    yandex.Point(latitude: 56.0153, longitude: 92.8932),
    yandex.Point(latitude: 56.0120, longitude: 92.8800),
    yandex.Point(latitude: 56.0100, longitude: 92.8700),
    yandex.Point(latitude: 56.0170, longitude: 92.8920),
    yandex.Point(latitude: 56.0145, longitude: 92.8855),
    yandex.Point(latitude: 56.0165, longitude: 92.8811),
    yandex.Point(latitude: 56.0180, longitude: 92.8830),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(progressProvider);

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
                          'Карта маршрутов',
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
                child: _buildRouteVisual(context, ref, unlocked),
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

  Widget _buildRouteVisual(BuildContext context, WidgetRef ref, Set<int> unlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(routeLabels.length, (index) {
        final isLocked = !unlocked.contains(index);
        final color = isLocked ? Colors.grey : Colors.blue;
        final icon = isLocked ? '🔒' : '';

        final pointWidget = GestureDetector(
          onTap: isLocked
              ? null
              : () async {
                  final prefs = await SharedPreferences.getInstance();
                  final hasSeenOnboarding = prefs.getBool('hasSeenQuestOnboarding') ?? false;

                  if (!hasSeenOnboarding) {
                    // ignore: use_build_context_synchronously
                    final onboardingResult = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => const QuestOnboardingScreen(),
                          ),
                        ) ??
                        false;

                    if (!onboardingResult) {
                      if (context.mounted) {
                        context.showSnack('Онбординг не завершён');
                      }
                      return;
                    }

                    await prefs.setBool('hasSeenQuestOnboarding', true);
                  }

                  final testId = 'test_$index';
                  final pointId = 'point_$index';
                  final nextPointId = 'point_${index + 1}';

                  // ignore: use_build_context_synchronously
                  final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (context) => BeginningQuestScreen(
                            testId: testId,
                            pointId: pointId,
                            nextPointId: nextPointId,
                          ),
                        ),
                      ) ??
                      false;

                  if (result) {
                    ref.read(progressProvider.notifier).unlockNext(index);
                    if (context.mounted) {
                      context.showSnack('Квест пройден! Следующая точка разблокирована.');
                    }
                  } else {
                    if (context.mounted) {
                      context.showSnack('Квест не завершён.');
                    }
                  }
                },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              if (icon.isNotEmpty)
                Text(
                  icon,
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                pointWidget,
                if (index != routeLabels.length - 1)
                  Container(
                    width: 4,
                    height: 36,
                    color: color,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  routeLabels[index],
                  style: TextStyle(
                    color: isLocked ? Colors.grey : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
