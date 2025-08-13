// lib/core/provider/auth_state.dart

import 'package:firebase_auth/firebase_auth.dart';

/// Состояние авторизации пользователя
class AuthState {
  final User? user; // Текущий пользователь Firebase
  final bool removeUser; // Флаг для удаления пользователя из состояния
  final bool isLoading; // Флаг загрузки (регистрация/вход)

  /// Конструктор состояния авторизации
  const AuthState({
    required this.user,
    required this.removeUser,
    required this.isLoading,
  });

  /// Начальное состояние авторизации
  factory AuthState.initial() => const AuthState(
        user: null,
        removeUser: false,
        isLoading: false,
      );

  /// Удобный метод обновления состояния через copyWith
  AuthState copyWith({
    User? user,
    bool? removeUser,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      removeUser: removeUser ?? this.removeUser,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Отладочное представление
  @override
  String toString() => 'AuthState(user: $user, removeUser: $removeUser, isLoading: $isLoading)';
}
