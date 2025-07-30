import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_images.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'info_widget.dart';

class FeedSuslikWidget extends ConsumerWidget {
  final VoidCallback onFeed;
  final String energyInfo;
  final String suscoinInfo;
  final String suslikName;

  const FeedSuslikWidget({
    super.key,
    required this.onFeed,
    this.energyInfo = 'Покупай суслику еду и пополняй энергию.',
    this.suscoinInfo = 'Заходи 7 дней подряд в приложение и получай сускоины.',
    this.suslikName = 'Валера',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final energy = profile.energy;
    final suscoins = profile.suscoins;
    final streak = profile.streak;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(color: AppColor.bgText100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('Суслик $suslikName', style: AppStyle.suslik.bgText900),
          const SizedBox(height: 16),
          Image.asset(energy <= 1 ? AppImages.susCry : AppImages.susHi, height: 170),
          const SizedBox(height: 16),
          Text('Посещений подряд', style: AppStyle.subtext.bgText900),
          const SizedBox(height: 7),
          SizedBox(
            height: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                7,
                (index) => Container(
                  height: 6,
                  width: 27,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: streak > index ? AppColor.primary : AppColor.bgText300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              ),
              const SizedBox(width: 46),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('Сускоины', style: AppStyle.subtext.bgText900),
                      const SizedBox(width: 4),
                      AppInfoWidget(text: suscoinInfo),
                    ],
                  ),
                  const SizedBox(height: 5.5),
                  Row(
                    children: [
                      Image.asset(AppImages.suscoin, height: 24, width: 24),
                      const SizedBox(width: 8),
                      Text(suscoins.toString(), style: AppStyle.body.bgText900),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            title: 'Покормить',
            onTap: energy >= 3 || suscoins < 1 ? null : onFeed,
          ),
        ],
      ),
    );
  }
}
