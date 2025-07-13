import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/add_type_question/single_choice_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/multiple_choice_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/anagram_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/order_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/match_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/general_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/true_false_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/sentence_order_editor.dart';

enum QuestionTypeTest {
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
  ),
  general(
    title: 'Общий вопрос',
    icon: Icons.help_outline,
  ),
  trueFalse(
    title: 'Правда/Ложь',
    icon: Icons.check,
  ),
  sentenceOrder(
    title: 'Порядок слов',
    icon: Icons.format_line_spacing,
  );

  final String title;
  final IconData icon;

  const QuestionTypeTest({required this.title, required this.icon});
}

extension QuestionTypeTestExt on QuestionTypeTest {
  Widget buildEditor({
    required dynamic initial,
    required void Function(dynamic data, bool isValid) onChanged,
  }) {
    switch (this) {
      case QuestionTypeTest.singleChoice:
        return SingleChoiceEditor(initial: initial, onChanged: onChanged);
      case QuestionTypeTest.multipleChoice:
        return MultipleChoiceEditor(initial: initial, onChanged: onChanged);
      case QuestionTypeTest.anagram:
        return AnagramEditor(initial: initial, onChanged: onChanged);
      case QuestionTypeTest.order:
        return OrderEditor(initial: initial, onChanged: onChanged);
      case QuestionTypeTest.pair:
        return MatchEditor(initial: initial, onChanged: onChanged);
      case QuestionTypeTest.general:
        return GeneralEditor(initial: initial, onChanged: onChanged);
      case QuestionTypeTest.trueFalse:
        return TrueFalseEditor(initial: initial, onChanged: onChanged);
      case QuestionTypeTest.sentenceOrder:
        return SentenceOrderEditor(initial: initial, onChanged: onChanged);
    }
  }
}
