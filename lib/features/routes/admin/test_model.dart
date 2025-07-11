// lib/features/routes/admin/test_model.dart

/// Типы вопросов
enum QuestionType { single, multiple, text, pair }

/// Расширение для получения читаемой метки
extension QuestionTypeLabel on QuestionType {
  String get label {
    switch (this) {
      case QuestionType.single:
        return 'Один вариант';
      case QuestionType.multiple:
        return 'Несколько вариантов';
      case QuestionType.text:
        return 'Текстовый';
      case QuestionType.pair:
        return 'Найди пару';
    }
  }

  String get name => toString().split('.').last;

  static QuestionType fromName(String name) {
    return QuestionType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => QuestionType.single,
    );
  }
}

/// Модель пары для типа 'pair'
class Pair {
  final String left;
  final String right;

  Pair({required this.left, required this.right});

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'right': right,
    };
  }

  factory Pair.fromJson(Map<String, dynamic> json) {
    return Pair(
      left: json['left'] as String? ?? '',
      right: json['right'] as String? ?? '',
    );
  }
}

/// Модель вопроса
class Question {
  final QuestionType type;
  final String text;
  final List<String> options;

  /// Для одиночного/текстового: строка
  /// Для множественного: индексы через запятую
  /// Для пар: пары идут отдельно
  final String correctAnswerText;

  /// Для типа 'pair'
  final List<Pair>? pairs;

  Question({
    required this.type,
    required this.text,
    required this.options,
    required this.correctAnswerText,
    this.pairs,
  });

  /// Для single/multiple
  Set<int> get correctIndexes {
    final parts = correctAnswerText.split(',');
    return parts.map((e) => int.tryParse(e.trim())).whereType<int>().toSet();
  }

  /// Для text
  String get correctText => correctAnswerText.trim().toLowerCase();

  /// Проверка правильности ответа
  bool checkAnswer({
    String? userText,
    Set<int>? userIndexes,
    List<Pair>? userPairs,
  }) {
    switch (type) {
      case QuestionType.single:
        return userIndexes != null && userIndexes.length == 1 && correctIndexes.contains(userIndexes.first);
      case QuestionType.multiple:
        return userIndexes != null &&
            userIndexes.isNotEmpty &&
            correctIndexes.length == userIndexes.length &&
            correctIndexes.containsAll(userIndexes);
      case QuestionType.text:
        return userText?.trim().toLowerCase() == correctText;
      case QuestionType.pair:
        if (pairs == null || userPairs == null) return false;
        if (pairs!.length != userPairs.length) return false;

        // Проверка: все пары должны совпасть
        for (final pair in pairs!) {
          final match = userPairs.any((p) =>
              p.left.trim().toLowerCase() == pair.left.trim().toLowerCase() &&
              p.right.trim().toLowerCase() == pair.right.trim().toLowerCase(),);
          if (!match) return false;
        }
        return true;
    }
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'text': text,
      'options': options,
      'correctAnswerText': correctAnswerText,
      'pairs': pairs?.map((p) => p.toJson()).toList(),
    };
  }

  /// Десериализация из JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: QuestionTypeLabel.fromName(json['type'] as String),
      text: json['text'] as String,
      options: List<String>.from(json['options'] ?? []),
      correctAnswerText: json['correctAnswerText'] as String,
      pairs: (json['pairs'] as List<dynamic>?)?.map((p) => Pair.fromJson(p as Map<String, dynamic>)).toList(),
    );
  }
}

/// Модель теста
class TestModel {
  final String id;
  final String title;
  final List<Question> questions;
  final bool isPassed;

  TestModel({
    required this.id,
    required this.title,
    List<Question>? questions,
    this.isPassed = false,
  }) : questions = questions ?? [];

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((e) => e.toJson()).toList(),
      'isPassed': isPassed,
    };
  }

  /// Десериализация из JSON
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      questions:
          (json['questions'] as List<dynamic>?)?.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList() ??
              [],
      isPassed: json['isPassed'] as bool? ?? false,
    );
  }

  /// Обновление флага прохождения
  TestModel copyWith({bool? isPassed}) {
    return TestModel(
      id: id,
      title: title,
      questions: questions,
      isPassed: isPassed ?? this.isPassed,
    );
  }
}
