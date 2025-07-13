import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';

class RouteModel {
  final String id;
  final String title;
  final String description;
  final List<RoutePoint> points;
  final int taskCount;

  RouteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.taskCount,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map, String id) {
    return RouteModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      taskCount: map['taskCount'] ?? 0,
      points:
          (map['points'] as List<dynamic>? ?? []).map((e) => RoutePoint.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'taskCount': taskCount,
      'points': points.map((p) => p.toJson()).toList(),
    };
  }
}

class RoutePoint {
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final bool isUnlocked;
  final QuestionTest test;

  RoutePoint({
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.isUnlocked = true,
    required this.test,
  });

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      name: map['name'] ?? '',
      description: map['description'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isUnlocked: map['isUnlocked'] ?? true,
      test: map['test'] != null ? QuestionTest.fromJson(map['test']) : SingleChoiceQuestion.init(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'isUnlocked': isUnlocked,
      'test': test.toJson(),
    };
  }
}
