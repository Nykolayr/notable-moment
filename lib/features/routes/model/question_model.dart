import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionType {
  single,
  multiple,
  text,
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final List<String> correctAnswers;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswers,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      text: data['text'] ?? '',
      type: _typeFromString(data['type'] ?? 'single'),
      options: List<String>.from(data['options'] ?? []),
      correctAnswers: List<String>.from(data['correctAnswers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type.name,
      'options': options,
      'correctAnswers': correctAnswers,
    };
  }

  static QuestionType _typeFromString(String type) {
    switch (type) {
      case 'multiple':
        return QuestionType.multiple;
      case 'text':
        return QuestionType.text;
      case 'single':
      default:
        return QuestionType.single;
    }
  }
}

class AnsweredQuestion {
  final String questionId;
  final String questionText;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  AnsweredQuestion({
    required this.questionId,
    required this.questionText,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
    };
  }

  factory AnsweredQuestion.fromMap(Map<String, dynamic> map) {
    return AnsweredQuestion(
      questionId: map['questionId'] ?? '',
      questionText: map['questionText'] ?? '',
      userAnswer: map['userAnswer'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}
