import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';

class PageTestScreen extends ConsumerWidget {
  final RouteModel route;
  final int currentIndex;

  const PageTestScreen({
    super.key,
    required this.route,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Прогресс по маршруту
    final progressState = ref.watch(progressProvider);
    final points = route.points;
    final totalCount = points.length;
    final lastUnlockedIndex = progressState.unlockedIndexes[route.id] ?? -1;
    final passedCount = lastUnlockedIndex + 1;

    // Проверка границ массива
    if (currentIndex < 0 || currentIndex >= totalCount) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F6),
        body: SafeArea(
          child: Center(
            child: Text(
              'Ошибка: неверный индекс точки ($currentIndex)',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      );
    }

    final question = points[currentIndex].test;
    final double progress = totalCount == 0 ? 0 : (passedCount) / totalCount;

    // Сускоины и энергия из профиля
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Выйти',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFE7EAF3),
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4A90E2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Image.asset('assets/coin.png', width: 24, height: 24),
                      const SizedBox(width: 4),
                      Text(
                        profile.suscoins.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      for (int i = 0; i < profile.energy; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(Icons.flash_on, color: Color(0xFFFFB800), size: 24),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.lightbulb_outline, color: Colors.black87, size: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    'Тут будет виджет вопроса для типа: \\${question.type.name}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF466BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ответить',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
