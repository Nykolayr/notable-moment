import 'question.dart';
import 'question_type.dart';

class AnagramQuestion extends Question {
  final String answer;
  final List<String> letters;

  AnagramQuestion({
    required super.id,
    required super.text,
    required this.answer,
    required this.letters,
    super.points,
    super.hint,
  }) : super(
          type: QuestionType.anagram,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'points': points,
        'hint': hint,
        'answer': answer,
        'letters': letters,
      };

  static AnagramQuestion fromJson(Map<String, dynamic> json) {
    return AnagramQuestion(
      id: json['id'],
      text: json['text'],
      answer: json['answer'],
      letters: List<String>.from(json['letters']),
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  AnagramQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    String? answer,
    List<String>? letters,
  }) {
    return AnagramQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      answer: answer ?? this.answer,
      letters: letters ?? this.letters,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
