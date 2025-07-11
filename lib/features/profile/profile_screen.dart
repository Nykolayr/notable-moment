import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notable_moments/core/constant/app_pdf.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/provider/auth_provider.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_images.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_avatar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_edit_button.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/features/profile/profile_edit_screen.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/profile/provider/sus_provider.dart';
import 'package:notable_moments/features/profile/sub_page/profile_faq.dart';
import 'package:notable_moments/features/profile/sub_page/profile_pdf.dart';
import 'package:notable_moments/features/profile/widget/info_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Widget profileTile(String title, [VoidCallback? onTap]) =>
      AppGestureDetector(onTap: onTap, child: Text(title, style: AppStyle.subheader2.bgText900));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final sus = ref.watch(susProvider);

    Widget profileLine(String title, {required VoidCallback onTap}) => AppGestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppStyle.body.bgText900)),
                AppIcon.chevronRight.svgPricture,
              ],
            ),
          ),
        );

    return Scaffold(
      backgroundColor: AppColor.bgText00,
      body: Column(
        children: [
          SizedBox(height: context.safeArea.top),
          Container(
            width: double.infinity,
            height: 76,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppAvatar(size: 44, avatarId: profile.avatarId),
                const SizedBox(width: 12),
                Expanded(child: Text(profile.name ?? '', style: AppStyle.subheader2.bgText900)),
                AppEditButton(onTap: () => context.push(ProfileEditScreen())),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 18),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  decoration: BoxDecoration(color: AppColor.bgText100, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text('Суслик Валера', style: AppStyle.suslik.bgText900),
                      const SizedBox(height: 16),
                      Image.asset(sus.energy <= 1 ? AppImages.susCry : AppImages.susHi, height: 170),
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
                                color: sus.daysInARow > index ? AppColor.primary : AppColor.bgText300,
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
                                children: [
                                  Text('Энергия', style: AppStyle.subtext.bgText900),
                                  const SizedBox(width: 4),
                                  AppInfoWidget(text: 'Покупай суслику еду и пополняй энергию.'),
                                ],
                              ),
                              const SizedBox(height: 5.5),
                              Row(
                                children: List.generate(
                                  3,
                                  (index) => SvgPicture.asset(
                                    AppIcon.energy,
                                    // ignore: deprecated_member_use
                                    color: sus.energy > index ? AppColor.orange : AppColor.bgText300,
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
                                  AppInfoWidget(text: 'Заходи 7 дней подряд в приложение и получай сускоины.'),
                                ],
                              ),
                              const SizedBox(height: 5.5),
                              Row(
                                children: [
                                  Image.asset(AppImages.suscoin, height: 24, width: 24),
                                  const SizedBox(width: 8),
                                  Text(sus.suscoins.toString(), style: AppStyle.body.bgText900),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        title: 'Покормить',
                        onTap:
                            sus.energy == 3 || sus.suscoins == 0 ? null : () => ref.read(susProvider.notifier).feed(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                profileTile('Помощь'),
                const SizedBox(height: 12),
                profileLine(
                  'Часто задаваемые вопросы',
                  onTap: () => context.push(const ProfileFAQ()),
                ),
                profileLine(
                  'Чат поддержки',
                  onTap: () => context.openLink('mailto:geekflownativetouches@gmail.com'),
                ),
                const SizedBox(height: 24),
                profileTile('О приложении'),
                const SizedBox(height: 12),
                profileLine(
                  'Политика конфиденциальности',
                  onTap: () => context.push(
                    ProfilePdf(
                      title: 'Политика конфиденциальности',
                      asset: AppPdf.privacyPolicy,
                    ),
                  ),
                ),
                profileLine(
                  'Пользовательское соглашение',
                  onTap: () => context.push(
                    ProfilePdf(
                      title: 'Пользовательское соглашение',
                      asset: AppPdf.userAgreement,
                    ),
                  ),
                ),
                profileLine(
                  'Политика в отношении обработки персональных данных',
                  onTap: () => context.push(
                    ProfilePdf(
                      title: 'Политика в отношении обработки персональных данных',
                      asset: AppPdf.dataPolicy,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                profileTile(
                  'Выйти',
                  () => appButtonDeleteDialog(
                    title: 'Вы уверены, что хотите выйти?',
                    context: context,
                    okText: 'Выйти',
                    okCallBack: () => ref.read(authProvider.notifier).signOut(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
