import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class AppModal extends StatelessWidget {
  final Widget? icon;
  final String? title;
  final String? text;
  final List<Widget> actions;
  final Widget? footer;

  const AppModal({
    super.key,
    this.icon,
    this.title,
    this.text,
    required this.actions,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8), // уменьшил паддинг
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon!,
            if (title != null) ...[
              const Gap(12),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
            if (text != null) ...[
              const SizedBox(height: 12),
              Text(
                text!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const Gap(24),
            Row(
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) const Gap(8),
                  Expanded(child: actions[i]),
                ]
              ],
            ),
            if (footer != null) ...[
              const Gap(16),
              DefaultTextStyle(
                style: const TextStyle(fontSize: 11, color: Color(0xFF222222), fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showBuyHintModal(BuildContext context, {required int hintsLeft, required VoidCallback onBuy}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AppModal(
      icon: SvgPicture.asset('assets/svg/lamp.svg', width: 32, height: 32),
      title: 'Осталось $hintsLeft подсказки',
      text: 'Вы хотите купить 1 подсказку за 1 сускоин?',
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7F8FA),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Нет',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onBuy();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF466BFF),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Да',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    ),
  );
}

Future<void> showExitConfirmModal(BuildContext context, {required VoidCallback onExit}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AppModal(
      title: 'Вы действительно хотите выйти?',
      text: 'Вы не завершили квест, новое место не будет открыто',
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7F8FA),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Нет, остаюсь',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // выйти из экрана
            Navigator.of(context).maybePop(); // выйти из экрана
            onExit();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF466BFF),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Да',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    ),
  );
}

Future<void> showHintInfoModal(BuildContext context, {required String text, required int hintsLeft}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AppModal(
      icon: SvgPicture.asset('assets/svg/lamp.svg', width: 32, height: 32),
      text: text,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF466BFF),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Спасибо',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
      footer: Text('Осталось $hintsLeft подсказки', textAlign: TextAlign.center),
    ),
  );
}
