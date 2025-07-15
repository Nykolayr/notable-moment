import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:either_dart/either.dart';
import 'package:notable_moments/core/provider/auth_service.dart';
import 'package:notable_moments/core/provider/auth_state.dart'; // Убедись, что этот файл существует
import 'package:notable_moments/features/profile/provider/profile_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref ref;

  AuthNotifier(this._authService, this.ref) : super(AuthState.initial()) {
    _authService.authStateChanges.listen((user) {
      Logger.i('authProvider user: $user');
      if (user == null) {
        state = state.copyWith(user: null, removeUser: true);
      } else {
        state = state.copyWith(user: user, removeUser: false);
      }
    });
  }

  Future<Either<String, User?>> registerWithEmailAndPassword(String email, String password) async {
    try {
      ref.read(profileProvider.notifier).setRegistrationMode();

      final result = await AuthService.registerWithEmailAndPassword(email, password);
      return result.fold(
        (error) {
          Logger.e('authProvider -- register error: $error');
          return Left(error);
        },
        (user) {
          state = state.copyWith(user: user);
          Logger.i('authProvider -- register success: ${user?.uid}');
          return Right(user);
        },
      );
    } catch (e) {
      Logger.e('authProvider -- register exception: $e');
      return Left('Ошибка регистрации: ${e.toString()}');
    }
  }

  Future<Either<String, User?>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await AuthService.signInWithEmailAndPassword(email, password);
      return result.fold(
        (error) {
          Logger.e('authProvider -- signIn error: $error');
          return Left(error);
        },
        (user) {
          state = state.copyWith(user: user);
          ref.read(profileProvider.notifier).loadProfile();
          Logger.i('authProvider -- signIn success: ${user?.uid}');
          return Right(user);
        },
      );
    } catch (e) {
      Logger.e('authProvider -- signIn exception: $e');
      return Left('Ошибка входа: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      ref.read(profileProvider.notifier).signOut();
      state = state.copyWith(user: null, removeUser: true);
      Logger.i('authProvider -- signOut success');
    } catch (e) {
      Logger.e('authProvider -- signOut error: $e');
    }
  }

  Future<void> removeAccount() async {
    try {
      final isProfileRemoved = await ref.read(profileProvider.notifier).deleteProfile();
      if (!isProfileRemoved) {
        Logger.e('authProvider -- removeAccount: ошибка удаления профиля');
        return;
      }

      final result = await AuthService.deleteAccount();
      result.fold(
        (error) => Logger.e('authProvider -- deleteAccount error: $error'),
        (_) {
          Logger.i('authProvider -- deleteAccount success');
          signOut();
        },
      );
    } catch (e) {
      Logger.e('authProvider -- removeAccount exception: $e');
    }
  }

  Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      final result = await AuthService.sendPasswordResetEmail(email);
      return result.fold(
        (error) {
          Logger.e('authProvider -- sendPasswordResetEmail error: $error');
          return Left(error);
        },
        (_) {
          Logger.i('authProvider -- sendPasswordResetEmail success');
          return const Right(null);
        },
      );
    } catch (e) {
      Logger.e('authProvider -- sendPasswordResetEmail exception: $e');
      return Left('Ошибка сброса пароля: ${e.toString()}');
    }
  }
}
