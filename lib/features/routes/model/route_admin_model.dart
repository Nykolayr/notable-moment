import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RouteAdminModel {
  final String id;
  final int order;
  final String title;
  final String description;
  final String url;
  final String whyThisRoute;
  final List<PointAdminModel> points;
  final bool isDraft;
  final Polyline polyline;
  final Polyline? calculatedRoute;

  int get visiblePoints => points.where((point) => !point.isDraft).length;
  int get draftPoints => points.where((point) => point.isDraft).length;

  const RouteAdminModel({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.url,
    required this.whyThisRoute,
    required this.points,
    required this.isDraft,
    required this.polyline,
    this.calculatedRoute,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'order': order,
        'title': title,
        'description': description,
        'url': url,
        'whyThisRoute': whyThisRoute,
        'points': points.map((point) => point.toMap()).toList(),
        'isDraft': isDraft,
        'polyline': polyline.toMap(),
        'calculatedRoute': calculatedRoute?.toMap(), // Добавляем рассчитанный маршрут
      };

  factory RouteAdminModel.fromMap(Map<String, dynamic> map) {
    final pointList = map['points'] as List<dynamic>? ?? [];
    final List<PointAdminModel> parsedPoints = [];

    for (int i = 0; i < pointList.length; i++) {
      final pointMap = pointList[i] as Map<String, dynamic>;
      final String pointId = pointMap['id'] ?? 'point_$i';
      parsedPoints.add(PointAdminModel.fromMap(pointMap, pointId));
    }

    return RouteAdminModel(
      id: map['id'] as String,
      order: map['order'] as int,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      url: map['url'] as String? ?? '',
      whyThisRoute: map['whyThisRoute'] as String? ?? '',
      points: parsedPoints,
      isDraft: map['isDraft'] as bool? ?? false,
      polyline: map['polyline'] == null
          ? Polyline(points: [])
          : PolylineMapExt.fromMap(map['polyline'] as Map<String, dynamic>),
      calculatedRoute: map['calculatedRoute'] == null
          ? null
          : PolylineMapExt.fromMap(map['calculatedRoute'] as Map<String, dynamic>), // Обратная совместимость
    );
  }

  RouteAdminModel copyWith({
    String? id,
    int? order,
    String? title,
    String? description,
    String? url,
    String? whyThisRoute,
    List<PointAdminModel>? points,
    bool? isDraft,
    Polyline? polyline,
    Polyline? calculatedRoute,
  }) =>
      RouteAdminModel(
        id: id ?? this.id,
        order: order ?? this.order,
        title: title ?? this.title,
        description: description ?? this.description,
        url: url ?? this.url,
        whyThisRoute: whyThisRoute ?? this.whyThisRoute,
        points: points ?? this.points,
        isDraft: isDraft ?? this.isDraft,
        polyline: polyline ?? Polyline(points: []),
        calculatedRoute: calculatedRoute ?? this.calculatedRoute,
      );

  @override
  String toString() => 'RouteAdminModel(${toMap()})';

  String print(String label) => '$label RouteAdminModel(id: $id, points.length: ${points.length})';
}

/// ✅ Расширение: безопасно преобразует RouteAdminModel → RouteModel
extension RouteAdminMapper on RouteAdminModel {
  RouteModel toRouteModel() {
    return RouteModel(
      id: id,
      title: title,
      description: description,
      whyThisRoute: whyThisRoute,
      points: points.map((p) {
        return RoutePoint(
          name: p.title,
          description: p.description,
          latitude: p.point.latitude,
          longitude: p.point.longitude,
          tests: p.tests,
        );
      }).toList(),
      taskCount: points.length, // При необходимости можешь заменить на сумму заданий
    );
  }
}

extension PolylineMapExt on Polyline {
  Map<String, dynamic> toMap() => {
        'points': points.map((p) => {'latitude': p.latitude, 'longitude': p.longitude}).toList(),
      };

  static Polyline fromMap(Map<String, dynamic> map) => Polyline(
        points: (map['points'] as List)
            .map((e) => Point(latitude: e['latitude'] as double, longitude: e['longitude'] as double))
            .toList(),
      );
}
