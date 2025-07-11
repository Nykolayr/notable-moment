import 'package:collection/collection.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';

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
  final Question test;

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
    required this.isDraft,
    required this.test,
  });

  factory PointAdminModel.fromMap(Map<String, dynamic> map, String id) => PointAdminModel(
        id: id,
        point: PointExtension.fromMap(map['point'] as Map<String, dynamic>),
        photos: List<String>.from(map['photos'] as List<dynamic>),
        title: map['title'] as String,
        description: map['description'] as String,
        schedule: WorkingHours.fromMap(map['schedule'] as Map<String, dynamic>),
        phones: map['phones'] == null ? [] : List<String>.from(map['phones'] as List<dynamic>),
        url: map['url'] as String,
        order: map['order'] as int? ?? 0,
        isDraft: map['isDraft'] as bool? ?? true,
        test: map['test'] != null ? Question.fromJson(map['test']) : SingleChoiceQuestion.init(),
      );

  Map<String, dynamic> toMap() => {
        'point': point.toMap(),
        'photos': photos,
        'title': title,
        'description': description,
        'schedule': schedule.toMap(),
        'phones': phones,
        'url': url,
        'order': order,
        'isDraft': isDraft,
        'test': test.toJson(),
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
    Question? test,
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
        test: test ?? this.test,
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
          test == other.test;

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
      test.hashCode;
}
