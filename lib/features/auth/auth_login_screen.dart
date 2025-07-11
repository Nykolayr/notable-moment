import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/helpers/validator.dart';
import 'package:notable_moments/core/provider/auth_provider.dart'; // ✅ путь и имя провайдера
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_text_button.dart';
import 'package:notable_moments/features/auth/auth_registration_screen.dart';
import 'package:notable_moments/features/auth/auth_reset_password_screen.dart';

class AuthLoginScreen extends ConsumerStatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  ConsumerState<AuthLoginScreen> createState() => _AuthEmailScreenState();
}

class _AuthEmailScreenState extends ConsumerState<AuthLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hasEmailError = true;
  bool hasPasswordError = true;

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateEmail);
    passwordController.addListener(validatePassword);
  }

  void validateEmail() {
    setState(() {
      hasEmailError = Validator.email(emailController.text) != null;
    });
  }

  void validatePassword() {
    setState(() {
      hasPasswordError = Validator.password(passwordController.text) != null;
    });
  }

  @override
  void dispose() {
    emailController.removeListener(validateEmail);
    passwordController.removeListener(validatePassword);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgText00,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              AppSvg.logo.svgPricture,
              const Spacer(),
              SizedBox(
                height: 72 + 72 + 28,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppInput(
                      controller: emailController,
                      label: 'Почта',
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: Validator.email,
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: passwordController,
                      label: 'Пароль',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      validator: Validator.password,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                title: 'Войти',
                onTap: (hasEmailError || hasPasswordError)
                    ? null
                    : () async {
                        final res = await ref
                            .read(authProvider.notifier) // ✅ исправлено и проверено имя
                            .signInWithEmailAndPassword(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                        if (res.isLeft && context.mounted) {
                          context.showErrorSnackBar(res.left);
                        }
                      },
              ),
              const SizedBox(height: 12),
              AppButton(
                title: 'Создать профиль',
                onTap: () {
                  context.push(const AuthRegistrationScreen());
                },
                style: AppButtonStyle.white,
              ),
              const Spacer(),
              AppTextButton(
                title: 'Забыли пароль?',
                color: AppColor.bgText900,
                onTap: () {
                  context.push(const AuthResetPasswordScreen());
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
