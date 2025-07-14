import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';
import 'package:notable_moments/features/questions/widgets/profile_stats_bar.dart';
import 'package:notable_moments/features/questions/widgets/top_progress_bar.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/questions/widgets/modals.dart';

class PageTestScreen extends ConsumerStatefulWidget {
  final RouteModel route;
  final int currentIndex;

  const PageTestScreen({super.key, required this.route, required this.currentIndex});

  @override
  ConsumerState<PageTestScreen> createState() => _PageTestScreenState();
}

class _PageTestScreenState extends ConsumerState<PageTestScreen> {
  int currentTestIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Прогресс по маршруту
    final progressState = ref.watch(progressProvider);
    final points = widget.route.points;
    final totalCount = points.length;
    final lastUnlockedIndex = progressState.unlockedIndexes[widget.route.id] ?? -1;
    final passedCount = lastUnlockedIndex + 1;

    final tests = points[widget.currentIndex].tests;
    final currentTest = tests.isNotEmpty ? tests[currentTestIndex] : null;
    final double progress = totalCount == 0 ? 0 : (passedCount) / totalCount;

    // Сускоины и энергия из профиля
    final profile = ref.watch(profileProvider);
    Logger.i('progressState: ${progressState.toMap()}');
    Logger.i('profile: ${profile.energy} == ${profile.suscoins}');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TopProgressBar(
                    progress: progress,
                    onExit: () {
                      showExitConfirmModal(
                        context,
                        onExit: () => Navigator.of(context).pop(),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  ProfileStatsBar(
                    suscoins: profile.suscoins,
                    energy: profile.energy,
                    onAddSuscoin: () async {
                      await ref.read(profileProvider.notifier).addSuscoins(1);
                    },
                    onAddEnergy: profile.energy < 3
                        ? () async {
                            await ref.read(profileProvider.notifier).addEnergy(1);
                          }
                        : null,
                  ),
                ],
              ),
              if (tests.length > 1) ...[
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    tests.length,
                    (index) => _buildTestIndicator(index),
                  ),
                ),
              ],
              const Gap(24),
              if (currentTest != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(child: currentTest.type.buildTestWidget(currentTest)),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text('Нет доступных тестов'),
                  ),
                ),
              const Gap(24),
              AppButton(
                title: 'Ответить',
                onTap: currentTest != null
                    ? () {
                        // Если это последний тест, то завершаем
                        if (currentTestIndex == tests.length - 1) {
                          // TODO: Обработка завершения всех тестов
                        } else {
                          // Переходим к следующему тесту
                          setState(() {
                            currentTestIndex++;
                          });
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestIndicator(int index) {
    final isActive = index == currentTestIndex;
    final isCompleted = index < currentTestIndex;

    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? const Color(0xFF2F80ED)
            : isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}
