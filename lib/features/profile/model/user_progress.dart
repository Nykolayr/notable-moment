class UserProgress {
  int suscoins;
  int energy;
  int daysInARow;
  DateTime lastVisit;
  Map<String, RouteProgress> routes; // routeId -> progress
  Set<String> completedQuests; // questId
  Set<String> boughtHints; // questId

  UserProgress({
    required this.suscoins,
    required this.energy,
    required this.daysInARow,
    required this.lastVisit,
    required this.routes,
    required this.completedQuests,
    required this.boughtHints,
  });

  UserProgress copyWith({
    int? suscoins,
    int? energy,
    int? daysInARow,
    DateTime? lastVisit,
    Map<String, RouteProgress>? routes,
    Set<String>? completedQuests,
    Set<String>? boughtHints,
  }) {
    return UserProgress(
      suscoins: suscoins ?? this.suscoins,
      energy: energy ?? this.energy,
      daysInARow: daysInARow ?? this.daysInARow,
      lastVisit: lastVisit ?? this.lastVisit,
      routes: routes ?? this.routes,
      completedQuests: completedQuests ?? this.completedQuests,
      boughtHints: boughtHints ?? this.boughtHints,
    );
  }
}

class RouteProgress {
  Set<String> completedPlaces; // placeId
  Map<String, Set<String>> completedQuests; // placeId -> Set<questId>

  RouteProgress({
    required this.completedPlaces,
    required this.completedQuests,
  });
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
      routes: (map['routes'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, RouteProgressFirestore.fromMap(v))),
      completedQuests: Set<String>.from(map['completedQuests'] ?? []),
      boughtHints: Set<String>.from(map['boughtHints'] ?? []),
    );
  }
}

extension RouteProgressFirestore on RouteProgress {
  Map<String, dynamic> toMap() {
    return {
      'completedPlaces': completedPlaces.toList(),
      'completedQuests': completedQuests.map((k, v) => MapEntry(k, v.toList())),
    };
  }

  static RouteProgress fromMap(Map<String, dynamic> map) {
    return RouteProgress(
      completedPlaces: Set<String>.from(map['completedPlaces'] ?? []),
      completedQuests: (map['completedQuests'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, Set<String>.from(v ?? []))),
    );
  }
} 