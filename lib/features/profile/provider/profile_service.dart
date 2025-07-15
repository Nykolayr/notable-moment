import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/constant/enum/gender_enum.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

class ProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Загружает профиль пользователя из Firestore
  Future<Map<String, dynamic>?> loadProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('profile').doc(userId).get();
      return doc.data();
    } catch (e) {
      Logger.e('Error loading profile: $e');
      return null;
    }
  }

  /// Сохраняет изменения в профиле (имя, др, пол, школа, аватар)
  /// Также можно использовать для частичного обновления энергии, streak, сускоинов.
  Future<bool> saveProfile({
    String? name,
    DateTime? birthday,
    Gender? gender,
    String? school,
    int? avatarId,
    int? energy,
    int? suscoins,
    int? streak,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        if (name != null) 'name': name,
        if (birthday != null) 'birthday': birthday.toIso8601String(),
        if (gender != null) 'gender': gender.name,
        if (school != null) 'school': school,
        if (avatarId != null) 'avatarId': avatarId,
        if (energy != null) 'energy': energy,
        if (suscoins != null) 'suscoins': suscoins,
        if (streak != null) 'streak': streak,
        'email': _auth.currentUser?.email,
      };

      await _firestore.collection('profile').doc(userId).set(
            updateData,
            SetOptions(merge: true),
          );

      Logger.i('ProfileService -- saveProfile: данные сохранены: $updateData');
      return true;
    } catch (e) {
      Logger.e('Error saving profile: $e');
      return false;
    }
  }

  /// Удаляет профиль пользователя из Firestore
  Future<bool> deleteProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      await _firestore.collection('profile').doc(userId).delete();
      Logger.i('ProfileService -- deleteProfile: профиль удалён');
      return true;
    } catch (e) {
      Logger.e('Error deleting profile: $e');
      return false;
    }
  }
}
