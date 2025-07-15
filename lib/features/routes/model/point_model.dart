import 'package:notable_moments/features/routes/enum/point_state_enum.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

extension PointMapExt on Point {
  Map<String, dynamic> toMap() => {'latitude': latitude, 'longitude': longitude};
}

class PointModel {
  final String title;
  final Point point;
  final PointState state;

  // Добавленные поля
  final bool isUnlocked;
  final bool isCompleted;

  const PointModel({
    required this.title,
    required this.point,
    required this.state,
    this.isUnlocked = false,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'point': point.toMap(),
        'state': state.name,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
      };

  factory PointModel.fromMap(Map<String, dynamic> map) => PointModel(
        title: map['title'] as String,
        point: Point(latitude: map['point']['latitude'] as double, longitude: map['point']['longitude'] as double),
        state: PointState.fromMap(map['state'] as String),
        isUnlocked: map['isUnlocked'] ?? false,
        isCompleted: map['isCompleted'] ?? false,
      );

  PointModel copyWith({
    String? title,
    Point? point,
    PointState? state,
    bool? isUnlocked,
    bool? isCompleted,
  }) =>
      PointModel(
        title: title ?? this.title,
        point: point ?? this.point,
        state: state ?? this.state,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  String toString() =>
      'PointModel(title: $title, point: $point, state: $state, isUnlocked: $isUnlocked, isCompleted: $isCompleted)';
}
