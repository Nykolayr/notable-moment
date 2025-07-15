import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/profile/provider/user_progress_provider.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EnergyRechargePage extends ConsumerWidget {
  final String routeId;
  const EnergyRechargePage({super.key, required this.routeId});

  String getSuslikImage(int energy) {
    if (energy == 0) return 'assets/image/sus_cry.png';
    if (energy == 1) return 'assets/image/sus_cry.png';
    if (energy == 2) return 'assets/image/sus_hi.png';
    if (energy == 3) return 'assets/image/sus_happy.png';
    return 'assets/image/sus_cry.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final userProgress = ref.watch(userProgressProvider);
    final energy = profile.energy;
    final suscoins = profile.suscoins;
    final suslikName = 'Валера';
    final suslikImage = getSuslikImage(energy);
    final canFeed = suscoins > 0 && energy < 3;
    final visitsInARow = userProgress.daysInARow;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Gap(32),
            Text(
              'Не удалось открыть новое место',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF222222),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Суслику нужна энергия, покормите его…',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color(0xFF8F99A8),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Суслик $suslikName',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const Gap(10),
                    Image.asset(
                      suslikImage,
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                    const Gap(10),
                    // Посещений подряд (бар)
                    const Text(
                      'Посещений подряд',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const Gap(8),
                    StreakBar(streak: visitsInARow),
                    const Gap(18),
                    // Энергия и сускоины с иконками info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Энергия', style: TextStyle(fontSize: 15, color: Color(0xFF222222))),
                            const SizedBox(width: 4),
                            Icon(Icons.info_outline, size: 18, color: Color(0xFF222222)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Сускоины', style: TextStyle(fontSize: 15, color: Color(0xFF222222))),
                            const SizedBox(width: 4),
                            Icon(Icons.info_outline, size: 18, color: Color(0xFF222222)),
                          ],
                        ),
                      ],
                    ),
                    const Gap(10),
                    // Визуальное отображение энергии и сускоина (как в ProfileStatsBar)
                    _EnergyAndSuscoinBar(energy: energy, suscoins: suscoins),
                    const Gap(18),
                    AppButton(
                      title: 'Покормить',
                      onTap: canFeed
                          ? () {
                              ref.read(profileProvider.notifier).spendSuscoins(1);
                              ref.read(profileProvider.notifier).addEnergy(1);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: energy > 1
                  ? AppButton(
                      title: 'Вернуться к маршруту',
                      onTap: () => Navigator.of(context).pop(),
                    )
                  : AppButton(
                      title: 'Завершить маршрут',
                      onTap: null,
                      style: AppButtonStyle.white,
                    ),
            ),
            const Gap(18),
          ],
        ),
      ),
    );
  }
}

class StreakBar extends StatelessWidget {
  final int streak;
  const StreakBar({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) {
        return Container(
          width: 32,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i < streak ? const Color(0xFF466BFF) : const Color(0xFFE7EAF3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _EnergyAndSuscoinBar extends StatelessWidget {
  final int energy;
  final int suscoins;
  const _EnergyAndSuscoinBar({required this.energy, required this.suscoins});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Энергия (3 svg молнии)
        Row(
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SvgPicture.asset(
                'assets/svg/energy.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  i < energy ? const Color(0xFFFFB800) : const Color(0xFFE1E9F4),
                  BlendMode.srcIn,
                ),
              ),
            );
          }),
        ),
        // Сускоины
        Row(
          children: [
            Image.asset('assets/image/suscoin.png', width: 24, height: 24),
            const SizedBox(width: 6),
            Text(
              suscoins.toString(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}
