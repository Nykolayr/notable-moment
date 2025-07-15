import 'package:yandex_mapkit/yandex_mapkit.dart' as yandex;

class RouteModel {
  final String id;
  final String title;
  final int locations;
  final int tasks;
  final String description;
  final List<String> labels;
  final List<yandex.Point> points;

  RouteModel({
    required this.id,
    required this.title,
    required this.locations,
    required this.tasks,
    required this.description,
    required this.labels,
    required this.points,
  });

  factory RouteModel.fromFirestore(String id, Map<String, dynamic> json) {
    // 🔐 Безопасное извлечение labels (гарантирует List)
    final rawLabels = json['labels'] as List<dynamic>? ?? [];
    final parsedLabels = rawLabels.map((e) => e.toString()).toList();

    // 🔐 Безопасное извлечение points
    final rawPoints = json['points'] as List<dynamic>? ?? [];
    final parsedPoints = rawPoints.map((point) {
      final lat = point['lat'];
      final lng = point['lng'];
      return yandex.Point(
        latitude: (lat is num) ? lat.toDouble() : 0.0,
        longitude: (lng is num) ? lng.toDouble() : 0.0,
      );
    }).toList();

    return RouteModel(
      id: id,
      title: json['title'] ?? '',
      locations: json['locations'] ?? 0,
      tasks: json['tasks'] ?? 0,
      description: json['description'] ?? '',
      labels: parsedLabels,
      points: parsedPoints,
    );
  }
}
