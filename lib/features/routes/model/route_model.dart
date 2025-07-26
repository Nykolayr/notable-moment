import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';

class RouteModel {
  final String id;
  final String title;
  final String description;
  final String? whyThisRoute;
  final List<RoutePoint> points;
  final int taskCount;
  final List<String> photos;

  RouteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.taskCount,
    this.whyThisRoute,
    this.photos = const [],
  });

  factory RouteModel.fromMap(Map<String, dynamic> map, String id) {
    return RouteModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      whyThisRoute: map['whyThisRoute'],
      taskCount: map['taskCount'] ?? 0,
      points:
          (map['points'] as List<dynamic>? ?? []).map((e) => RoutePoint.fromMap(e as Map<String, dynamic>)).toList(),
      photos: (map['photos'] as List<dynamic>? ?? const []).cast<String>().toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'whyThisRoute': whyThisRoute,
      'taskCount': taskCount,
      'points': points.map((p) => p.toJson()).toList(),
      'photos': photos,
    };
  }
}

class RoutePoint {
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final bool isUnlocked;
  final List<QuestionTest> tests;
  final List<String> photos;

  RoutePoint({
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.isUnlocked = true,
    required this.tests,
    this.photos = const [],
  });

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    // Обработка старого формата с одним тестом
    if (map['test'] != null && map['tests'] == null) {
      final test = QuestionTest.fromJson(map['test']);
      return RoutePoint(
        name: map['name'] ?? '',
        description: map['description'],
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        isUnlocked: map['isUnlocked'] ?? true,
        tests: [test],
        photos: (map['photos'] as List<dynamic>? ?? const []).cast<String>().toList(),
      );
    }

    // Обработка нового формата с массивом тестов
    return RoutePoint(
      name: map['name'] ?? '',
      description: map['description'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isUnlocked: map['isUnlocked'] ?? true,
      tests: map['tests'] != null
          ? (map['tests'] as List<dynamic>).map((e) => QuestionTest.fromJson(e)).toList()
          : [SingleChoiceQuestion.init()],
      photos: (map['photos'] as List<dynamic>? ?? const []).cast<String>().toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'isUnlocked': isUnlocked,
      'tests': tests.map((test) => test.toJson()).toList(),
      'photos': photos,
    };
  }
}
