import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';
import 'package:notable_moments/features/questions/widgets/profile_stats_bar.dart';
import 'package:notable_moments/features/questions/widgets/top_progress_bar.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/questions/widgets/modals.dart';

class PageTestScreen extends ConsumerWidget {
  final RouteModel route;
  final int currentIndex;

  const PageTestScreen({super.key, required this.route, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Прогресс по маршруту
    final progressState = ref.watch(progressProvider);
    final points = route.points;
    final totalCount = points.length;
    final lastUnlockedIndex = progressState.unlockedIndexes[route.id] ?? -1;
    final passedCount = lastUnlockedIndex + 1;

    final question = points[currentIndex].test;
    final double progress = totalCount == 0 ? 0 : (passedCount) / totalCount;

    // Сускоины и энергия из профиля
    final profile = ref.watch(profileProvider);
    Logger.i('progressState: ${progressState.toMap()}');
    Logger.i('profile: ${profile.energy} == ${profile.suscoins}');
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
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
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(child: question.type.buildTestWidget(question)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
