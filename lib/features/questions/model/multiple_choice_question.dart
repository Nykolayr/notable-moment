import 'question.dart';
import 'question_type.dart';

class MultipleChoiceQuestion extends QuestionTest {
  final List<String> options;
  final List<int> correctIndexes;

  MultipleChoiceQuestion({
    required super.id,
    required super.text,
    required this.options,
    required this.correctIndexes,
    super.points,
    super.hint,
  }) : super(
          type: QuestionTypeTest.multipleChoice,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'points': points,
        'hint': hint,
        'options': options,
        'correctIndexes': correctIndexes,
      };

  static MultipleChoiceQuestion fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctIndexes: List<int>.from(json['correctIndexes']),
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  MultipleChoiceQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    List<String>? options,
    List<int>? correctIndexes,
  }) {
    return MultipleChoiceQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndexes: correctIndexes ?? this.correctIndexes,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
