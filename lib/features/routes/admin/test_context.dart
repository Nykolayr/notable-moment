// lib/features/routes/admin/test_context.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Типы вопросов
enum QuestionType { single, multiple, text, pair }

/// Расширение: Человеческий label для UI
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
      orElse: () => QuestionType.text,
    );
  }
}

/// Модель пары для 'pair'
class PairModel {
  String left;
  String right;

  PairModel({this.left = '', this.right = ''});

  Map<String, dynamic> toMap() => {
        'left': left,
        'right': right,
      };

  factory PairModel.fromMap(Map<String, dynamic> map) => PairModel(
        left: map['left'] ?? '',
        right: map['right'] ?? '',
      );
}

/// Модель вопроса
class Question {
  QuestionType type;
  String text;
  List<String> options;
  String correctAnswer; // single, multiple, text
  List<PairModel> pairs; // pair

  Question({
    required this.type,
    required this.text,
    required this.options,
    required this.correctAnswer,
    this.pairs = const [],
  });

  Set<int> get correctIndexes {
    final parts = correctAnswer.split(',');
    return parts.map((e) => int.tryParse(e.trim())).whereType<int>().toSet();
  }

  String get correctAnswerText => correctAnswer.trim().toLowerCase();

  /// Проверка правильности ответа
  bool isCorrect({
    dynamic userAnswer,
  }) {
    switch (type) {
      case QuestionType.single:
        if (userAnswer == null) return false;
        return userAnswer.toString() == correctAnswer;
      case QuestionType.multiple:
        if (userAnswer == null || userAnswer is! Set<int>) return false;
        return userAnswer.length == correctIndexes.length && userAnswer.containsAll(correctIndexes);
      case QuestionType.text:
        if (userAnswer == null || userAnswer.toString().trim().isEmpty) {
          return false;
        }
        return userAnswer.toString().trim().toLowerCase() == correctAnswerText;
      case QuestionType.pair:
        if (userAnswer == null || userAnswer is! List<PairModel>) return false;
        if (userAnswer.length != pairs.length) return false;
        for (final pair in pairs) {
          final match = userAnswer.any((p) =>
              p.left.trim().toLowerCase() == pair.left.trim().toLowerCase() &&
              p.right.trim().toLowerCase() == pair.right.trim().toLowerCase(),);
          if (!match) return false;
        }
        return true;
    }
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'text': text,
        'options': options,
        'correctAnswer': correctAnswer,
        'pairs': pairs.map((p) => p.toMap()).toList(),
      };

  factory Question.fromMap(Map<String, dynamic> map) => Question(
        type: QuestionTypeLabel.fromName(map['type'] ?? 'text'),
        text: map['text'] ?? '',
        options: List<String>.from(map['options'] ?? []),
        correctAnswer: map['correctAnswer'] ?? '',
        pairs: map['pairs'] != null
            ? List<Map<String, dynamic>>.from(map['pairs']).map((p) => PairModel.fromMap(p)).toList()
            : [],
      );

  Question clone() => Question(
        type: type,
        text: text,
        options: List<String>.from(options),
        correctAnswer: correctAnswer,
        pairs: pairs.map((p) => PairModel(left: p.left, right: p.right)).toList(),
      );
}

/// StateNotifier для управления тестом
class TestNotifier extends StateNotifier<List<Question>> {
  TestNotifier() : super([]);

  void setQuestions(List<Question> questions) {
    state = questions;
  }

  void addQuestion(Question question) {
    state = [...state, question];
  }

  void updateQuestion(int index, Question updated) {
    final list = [...state];
    list[index] = updated;
    state = list;
  }

  void removeQuestion(int index) {
    final list = [...state]..removeAt(index);
    state = list;
  }

  void clear() {
    state = [];
  }
}

/// Провайдер для использования в UI
final testProvider = StateNotifierProvider<TestNotifier, List<Question>>(
  (ref) => TestNotifier(),
);

/// Firestore repository для тестов
class FirestoreTestRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Question>> fetchQuestions(String testId) async {
    final snap = await _db.collection('tests').doc(testId).collection('questions').get();
    return snap.docs.map((doc) => Question.fromMap(doc.data())).toList();
  }

  Future<void> saveQuestion(
    String testId,
    Question question, {
    String? questionId,
  }) async {
    final ref = _db.collection('tests').doc(testId).collection('questions').doc(questionId);
    await ref.set(question.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteQuestion(String testId, String questionId) async {
    await _db.collection('tests').doc(testId).collection('questions').doc(questionId).delete();
  }

  Future<Map<String, dynamic>?> fetchTestMeta(String testId) async {
    final doc = await _db.collection('tests').doc(testId).get();
    return doc.data();
  }

  Future<void> saveTestMeta(
    String testId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('tests').doc(testId).set(data, SetOptions(merge: true));
  }
}
