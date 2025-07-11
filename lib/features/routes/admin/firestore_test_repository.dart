// lib/features/routes/admin/firestore_test_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/question.dart';

class FirestoreTestRepository {
  final _firestore = FirebaseFirestore.instance;

  /// Загружает список вопросов из саб-коллекции tests/{testId}/questions
  Future<List<Question>> fetchQuestions(String testId) async {
    final questionsSnapshot = await _firestore
        .collection('tests')
        .doc(testId)
        .collection('questions')
        .orderBy('order', descending: false)
        .get();

    return questionsSnapshot.docs.map((doc) => Question.fromJson(doc.data()..['id'] = doc.id)).toList();
  }

  /// Загружает мета-данные теста: title, description и др.
  Future<Map<String, dynamic>?> fetchTestMeta(String testId) async {
    final doc = await _firestore.collection('tests').doc(testId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Сохраняет вопросы в саб-коллекцию tests/{testId}/questions
  Future<void> saveQuestions(String testId, List<Question> questions) async {
    final batch = _firestore.batch();
    final questionsCollection = _firestore.collection('tests').doc(testId).collection('questions');

    for (var question in questions) {
      final docRef = questionsCollection.doc(question.id.isEmpty ? null : question.id);
      batch.set(docRef, question.toJson(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Удаляет тест и все вопросы из саб-коллекции
  Future<void> deleteTest(String testId) async {
    final questionsSnapshot = await _firestore.collection('tests').doc(testId).collection('questions').get();

    final batch = _firestore.batch();

    for (var doc in questionsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestore.collection('tests').doc(testId));

    await batch.commit();
  }
}
