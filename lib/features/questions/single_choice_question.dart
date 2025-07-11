import 'question.dart';
import 'question_type.dart';

class SingleChoiceQuestion extends Question {
  final List<String> options;
  final int correctIndex;

  SingleChoiceQuestion({
    required super.id,
    required super.text,
    required this.options,
    required this.correctIndex,
    super.points,
    super.hint,
  }) : super(
          type: QuestionType.singleChoice,
        );

  static SingleChoiceQuestion init() => SingleChoiceQuestion(
        id: 'empty',
        text: '',
        options: const [],
        correctIndex: 0,
      );

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

  static SingleChoiceQuestion fromJson(Map<String, dynamic> json) {
    return SingleChoiceQuestion(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  SingleChoiceQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    List<String>? options,
    int? correctIndex,
  }) {
    return SingleChoiceQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
