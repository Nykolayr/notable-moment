import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/constant/enum/gender_enum.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/helpers/validator.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_input_datetime.dart';
import 'package:notable_moments/core/widget/app_radio_group.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/global/widget/school_dropdown.dart';
import 'package:notable_moments/features/profile/model/status_enum.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';

class AuthFillProfileScreen extends ConsumerStatefulWidget {
  const AuthFillProfileScreen({super.key});

  @override
  ConsumerState<AuthFillProfileScreen> createState() => _AuthCreateProfileScreenState();
}

class _AuthCreateProfileScreenState extends ConsumerState<AuthFillProfileScreen> {
  final nameController = TextEditingController();
  final birthdayController = TextEditingController();
  Gender? gender;
  String? school;

  bool get canGoNext =>
      nameController.text.isNotEmpty && birthdayController.text.isNotEmpty && gender != null && school != null;

  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    ref.listen(
      profileProvider,
      (previous, profileState) {
        if (profileState.status == Status.loaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            nameController.text = ref.read(profileProvider).name ?? '';
            birthdayController.text = ref.read(profileProvider).birthday?.toIso8601String() ?? '';
            gender = ref.read(profileProvider).gender;
            school = ref.read(profileProvider).school;
            setState(() {});
          });
        }
      },
    );
    return AppScaffold(
      appBar: profileState.isRegistration ? AppAppBar(title: 'Создание профиля') : null,
      singleSpageScrollable: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: context.mediaQuery.size.height -
              context.safeArea.bottom -
              context.safeArea.top -
              (profileState.isRegistration ? AppAppBar.height : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              Text('Заполни информацию о себе', style: AppStyle.subheader2.bgText900),
              const SizedBox(height: 24),
              AppInput(
                controller: nameController,
                label: 'Фамилия Имя',
                hintText: 'Фамилия Имя',
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: Validator.name,
              ),
              const SizedBox(height: 13),
              AppInputDateTime(
                controller: birthdayController,
                label: 'Дата рождения',
                hintText: 'дд.мм.гггг',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => null,
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
              const Spacer(),
              const SizedBox(height: 20),
              AppButton(
                title: 'Продолжить',
                onTap: !canGoNext
                    ? null
                    : () async {
                        final birthday = DateTime.parse(birthdayController.text.split('.').reversed.join('-'));
                        await ref.read(profileProvider.notifier).updateProfile(
                              name: nameController.text,
                              birthday: birthday,
                              gender: gender!,
                              school: school!,
                              avatarId: 1,
                            );
                      },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
