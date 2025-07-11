import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registers a new user with email and password
  static Future<Either<String, User?>> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      switch (e.code) {
        case 'weak-password':
          return Left('Слабый пароль');
        case 'email-already-in-use':
          return Left('Этот адрес электронной почты уже используется');
        case 'invalid-email':
          return Left('Неверный адрес электронной почты');
        case 'operation-not-allowed':
          return Left('Неверный адрес электронной почты');
        default:
          return Left(e.message ?? '');
      }
    }
  }

  /// Signs in a user with email and password
  static Future<Either<String, User?>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      switch (e.code) {
        case 'user-not-found':
          return Left('Пользователь не найден');
        case 'wrong-password':
          return Left('Неверный пароль');
        case 'invalid-email':
          return Left('Неверный адрес электронной почты');
        case 'invalid-credential':
          return Left('Неверные учетные данные');
        case 'user-disabled':
          return Left('Пользователь заблокирован');
        default:
          return Left(e.message ?? '');
      }
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the specified email address
  static Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      _auth.setLanguageCode("ru");
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error sending password reset email: $e');
      switch (e.code) {
        case 'user-not-found':
          return Left('Пользователь не найден');
        case 'invalid-email':
          return Left('Неверный адрес электронной почты');
        default:
          return Left(e.message ?? 'An error occurred while sending password reset email');
      }
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return const Left('An unexpected error occurred');
    }
  }

  /// Deletes the current user's account and associated data
  static Future<Either<String, void>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Left('No user signed in');

      await user.delete();
      return Right(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error deleting account: $e');
      switch (e.code) {
        case 'requires-recent-login':
          return Left('Please sign in again before deleting your account');
        default:
          return Left(e.message ?? 'Failed to delete account');
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return Left('Failed to delete account');
    }
  }
}
