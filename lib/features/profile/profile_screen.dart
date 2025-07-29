import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:notable_moments/core/constant/app_pdf.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/provider/auth_provider.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_avatar.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_edit_button.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/features/profile/profile_edit_screen.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/profile/provider/user_progress_provider.dart';
import 'package:notable_moments/features/profile/sub_page/profile_faq.dart';
import 'package:notable_moments/features/profile/sub_page/profile_pdf.dart';
import 'package:notable_moments/features/profile/widget/feed_suslik_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Widget profileTile(String title, [VoidCallback? onTap]) =>
      AppGestureDetector(onTap: onTap, child: Text(title, style: AppStyle.subheader2.bgText900));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final userProgress = ref.watch(userProgressProvider);
    // streak: используем profile.streak если есть, иначе userProgress.daysInARow
    final streak = profile.streak != 0 ? profile.streak : userProgress.daysInARow;

    Widget profileLine(String title, {required VoidCallback onTap}) => AppGestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
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
                FeedSuslikWidget(
                  onFeed: () async {
                    await ref.read(profileProvider.notifier).spendSuscoins(1);
                    await ref.read(profileProvider.notifier).addEnergy(1);
                  },
                ),
                const Gap(4),
                profileTile('Помощь'),
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
