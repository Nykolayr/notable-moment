import 'package:flutter/material.dart';

enum QuestionType {
  singleChoice(
    title: 'Один вариант',
    icon: Icons.radio_button_checked,
  ),
  multipleChoice(
    title: 'Несколько вариантов',
    icon: Icons.check_box,
  ),
  anagram(
    title: 'Анаграмма',
    icon: Icons.text_fields,
  ),
  order(
    title: 'Расположи по порядку',
    icon: Icons.format_list_numbered,
  ),
  pair(
    title: 'Найди пару',
    icon: Icons.link,
  );

  final String title;
  final IconData icon;

  const QuestionType({required this.title, required this.icon});
}
