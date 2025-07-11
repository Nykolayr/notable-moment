import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserTestRepository {
  final _firestore = FirebaseFirestore.instance;

  /// Сохраняет прогресс прохождения теста
  Future<void> saveUserTestProgress({
    required String userId,
    required String testId,
    required String pointId,
    required int score,
    required int maxScore,
    required List<Map<String, dynamic>> answers,
  }) async {
    await _firestore.collection('user_tests').doc('${userId}_$testId').set({
      'userId': userId,
      'testId': testId,
      'pointId': pointId,
      'score': score,
      'maxScore': maxScore,
      'answers': answers,
      'passedAt': Timestamp.now(),
    }, SetOptions(merge: true),);
  }

  /// Загружает прогресс прохождения теста
  Future<Map<String, dynamic>?> getUserTestProgress({
    required String userId,
    required String testId,
  }) async {
    final doc = await _firestore.collection('user_tests').doc('${userId}_$testId').get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Разблокировка следующей точки пользователю
  Future<void> unlockNextPoint({
    required String userId,
    required String pointId,
  }) async {
    await _firestore
        .collection('profile')
        .doc(userId)
        .collection('available_points')
        .doc(pointId)
        .set({'unlocked': true}, SetOptions(merge: true));
  }
}
