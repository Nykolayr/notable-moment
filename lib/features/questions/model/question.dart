import 'package:notable_moments/features/questions/model/general_question.dart';
import 'package:notable_moments/features/questions/model/sentence_order_question.dart';
import 'package:notable_moments/features/questions/model/true_false_question.dart';

import 'question_type.dart';
import 'single_choice_question.dart';
import 'multiple_choice_question.dart';
import 'anagram_question.dart';
import 'order_question.dart';
import 'pair_question.dart';

abstract class QuestionTest {
  final String id;
  final String text;
  final QuestionTypeTest type;
  final int points;
  final String? hint;

  QuestionTest({
    required this.id,
    required this.text,
    required this.type,
    this.points = 1,
    this.hint,
  });

  Map<String, dynamic> toJson();
  QuestionTest copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
  });

  static QuestionTest fromJson(Map<String, dynamic> json) {
    final type = QuestionTypeTest.values.byName(json['type']);
    switch (type) {
      case QuestionTypeTest.singleChoice:
        return SingleChoiceQuestion.fromJson(json);
      case QuestionTypeTest.multipleChoice:
        return MultipleChoiceQuestion.fromJson(json);
      case QuestionTypeTest.anagram:
        return AnagramQuestion.fromJson(json);
      case QuestionTypeTest.order:
        return OrderQuestion.fromJson(json);
      case QuestionTypeTest.pair:
        return PairQuestion.fromJson(json);
      case QuestionTypeTest.general:
        return GeneralQuestion.fromJson(json);
      case QuestionTypeTest.trueFalse:
        return TrueFalseQuestion.fromJson(json);
      case QuestionTypeTest.sentenceOrder:
        return SentenceOrderQuestion.fromJson(json);
    }
  }
}
