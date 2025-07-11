import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/profile/widget/foldable_item.dart';

class ProfileFAQ extends StatefulWidget {
  const ProfileFAQ({super.key});

  @override
  State<ProfileFAQ> createState() => _ProfileFAQState();
}

class _ProfileFAQState extends State<ProfileFAQ> {
  @override
  Widget build(BuildContext context) {
    Widget text(String t) => Text(t, style: AppStyle.body.bgText900);
    Widget subh2(String t) => Text(t, style: AppStyle.subheader2.bgText900);

    return AppScaffold(
      appBar: AppAppBar(title: 'Часто задаваемые вопросы'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          FoldableItem(
            title: 'Что такое очки энергии? Как их пополнить?',
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                children: [
                  text(
                    'Очки энергии — это ресурс, который используется сусликом Валерой в процессе игры для перемещения по маршруту и выполнения заданий. ',
                  ),
                  const SizedBox(height: 12),
                  subh2('Пополнить очки энергии можно несколькими способами:'),
                  const SizedBox(height: 12),
                  text(
                    '1. Съедание пищи: Если Валера использует всю свою энергию, он не сможет выполнять никаких действий, пока не съест лакомства, которые пополняют его очки энергии. Лакомства можно купить за собранные сускойны.',
                  ),
                  const SizedBox(height: 12),
                  text(
                    '2. Заработок сускойнов: \n- Если ты заходишь в приложение семь дней подряд, на седьмой день получаешь сускойны, которые можешь потратить на лакомства для Валеры.',
                  ),
                  const SizedBox(height: 12),
                  text(
                    '  - При успешном решении задания с первой попытки ты получаешь сускойны и сохраняешь очки энергии. Если ответ неправильный, очки энергии отнимаются за каждую попытку. ',
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
