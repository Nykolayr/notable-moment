import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/helpers/validator.dart';
import 'package:notable_moments/core/provider/auth_provider.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_checkbox.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';

class AuthRegistrationScreen extends ConsumerStatefulWidget {
  const AuthRegistrationScreen({super.key});

  @override
  ConsumerState<AuthRegistrationScreen> createState() => _AuthCreateProfileScreenState();
}

class _AuthCreateProfileScreenState extends ConsumerState<AuthRegistrationScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isPrivacyConsentChecked = false;

  bool hasEmailError = false;
  bool hasPasswordError = false;
  bool hasConfirmPasswordError = false;

  bool get hasError => hasEmailError || hasPasswordError || hasConfirmPasswordError;

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateEmail);
    passwordController.addListener(validatePassword);
    confirmPasswordController.addListener(validateConfirmPassword);
  }

  void validateEmail() {
    setState(() {
      hasEmailError = Validator.email(emailController.text) != null;
    });
  }

  void validatePassword() {
    setState(() {
      hasPasswordError = Validator.password(passwordController.text) != null;
      // Also validate confirm password when password changes
      if (confirmPasswordController.text.isNotEmpty) {
        hasConfirmPasswordError =
            Validator.confirmPassword(confirmPasswordController.text, passwordController.text) != null;
      }
    });
  }

  void validateConfirmPassword() {
    setState(() {
      hasConfirmPasswordError =
          Validator.confirmPassword(confirmPasswordController.text, passwordController.text) != null;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      singleSpageScrollable: true,
      appBar: AppAppBar(title: 'Создание профиля'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Spacer(flex: 2),
            AppInput(
              controller: emailController,
              label: 'Почта',
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validator.email,
            ),
            const SizedBox(height: 13),
            AppInput(
              controller: passwordController,
              label: 'Пароль',
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validator.password,
            ),
            const SizedBox(height: 13),
            AppInput(
              controller: confirmPasswordController,
              label: 'Подтверждение пароля',
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => Validator.confirmPassword(value, passwordController.text),
            ),
            const SizedBox(height: 26),
            AppCheckbox(
              value: isPrivacyConsentChecked,
              title: 'Я согласен на обработку персональных данных',
              onChange: (value) => setState(() => isPrivacyConsentChecked = value),
            ),
            const SizedBox(height: 15),
            AppButton(
              title: 'Продолжить',
              onTap: !isPrivacyConsentChecked || hasError
                  ? null
                  : () async {
                      final res = await ref.read(authProvider.notifier).registerWithEmailAndPassword(
                            emailController.text,
                            passwordController.text,
                          );

                      if (res.isLeft && context.mounted) {
                        context.showErrorSnackBar(res.left);
                      }
                    },
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
