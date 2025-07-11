// lib/features/routes/admin/progress_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Хранилище прогресса прохождения маршрутов
class ProgressState {
  final Map<String, int> unlockedIndexes; // ключ: routeId, значение: последний разблокированный индекс

  ProgressState({
    required this.unlockedIndexes,
  });

  /// Возвращает Set String разблокированных pointId в формате routeId-index
  Set<String> get unlockedPointIds {
    final ids = <String>{};
    unlockedIndexes.forEach((routeId, lastUnlocked) {
      for (int i = 0; i <= lastUnlocked; i++) {
        ids.add('$routeId-$i');
      }
    });
    return ids;
  }

  ProgressState copyWith({Map<String, int>? unlockedIndexes}) {
    return ProgressState(
      unlockedIndexes: unlockedIndexes ?? this.unlockedIndexes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unlockedIndexes': unlockedIndexes,
    };
  }

  factory ProgressState.fromMap(Map<String, dynamic> map) {
    final unlocked = Map<String, int>.from(map['unlockedIndexes'] ?? {});
    return ProgressState(unlockedIndexes: unlocked);
  }
}

/// StateNotifier для управления прогрессом
class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(ProgressState(unlockedIndexes: {'default': 0})); // по умолчанию открыта первая точка

  /// Разблокировать следующую точку на маршруте
  void unlockNext(String routeId) {
    final current = state.unlockedIndexes[routeId] ?? -1;
    final next = current + 1;
    final updated = Map<String, int>.from(state.unlockedIndexes);
    updated[routeId] = next;
    state = state.copyWith(unlockedIndexes: updated);
  }

  /// Загрузить прогресс из Firestore
  void setProgressFromFirestore(ProgressState firestoreState) {
    state = firestoreState;
  }

  /// Сбросить прогресс (для тестов или обнуления)
  void resetProgress() {
    state = ProgressState(unlockedIndexes: {'default': 0});
  }
}

/// Провайдер для UI
final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) => ProgressNotifier(),
);

/// Firestore-репозиторий для прогресса пользователя
class FirestoreProgressRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Загрузить прогресс пользователя
  Future<ProgressState> fetchUserProgress(String userId) async {
    try {
      final doc = await _db.collection('user_progress').doc(userId).get();
      if (!doc.exists) {
        return ProgressState(unlockedIndexes: {});
      }
      final data = doc.data() ?? {};
      return ProgressState.fromMap(data);
    } catch (e) {
      // Логирование ошибки при необходимости
      return ProgressState(unlockedIndexes: {});
    }
  }

  /// Сохранить прогресс пользователя
  Future<void> saveUserProgress(String userId, ProgressState state) async {
    try {
      await _db.collection('user_progress').doc(userId).set(
            state.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      // Логирование ошибки при необходимости
    }
  }
}
