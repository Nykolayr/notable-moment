

import 'question.dart';
import 'question_type.dart';

/// GeneralQuestion
///
/// Модель для общего вопроса с двумя вариантами ответа (например, Да/Нет).
/// Используется для вопросов, где требуется выбрать один из двух простых вариантов.
/// Наследник QuestionTest.
class GeneralQuestion extends QuestionTest {
  final List<String> options;
  final int correctIndex;

  GeneralQuestion({
    required super.id,
    required super.text,
    required this.options,
    required this.correctIndex,
    super.points,
    super.hint,
  }) : super(type: QuestionTypeTest.general);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'points': points,
        'hint': hint,
        'options': options,
        'correctIndex': correctIndex,
      };

  static GeneralQuestion fromJson(Map<String, dynamic> json) {
    return GeneralQuestion(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  GeneralQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    List<String>? options,
    int? correctIndex,
  }) {
    return GeneralQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
