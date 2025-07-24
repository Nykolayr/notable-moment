import 'package:collection/collection.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as yandex_map;

class PointAdminModel {
  final String id;
  final yandex_map.Point point;
  final List<String> photos;
  final String title;
  final String description;
  final WorkingHours schedule;
  final List<String> phones;
  final String url;
  final int order;
  final bool isDraft;
  final List<QuestionTest> tests;

  bool get isActive => !isDraft;

  // 🔹 Добавлены геттеры для latitude и longitude
  double get latitude => point.latitude;
  double get longitude => point.longitude;

  PointAdminModel({
    required this.id,
    required this.point,
    required this.photos,
    required this.title,
    required this.description,
    required this.schedule,
    required this.phones,
    required this.url,
    required this.order,
    this.isDraft = false,
    required this.tests,
  });

  factory PointAdminModel.fromMap(Map<String, dynamic> map, String id) {
    // Обработка старого формата с одним тестом
    if (map['test'] != null && map['tests'] == null) {
      final test = QuestionTest.fromJson(map['test']);
      return PointAdminModel(
        id: id,
        point: yandex_map.Point(
          latitude: (map['point']['latitude'] as num).toDouble(),
          longitude: (map['point']['longitude'] as num).toDouble(),
        ),
        photos: List<String>.from(map['photos'] as List<dynamic>),
        title: map['title'] as String,
        description: map['description'] as String,
        schedule: WorkingHours.fromMap(map['schedule'] as Map<String, dynamic>),
        phones: map['phones'] == null ? [] : List<String>.from(map['phones'] as List<dynamic>),
        url: map['url'] as String,
        order: map['order'] as int? ?? 0,
        isDraft: map['isDraft'] as bool? ?? true,
        tests: [test],
      );
    }

    // Обработка нового формата с массивом тестов
    return PointAdminModel(
      id: id,
      point: yandex_map.Point(
        latitude: (map['point']['latitude'] as num).toDouble(),
        longitude: (map['point']['longitude'] as num).toDouble(),
      ),
      photos: List<String>.from(map['photos'] as List<dynamic>),
      title: map['title'] as String,
      description: map['description'] as String,
      schedule: WorkingHours.fromMap(map['schedule'] as Map<String, dynamic>),
      phones: map['phones'] == null ? [] : List<String>.from(map['phones'] as List<dynamic>),
      url: map['url'] as String,
      order: map['order'] as int? ?? 0,
      isDraft: map['isDraft'] as bool? ?? true,
      tests: map['tests'] != null
          ? (map['tests'] as List<dynamic>).map((e) => QuestionTest.fromJson(e)).toList()
          : [SingleChoiceQuestion.init()],
    );
  }

  Map<String, dynamic> toMap() => {
        'point': {
          'latitude': point.latitude,
          'longitude': point.longitude,
        },
        'photos': photos,
        'title': title,
        'description': description,
        'schedule': schedule.toMap(),
        'phones': phones,
        'url': url,
        'order': order,
        'isDraft': isDraft,
        'tests': tests.map((test) => test.toJson()).toList(),
      };

  PointAdminModel copyWith({
    String? id,
    yandex_map.Point? point,
    List<String>? photos,
    String? title,
    String? description,
    WorkingHours? schedule,
    List<String>? phones,
    String? url,
    int? order,
    bool? isDraft,
    List<QuestionTest>? tests,
  }) =>
      PointAdminModel(
        id: id ?? this.id,
        point: point ?? this.point,
        photos: photos ?? this.photos,
        title: title ?? this.title,
        description: description ?? this.description,
        schedule: schedule ?? this.schedule,
        phones: phones ?? this.phones,
        url: url ?? this.url,
        order: order ?? this.order,
        isDraft: isDraft ?? this.isDraft,
        tests: tests ?? this.tests,
      );

  @override
  String toString() => 'PointAdminModel(id: $id, ${toMap()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointAdminModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          point == other.point &&
          const ListEquality<String>().equals(photos, other.photos) &&
          title == other.title &&
          description == other.description &&
          schedule == other.schedule &&
          const ListEquality<String>().equals(phones, other.phones) &&
          url == other.url &&
          order == other.order &&
          isDraft == other.isDraft &&
          const ListEquality<QuestionTest>().equals(tests, other.tests);

  @override
  int get hashCode =>
      id.hashCode ^
      point.hashCode ^
      photos.hashCode ^
      title.hashCode ^
      description.hashCode ^
      schedule.hashCode ^
      phones.hashCode ^
      url.hashCode ^
      order.hashCode ^
      isDraft.hashCode ^
      tests.hashCode;
}
