import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/add_type_question/single_choice_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/multiple_choice_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/anagram_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/order_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/match_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/general_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/true_false_editor.dart';
import 'package:notable_moments/features/questions/add_type_question/sentence_order_editor.dart';
import 'package:notable_moments/features/questions/page_type_question/single_choice_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/multiple_choice_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/anagram_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/order_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/pair_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/general_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/true_false_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/sentence_order_test_widget.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'package:notable_moments/features/questions/model/anagram_question.dart';
import 'package:notable_moments/features/questions/model/order_question.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';
import 'package:notable_moments/features/questions/model/general_question.dart';
import 'package:notable_moments/features/questions/model/true_false_question.dart';
import 'package:notable_moments/features/questions/model/sentence_order_question.dart';

enum QuestionTypeTest {
  singleChoice(
    title: 'Один вариант',
    icon: Icons.radio_button_checked,
    text: 'Выбери один правильный вариант ответа.',
  ),
  multipleChoice(
    title: 'Несколько вариантов',
    icon: Icons.check_box,
    text: 'Выбери несколько правильных вариантов ответа.',
  ),
  anagram(
    title: 'Анаграмма',
    icon: Icons.text_fields,
    text: 'Перетащи буквы в их правильные позиции..',
  ),
  order(
    title: 'Расположи по порядку',
    icon: Icons.format_list_numbered,
    text: 'Расположи предметы в правильном порядке.',
  ),
  pair(
    title: 'Найди пару',
    icon: Icons.link,
    text: 'Найди пару.',
  ),
  general(
    title: 'Общий вопрос',
    icon: Icons.help_outline,
    text: 'Выбери правильный вариант ответа.',
  ),
  trueFalse(
    title: 'Правда/Ложь',
    icon: Icons.check,
    text: 'Выбери правильный вариант ответа.',
  ),
  sentenceOrder(
    title: 'Порядок слов',
    icon: Icons.format_line_spacing,
    text: 'Расположи предметы в правильном порядке.',
  );

  final String title;
  final IconData icon;
  final String text;

  const QuestionTypeTest({required this.title, required this.icon, required this.text});
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

  Widget buildTestWidget(
    QuestionTest test, {
    required void Function(bool, List<int>) onAnswered,
    void Function(bool, List<String>)? onAnagramAnswered,
    List<int> selectedIndexes = const [],
    List<String?>? userAnswer,
    List<String>? bank,
    void Function(int fromRow, int fromIdx, int toRow, int toIdx)? onMove,
    bool showResult = false,
    bool? isCorrect,
    List<int>? wrongIndexes,
    void Function(List<int>)? onSelectionChanged,
  }) {
    switch (this) {
      case QuestionTypeTest.singleChoice:
        return SingleChoiceTestWidget(
          question: test as SingleChoiceQuestion,
          onAnswered: onAnswered,
          selectedIndexes: selectedIndexes,
          showResult: showResult,
          isCorrect: isCorrect,
          wrongIndexes: wrongIndexes,
        );
      case QuestionTypeTest.multipleChoice:
        return MultipleChoiceTestWidget(
          question: test as MultipleChoiceQuestion,
          onAnswered: onAnswered,
          selectedIndexes: selectedIndexes,
          showResult: showResult,
          isCorrect: isCorrect,
          wrongIndexes: wrongIndexes,
          onSelectionChanged: onSelectionChanged,
        );
      case QuestionTypeTest.anagram:
        return AnagramTestWidget(
          question: test as AnagramQuestion,
          userAnswer: userAnswer!,
          bank: bank!,
          onMove: onMove,
          showResult: showResult,
          isCorrect: isCorrect,
        );
      case QuestionTypeTest.order:
        return OrderTestWidget(question: test as OrderQuestion);
      case QuestionTypeTest.pair:
        return PairTestWidget(question: test as PairQuestion);
      case QuestionTypeTest.general:
        return GeneralTestWidget(
          question: test as GeneralQuestion,
          onAnswered: onAnswered,
          onSelectionChanged: onSelectionChanged,
          selectedIndexes: selectedIndexes,
          showResult: showResult,
          isCorrect: isCorrect,
          wrongIndexes: wrongIndexes,
        );
      case QuestionTypeTest.trueFalse:
        return TrueFalseTestWidget(
          question: test as TrueFalseQuestion,
          onAnswered: onAnswered,
          onSelectionChanged: onSelectionChanged,
          selectedIndexes: selectedIndexes,
          showResult: showResult,
          isCorrect: isCorrect,
          wrongIndexes: wrongIndexes,
        );
      case QuestionTypeTest.sentenceOrder:
        return SentenceOrderTestWidget(question: test as SentenceOrderQuestion);
    }
  }
}
