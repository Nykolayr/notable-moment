// lib/core/provider/auth_state.dart

import 'package:firebase_auth/firebase_auth.dart';

/// Состояние авторизации пользователя
class AuthState {
  final User? user; // Текущий пользователь Firebase
  final bool removeUser; // Флаг для удаления пользователя из состояния

  /// Конструктор состояния авторизации
  const AuthState({
    required this.user,
    required this.removeUser,
  });

  /// Начальное состояние авторизации
  factory AuthState.initial() => const AuthState(
        user: null,
        removeUser: false,
      );

  /// Удобный метод обновления состояния через copyWith
  AuthState copyWith({
    User? user,
    bool? removeUser,
  }) {
    return AuthState(
      user: user ?? this.user,
      removeUser: removeUser ?? this.removeUser,
    );
  }

  /// Отладочное представление
  @override
  String toString() => 'AuthState(user: $user, removeUser: $removeUser)';
}
