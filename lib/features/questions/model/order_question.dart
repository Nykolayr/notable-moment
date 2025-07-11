import 'question.dart';
import 'question_type.dart';

class OrderQuestion extends Question {
  final List<String> items;
  final List<int> correctOrder;

  OrderQuestion({
    required super.id,
    required super.text,
    required this.items,
    required this.correctOrder,
    super.points,
    super.hint,
  }) : super(
          type: QuestionType.order,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'points': points,
        'hint': hint,
        'items': items,
        'correctOrder': correctOrder,
      };

  static OrderQuestion fromJson(Map<String, dynamic> json) {
    return OrderQuestion(
      id: json['id'],
      text: json['text'],
      items: List<String>.from(json['items']),
      correctOrder: List<int>.from(json['correctOrder']),
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  OrderQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    List<String>? items,
    List<int>? correctOrder,
  }) {
    return OrderQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      items: items ?? this.items,
      correctOrder: correctOrder ?? this.correctOrder,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
