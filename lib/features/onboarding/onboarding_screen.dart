import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_text_button.dart';
import 'package:notable_moments/core/theme/app_images.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/features/global/provider/global_screen_provider.dart';
import 'package:notable_moments/features/onboarding/widget/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int bottomPageIndex = 0;

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return OnboardingPage(
          title: 'Исследуем город?',
          description: 'Я суслик Валера – любимец красноярцев и любитель приключений. Давай, исследуем город вместе!',
          imageWidget: LayoutBuilder(
            builder: (context, constraints) {
              return AspectRatio(
                aspectRatio: 369 / 312,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AppSvg.onboarding1.svgPricture,
                    SizedBox(width: constraints.maxWidth / 360 * 220, child: Image.asset(AppImages.susHappy)),
                  ],
                ),
              );
            },
          ),
          index: 0,
          bottomButton: AppTextButton(title: 'Пропустить', onTap: nextPage),
        );
      case 1:
        return OnboardingPage(
          title: 'Выполняй задания!',
          description: 'Отвечай на вопросы, чтобы открывать новые интересные места.',
          imageWidget: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final diameter = 360 / maxWidth * 215;
              return AspectRatio(
                aspectRatio: 369 / 312,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(alignment: Alignment.topRight, child: AppSvg.onboarding2_1.svgPricture),
                    Positioned(
                      top: 20,
                      left: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(diameter / 2),
                        child: Image.asset(
                          AppImages.susThink,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          height: diameter,
                          width: diameter,
                        ),
                      ),
                    ),
                    Positioned(bottom: 0, right: 15, child: AppSvg.onboarding2_2.svgPricture),
                  ],
                ),
              );
            },
          ),
          index: 1,
          bottomButton: AppTextButton(title: 'Пропустить', onTap: nextPage),
        );
      case 2:
        return OnboardingPage(
          title: 'Будь энергичным!',
          description: 'Заходи в приложение каждый день – получай сускоины и радуй суслика Валеру вкусностями.',
          imageWidget: LayoutBuilder(
            builder: (context, constraints) {
              final dy = 360 / constraints.maxWidth;
              return AspectRatio(
                aspectRatio: 360 / 360,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(alignment: Alignment.bottomCenter, child: Image.asset(AppImages.susHappy2, width: 214 * dy)),
                    Positioned(top: 0, left: dy * 38, child: Image.asset(AppImages.suscoin, height: dy * 45)),
                    Positioned(top: 38 * dy, left: 91 * dy, child: Image.asset(AppImages.suscoin, height: dy * 34)),
                    Positioned(top: 70 * dy, left: 16 * dy, child: Image.asset(AppImages.suscoin, height: dy * 75)),
                    Positioned(top: 0, right: 40 * dy, child: AppSvg.onboarding3.svgPricture),
                  ],
                ),
              );
            },
          ),
          index: 2,
          bottomButton: AppButton(title: 'В путь!', onTap: nextPage, style: AppButtonStyle.white),
        );
      default:
        throw Exception('Invalid page index');
    }
  }

  final controller = PageController();

  void nextPage() {
    if (controller.page == 2) {
      ref.read(globalScreenProvider.notifier).finishOnboarding();
    } else {
      controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(pageListener);
  }

  @override
  void dispose() {
    controller.removeListener(pageListener);
    controller.dispose();
    super.dispose();
  }

  void pageListener() {
    setState(() {
      bottomPageIndex = controller.page!.floor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildPage(bottomPageIndex),
        PageView.builder(
          controller: controller,
          itemCount: 3,
          itemBuilder: (context, index) => Opacity(opacity: index <= bottomPageIndex ? 0 : 1, child: _buildPage(index)),
        ),
      ],
    );
  }
}
