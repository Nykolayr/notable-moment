import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notable_moments/core/constant/enum/gender_enum.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/helpers/validator.dart';
import 'package:notable_moments/core/provider/auth_provider.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_avatar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_edit_button.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_input_datetime.dart';
import 'package:notable_moments/core/widget/app_radio_group.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/core/widget/app_text_button.dart';
import 'package:notable_moments/features/global/widget/school_dropdown.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final nameController = TextEditingController();
  final birthdayController = TextEditingController();
  String? school;
  Gender? gender;
  late int avatarId;
  final _dateFormat = DateFormat('dd.MM.yyyy');

  bool get canSave {
    final profile = ref.watch(profileProvider);
    if (nameController.text.isEmpty) return false;
    if (birthdayController.text.isEmpty) return false;
    if (gender == null) return false;
    if (school == null) return false;

    if (nameController.text != profile.name) return true;
    if (birthdayController.text != (profile.birthday != null ? _dateFormat.format(profile.birthday!) : '')) return true;
    if (gender != profile.gender) return true;
    if (school != profile.school) return true;
    if (avatarId != profile.avatarId) return true;

    return false;
  }

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    nameController.text = profile.name ?? '';
    birthdayController.text = profile.birthday != null ? _dateFormat.format(profile.birthday!) : '';
    gender = profile.gender;
    school = profile.school;
    avatarId = profile.avatarId;

    nameController.addListener(() => setState(() {}));
    birthdayController.addListener(() => setState(() {}));
  }

  void editAvatar() async {
    final newAvatarId = await showModalBottomSheet<int>(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.bgText00,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 4,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColor.bgText500,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Выберите фото', style: AppStyle.subheader1.bgText900),
            const SizedBox(height: 13),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: List.generate(
                    AppSvg.avatars.length,
                    (index) => GestureDetector(
                      onTap: () => context.pop(index + 1),
                      child: AppSvg.avatars[index].svgPricture,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (newAvatarId == null) return;
    setState(() {
      avatarId = newAvatarId;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Редактирование профиля'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: AppGestureDetector(
                onTap: editAvatar,
                child: Stack(
                  children: [
                    Positioned.fill(child: AppAvatar(avatarId: avatarId, size: 100)),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: AppEditButton(onTap: editAvatar),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppInput(
            controller: nameController,
            label: 'Фамилия Имя',
            hintText: 'Фамилия Имя',
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: Validator.name,
          ),
          const SizedBox(height: 13),
          AppInputDateTime(
            controller: birthdayController,
            label: 'Дата рождения',
            hintText: 'дд.мм.гггг',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: Validator.birthday,
          ),
          const SizedBox(height: 13),
          AppRadioGroup<Gender>(
            label: 'Пол',
            value: gender,
            values: [
              AppRadioValue(value: Gender.male, label: Gender.male.label),
              AppRadioValue(value: Gender.female, label: Gender.female.label),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                gender = value;
              });
            },
          ),
          const SizedBox(height: 15),
          SchoolDropdown(
            school: school,
            onChanged: (val) => setState(() {
              school = val;
            }),
          ),
          const SizedBox(height: 20),
          AppButton(
            title: 'Сохранить',
            onTap: canSave
                ? () async {
                    try {
                      // Проверяем формат даты
                      if (!RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(birthdayController.text)) {
                        context.showErrorSnackBar('Введите корректную дату в формате дд.мм.гггг');
                        return;
                      }

                      // Парсим дату
                      DateTime? bday;
                      try {
                        bday = _dateFormat.parse(birthdayController.text);
                      } catch (e) {
                        context.showErrorSnackBar('Введите корректную дату в формате дд.мм.гггг');
                        return;
                      }

                      // Проверяем что дата не в будущем
                      if (bday.isAfter(DateTime.now())) {
                        context.showErrorSnackBar('Дата рождения не может быть в будущем');
                        return;
                      }

                      final res = await ref.read(profileProvider.notifier).updateProfile(
                            name: nameController.text,
                            birthday: bday,
                            gender: gender,
                            school: school,
                            avatarId: avatarId,
                          );

                      if (!context.mounted) return;
                      if (res) {
                        context.pop();
                      } else {
                        context.showErrorSnackBar('Ошибка сохранения профиля, проверьте подключение к интернету');
                      }
                    } catch (e) {
                      context.showErrorSnackBar('Ошибка: ${e.toString()}');
                    }
                  }
                : null,
          ),
          const SizedBox(height: 16),
          AppTextButton(
            title: 'Удалить аккаунт',
            color: AppColor.error,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColor.bgText00,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Удалить аккаунт?', style: AppStyle.subheader2.bgText900),
                        const SizedBox(height: 12),
                        Text(
                          'Пройденные маршруты и открытые\nместа будут потеряны.',
                          textAlign: TextAlign.center,
                          style: AppStyle.body.bgText900,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                title: 'Отмена',
                                style: AppButtonStyle.white,
                                onTap: () => context.pop(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                title: 'Удалить',
                                style: AppButtonStyle.primary,
                                onTap: () {
                                  context.pop();
                                  ref.read(authProvider.notifier).removeAccount();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
