enum QuestionType { single, multiple, text }

class QuestionOld {
  final String id;
  final QuestionType type;
  final String text;
  final List<String> options;
  final List<int> correctIndexes; // ✅ добавлено
  final String correctAnswer; // для текстовых

  QuestionOld({
    required this.id,
    required this.type,
    required this.text,
    required this.options,
    required this.correctIndexes,
    required this.correctAnswer,
  });

  factory QuestionOld.fromJson(Map<String, dynamic> json) {
    return QuestionOld(
      id: json['id'] ?? '',
      type: _parseType(json['type'] ?? 'single'),
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndexes: List<int>.from(json['correctIndexes'] ?? []), // ✅ добавлено
      correctAnswer: json['correctAnswer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      'options': options,
      'correctIndexes': correctIndexes,
      'correctAnswer': correctAnswer,
    };
  }

  static QuestionType _parseType(String type) {
    switch (type) {
      case 'multiple':
        return QuestionType.multiple;
      case 'text':
        return QuestionType.text;
      default:
        return QuestionType.single;
    }
  }
}
