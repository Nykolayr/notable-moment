import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/helpers/validator.dart';
import 'package:notable_moments/core/provider/auth_provider.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';

class AuthResetPasswordScreen extends ConsumerStatefulWidget {
  const AuthResetPasswordScreen({super.key});

  @override
  ConsumerState<AuthResetPasswordScreen> createState() => _AuthResetPasswordScreenState();
}

class _AuthResetPasswordScreenState extends ConsumerState<AuthResetPasswordScreen> {
  final emailController = TextEditingController();
  bool hasEmailError = true;

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateEmail);
  }

  void validateEmail() {
    setState(() {
      hasEmailError = Validator.email(emailController.text) != null;
    });
  }

  @override
  void dispose() {
    emailController.removeListener(validateEmail);
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(
        title: 'Сброс пароля',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Введите адрес электронной почты, связанный с вашей учетной записью, и мы отправим вам инструкции по сбросу пароля.',
              style: TextStyle(color: AppColor.bgText900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppInput(
              controller: emailController,
              label: 'Почта',
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validator.email,
            ),
            const SizedBox(height: 20),
            AppButton(
              title: 'Отправить',
              onTap: hasEmailError
                  ? null
                  : () async {
                      final res = await ref.read(authProvider.notifier).sendPasswordResetEmail(emailController.text);

                      if (res.isLeft && context.mounted) {
                        context.showErrorSnackBar(res.left);
                      } else if (context.mounted) {
                        context.showSuccessSnackBar(
                          'Инструкции по сбросу пароля отправлены на вашу почту',
                        );
                        context.pop();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
