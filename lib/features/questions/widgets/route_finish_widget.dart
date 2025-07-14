import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notable_moments/core/widget/app_button.dart';

class RouteFinishWidget extends StatelessWidget {
  final int correctCount;
  final int total;
  final int suscoins;
  final int energy;
  final String? routeTitle;
  final VoidCallback onClose;
  const RouteFinishWidget({
    super.key,
    required this.correctCount,
    required this.total,
    required this.suscoins,
    required this.energy,
    this.routeTitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F4F6),
          body: Column(
            children: [
              const SizedBox(height: 120),
              if (routeTitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    routeTitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              if (routeTitle != null) const SizedBox(height: 16),
              Image.asset('assets/image/sus_champion.png', width: 180, height: 180),
              const SizedBox(height: 16),
              Text(
                '$correctCount из $total верных ответов',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/image/suscoin.png', width: 28, height: 28),
                  const SizedBox(width: 4),
                  Text('+$suscoins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 16),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          'assets/svg/energy.svg',
                          colorFilter: ColorFilter.mode(
                            const Color(0xFFFFB800),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: AppButton(
                  title: 'К другим маршрутам',
                  onTap: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestFinishWidget extends StatelessWidget {
  final int correctCount;
  final int total;
  final int suscoins;
  final String suslikAsset;
  final VoidCallback onFinish;
  final VoidCallback onNext;
  const QuestFinishWidget({
    super.key,
    required this.correctCount,
    required this.total,
    required this.suscoins,
    required this.suslikAsset,
    required this.onFinish,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F4F6),
          body: Column(
            children: [
              const SizedBox(height: 120),
              Text('Отличная работа!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Image.asset(suslikAsset, width: 160, height: 160),
              const SizedBox(height: 16),
              Text(
                '$correctCount из $total верных ответов',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/image/suscoin.png', width: 28, height: 28),
                  const SizedBox(width: 4),
                  Text('+$suscoins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 16),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          'assets/svg/energy.svg',
                          colorFilter: ColorFilter.mode(
                            const Color(0xFFFFB800),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        title: 'Завершить',
                        onTap: onFinish,
                        style: AppButtonStyle.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        title: 'Идти дальше',
                        onTap: onNext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
