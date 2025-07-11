// lib/features/routes/admin/question.dart

enum QuestionType {
  single,
  multiple,
  text,
  pair,
}

class Question2 {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final List<int> correctIndexes;
  final String correctAnswerText;

  Question2({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctIndexes,
    required this.correctAnswerText,
  });

  /// Десериализация из Firestore
  factory Question2.fromJson(Map<String, dynamic> json) {
    return Question2(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      type: _parseQuestionType(json['type']),
      options: json['options'] != null ? List<String>.from(json['options']) : <String>[],
      correctIndexes: json['correctIndexes'] != null ? List<int>.from(json['correctIndexes']) : <int>[],
      correctAnswerText: json['correctAnswerText'] ?? '',
    );
  }

  /// Сериализация в JSON (если нужно)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'options': options,
      'correctIndexes': correctIndexes,
      'correctAnswerText': correctAnswerText,
    };
  }
}

/// Вспомогательная функция для парсинга типа вопроса из строки
QuestionType _parseQuestionType(String? type) {
  switch (type) {
    case 'single':
      return QuestionType.single;
    case 'multiple':
      return QuestionType.multiple;
    case 'text':
      return QuestionType.text;
    case 'pair':
      return QuestionType.pair;
    default:
      return QuestionType.single;
  }
}
