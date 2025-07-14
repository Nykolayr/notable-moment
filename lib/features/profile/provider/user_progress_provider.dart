import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notable_moments/features/profile/model/achievement.dart';

final userProgressProvider = StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  return UserProgressNotifier();
});

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier() : super(_initialProgress());

  static UserProgress _initialProgress() => UserProgress(
        suscoins: 10,
        energy: 3,
        daysInARow: 0,
        lastVisit: DateTime.now(),
        routes: {},
        completedQuests: {},
        boughtHints: {},
        completedTestsV2: {},
        boughtHintsV2: {},
      );

  final _db = FirebaseFirestore.instance;

  Future<void> loadFromFirestore(String userId) async {
    final doc = await _db.collection('user_progress').doc(userId).get();
    if (doc.exists) {
      state = UserProgressFirestore.fromMap(doc.data()!);
    }
  }

  Future<void> saveToFirestore(String userId) async {
    await _db.collection('user_progress').doc(userId).set(state.toMap(), SetOptions(merge: true));
  }

  void addSuscoins(int count) => state = state.copyWith(suscoins: state.suscoins + count);
  void spendSuscoins(int count) => state = state.copyWith(suscoins: state.suscoins - count);

  void addEnergy(int count) => state = state.copyWith(energy: state.energy + count);
  void spendEnergy(int count) => state = state.copyWith(energy: state.energy - count);

  void addStreak() {
    final today = DateTime.now();
    if (state.lastVisit.difference(today).inDays == -1) {
      final newStreak = state.daysInARow + 1;
      state = state.copyWith(daysInARow: newStreak, lastVisit: today);
      if (newStreak % 7 == 0) addSuscoins(2); // 2 сускоина за 7 дней подряд
    } else if (state.lastVisit.day != today.day) {
      state = state.copyWith(daysInARow: 1, lastVisit: today);
    }
  }

  bool feedSuslik() {
    if (state.suscoins >= 3 && state.energy < 3) {
      spendSuscoins(3);
      addEnergy(1);
      return true;
    }
    return false;
  }

  void completeQuest(String questId, {bool noMistakes = false}) {
    state.completedQuests.add(questId);
    if (noMistakes) addSuscoins(1);
  }

  bool buyHint(String questId) {
    if (state.energy > 0 && !state.boughtHints.contains(questId)) {
      spendEnergy(1);
      state.boughtHints.add(questId);
      return true;
    }
    return false;
  }

  void completePlace(String routeId, String placeId) {
    state.routes.putIfAbsent(routeId, () => RouteProgress(completedPlaces: {}, completedQuests: {}));
    state.routes[routeId]!.completedPlaces.add(placeId);
  }

  void updateRoutes(List<dynamic> newRoutes) {
    // TODO: реализовать логику обновления маршрутов при изменениях
  }

  void initializeRoute(String routeId) {
    final routeProgress = state.routes[routeId];
    if (routeProgress == null) {
      final newRouteProgress = RouteProgress(
        completedPlaces: {},
        completedQuests: {},
        hintsLeft: 3,
      );
      final newRoutes = Map<String, RouteProgress>.from(state.routes);
      newRoutes[routeId] = newRouteProgress;
      state = state.copyWith(routes: newRoutes);
    }
  }

  void spendSuscoinAndUpdateHints(String routeId, int newHintsLeft) {
    final routeProgress = state.routes[routeId];
    final updatedRouteProgress = routeProgress?.copyWith(hintsLeft: newHintsLeft) ??
        RouteProgress(completedPlaces: {}, completedQuests: {}, hintsLeft: newHintsLeft);
    final newRoutes = Map<String, RouteProgress>.from(state.routes);
    newRoutes[routeId] = updatedRouteProgress;
    state = state.copyWith(
      suscoins: state.suscoins - 1,
      routes: newRoutes,
    );
  }

  Future<List<Achievement>> fetchAchievements(String userId) async {
    final snap = await _db.collection('achievements').where('userId', isEqualTo: userId).get();
    return snap.docs.map((doc) => Achievement.fromMap(doc.data())).toList();
  }

  Future<void> addAchievement(String userId, Achievement achievement) async {
    await _db.collection('achievements').add({
      ...achievement.toMap(),
      'userId': userId,
    });
  }
}
