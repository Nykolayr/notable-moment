

import 'question.dart';
import 'question_type.dart';

/// TrueFalseQuestion
///
/// Модель для вопроса "Правда/Ложь".
/// Используется для вопросов, где требуется выбрать между двумя фиксированными вариантами: Правда или Ложь.
/// Наследник QuestionTest.
class TrueFalseQuestion extends QuestionTest {
  final bool correct;

  TrueFalseQuestion({
    required super.id,
    required super.text,
    required this.correct,
    super.points,
    super.hint,
  }) : super(type: QuestionTypeTest.trueFalse);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'points': points,
        'hint': hint,
        'correct': correct,
      };

  static TrueFalseQuestion fromJson(Map<String, dynamic> json) {
    return TrueFalseQuestion(
      id: json['id'],
      text: json['text'],
      correct: json['correct'],
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  TrueFalseQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    bool? correct,
  }) {
    return TrueFalseQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      correct: correct ?? this.correct,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
