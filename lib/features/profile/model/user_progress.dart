class UserProgress {
  int suscoins;
  int energy;
  int daysInARow;
  DateTime lastVisit;
  Map<String, RouteProgress> routes;
  Set<String> completedTestsV2; // pointId_questionId
  Set<String> boughtHintsV2; // pointId_questionId
  Set<String> completedQuests; // legacy
  Set<String> boughtHints; // legacy

  UserProgress({
    required this.suscoins,
    required this.energy,
    required this.daysInARow,
    required this.lastVisit,
    required this.routes,
    required this.completedTestsV2,
    required this.boughtHintsV2,
    required this.completedQuests,
    required this.boughtHints,
  });

  UserProgress copyWith({
    int? suscoins,
    int? energy,
    int? daysInARow,
    DateTime? lastVisit,
    Map<String, RouteProgress>? routes,
    Set<String>? completedTestsV2,
    Set<String>? boughtHintsV2,
    Set<String>? completedQuests,
    Set<String>? boughtHints,
  }) {
    return UserProgress(
      suscoins: suscoins ?? this.suscoins,
      energy: energy ?? this.energy,
      daysInARow: daysInARow ?? this.daysInARow,
      lastVisit: lastVisit ?? this.lastVisit,
      routes: routes ?? this.routes,
      completedTestsV2: completedTestsV2 ?? this.completedTestsV2,
      boughtHintsV2: boughtHintsV2 ?? this.boughtHintsV2,
      completedQuests: completedQuests ?? this.completedQuests,
      boughtHints: boughtHints ?? this.boughtHints,
    );
  }

  /// Миграция старых полей в новые
  void migrateLegacyProgress(Map<String, String> pointToQuestionId) {
    // completedQuests -> completedTestsV2
    for (final pointId in completedQuests) {
      final qid = pointToQuestionId[pointId] ?? 'unknown';
      completedTestsV2.add('${pointId}_$qid');
    }
    // boughtHints -> boughtHintsV2
    for (final pointId in boughtHints) {
      final qid = pointToQuestionId[pointId] ?? 'unknown';
      boughtHintsV2.add('${pointId}_$qid');
    }
  }
}

class RouteProgress {
  Set<String> completedPlaces; // placeId
  Map<String, Set<String>> completedQuests; // placeId -> Set<questId>
  int hintsLeft;

  RouteProgress({
    required this.completedPlaces,
    required this.completedQuests,
    this.hintsLeft = 3,
  });

  RouteProgress copyWith({
    Set<String>? completedPlaces,
    Map<String, Set<String>>? completedQuests,
    int? hintsLeft,
  }) {
    return RouteProgress(
      completedPlaces: completedPlaces ?? this.completedPlaces,
      completedQuests: completedQuests ?? this.completedQuests,
      hintsLeft: hintsLeft ?? this.hintsLeft,
    );
  }
}

extension UserProgressFirestore on UserProgress {
  Map<String, dynamic> toMap() {
    return {
      'suscoins': suscoins,
      'energy': energy,
      'daysInARow': daysInARow,
      'lastVisit': lastVisit.toIso8601String(),
      'routes': routes.map((k, v) => MapEntry(k, v.toMap())),
      'completedQuests': completedQuests.toList(),
      'boughtHints': boughtHints.toList(),
    };
  }

  static UserProgress fromMap(Map<String, dynamic> map) {
    return UserProgress(
      suscoins: map['suscoins'] ?? 0,
      energy: map['energy'] ?? 0,
      daysInARow: map['daysInARow'] ?? 0,
      lastVisit: DateTime.parse(map['lastVisit'] ?? DateTime.now().toIso8601String()),
      routes:
          (map['routes'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, RouteProgressFirestore.fromMap(v))),
      completedQuests: Set<String>.from(map['completedQuests'] ?? []),
      boughtHints: Set<String>.from(map['boughtHints'] ?? []),
      completedTestsV2: Set<String>.from(map['completedTestsV2'] ?? []),
      boughtHintsV2: Set<String>.from(map['boughtHintsV2'] ?? []),
    );
  }
}

extension RouteProgressFirestore on RouteProgress {
  Map<String, dynamic> toMap() {
    return {
      'completedPlaces': completedPlaces.toList(),
      'completedQuests': completedQuests.map((k, v) => MapEntry(k, v.toList())),
      'hintsLeft': hintsLeft,
    };
  }

  static RouteProgress fromMap(Map<String, dynamic> map) {
    return RouteProgress(
      completedPlaces: Set<String>.from(map['completedPlaces'] ?? []),
      completedQuests:
          (map['completedQuests'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, Set<String>.from(v ?? []))),
      hintsLeft: map['hintsLeft'] ?? 3,
    );
  }
}
