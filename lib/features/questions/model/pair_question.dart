import 'question.dart';
import 'question_type.dart';

class Pair {
  final String left;
  final String right;
  Pair({required this.left, required this.right});

  Map<String, dynamic> toJson() => {
        'left': left,
        'right': right,
      };

  static Pair fromJson(Map<String, dynamic> json) => Pair(
        left: json['left'],
        right: json['right'],
      );

  Pair copyWith({String? left, String? right}) => Pair(
        left: left ?? this.left,
        right: right ?? this.right,
      );
}

class PairQuestion extends QuestionTest {
  final List<Pair> pairs;
  final List<Pair> correctPairs;

  PairQuestion({
    required super.id,
    required super.text,
    required this.pairs,
    required this.correctPairs,
    super.points,
    super.hint,
  }) : super(
          type: QuestionTypeTest.pair,
        );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type.name,
        'points': points,
        'hint': hint,
        'pairs': pairs.map((e) => e.toJson()).toList(),
        'correctPairs': correctPairs.map((e) => e.toJson()).toList(),
      };

  static PairQuestion fromJson(Map<String, dynamic> json) {
    return PairQuestion(
      id: json['id'],
      text: json['text'],
      pairs: (json['pairs'] as List).map((e) => Pair.fromJson(e)).toList(),
      correctPairs: (json['correctPairs'] as List).map((e) => Pair.fromJson(e)).toList(),
      points: json['points'] ?? 1,
      hint: json['hint'],
    );
  }

  @override
  PairQuestion copyWith({
    String? id,
    String? text,
    int? points,
    String? hint,
    List<Pair>? pairs,
    List<Pair>? correctPairs,
  }) {
    return PairQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      pairs: pairs ?? this.pairs,
      correctPairs: correctPairs ?? this.correctPairs,
      points: points ?? this.points,
      hint: hint ?? this.hint,
    );
  }
}
