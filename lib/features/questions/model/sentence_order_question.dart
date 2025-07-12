

import 'question.dart';
import 'question_type.dart';

/// SentenceOrderQuestion
///
/// Модель для вопроса "Приведи в порядок" (слова в предложении).
/// Используется для вопросов, где требуется расставить слова в правильном порядке для составления предложения.
/// Наследник QuestionTest.
class SentenceOrderQuestion extends QuestionTest {
  final List<String> words;
  final List<int> correctOrder;

  SentenceOrderQuestion({
    required super.id,
    required super.text,
    required this.words,
    required this.correctOrder,
    super.points,
    super.hint,
  }) : super(type: QuestionTypeTest.sentenceOrder);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'points': points,
        'hint': hint,
        'words': words,
        'correctOrder': correctOrder,
      };

  static SentenceOrderQuestion fromJson(Map<String, dynamic> json) {
    return SentenceOrderQuestion(
      id: json['id'],
      text: json['text'],
      words: List<String>.from(json['words']),
      correctOrder: List<int>.from(json['correctOrder']),
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  SentenceOrderQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    List<String>? words,
    List<int>? correctOrder,
  }) {
    return SentenceOrderQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      words: words ?? this.words,
      correctOrder: correctOrder ?? this.correctOrder,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
