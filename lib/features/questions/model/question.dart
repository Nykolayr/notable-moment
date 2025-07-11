import 'question_type.dart';
import 'single_choice_question.dart';
import 'multiple_choice_question.dart';
import 'anagram_question.dart';
import 'order_question.dart';
import 'pair_question.dart';

abstract class Question {
  final String id;
  final String text;
  final QuestionType type;
  final int points;
  final String? hint;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.points = 1,
    this.hint,
  });

  Map<String, dynamic> toJson();
  Question copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
  });

  static Question fromJson(Map<String, dynamic> json) {
    final type = QuestionType.values.byName(json['type']);
    switch (type) {
      case QuestionType.singleChoice:
        return SingleChoiceQuestion.fromJson(json);
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion.fromJson(json);
      case QuestionType.anagram:
        return AnagramQuestion.fromJson(json);
      case QuestionType.order:
        return OrderQuestion.fromJson(json);
      case QuestionType.pair:
        return PairQuestion.fromJson(json);
    }
  }
}
