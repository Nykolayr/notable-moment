import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class ProfileStatsBar extends ConsumerWidget {
  final int suscoins;
  final int energy;
  final VoidCallback onAddSuscoin;
  final VoidCallback? onAddEnergy;
  final VoidCallback? onHintPressed;
  final int hintsLeft;
  final bool hintUsedThisTest;
  const ProfileStatsBar({
    super.key,
    required this.suscoins,
    required this.energy,
    required this.onAddSuscoin,
    required this.onAddEnergy,
    this.onHintPressed,
    this.hintsLeft = 3,
    this.hintUsedThisTest = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/image/suscoin.png', width: 24, height: 24),
        const SizedBox(width: 6),
        Text(
          suscoins.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        const Gap(16),
        Row(
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SvgPicture.asset(
                'assets/svg/energy.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  i < energy ? const Color(0xFFFFB800) : const Color(0xFFE1E9F4),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4A90E2)),
          iconSize: 32,
          tooltip: 'Добавить сускоин',
          onPressed: onAddSuscoin,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.flash_on, color: Color(0xFFFFB800)),
          iconSize: 32,
          tooltip: 'Добавить энергию',
          onPressed: onAddEnergy,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onHintPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/svg/lamp.svg',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ],
    );
  }
}
