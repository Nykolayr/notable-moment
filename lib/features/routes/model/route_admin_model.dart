import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:convert' as jsonDecode;
import 'package:http/http.dart' as http;
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/utils/yandex_disk_upload.dart';
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
  Future<RouteModel> toRouteModel() async {
    Logger.i('toRouteModel: ВЫЗВАН метод toRouteModel для маршрута $id ($title)');

    final List<RoutePoint> routePoints = [];

    // Получаем токен один раз для всех запросов
    final token = await YandexDiskUploader.getValidToken();

    for (var p in points) {
      final List<String> localPhotos = [];

      for (var photoUrl in p.photos) {
        Logger.i('toRouteModel: путь к фото: $photoUrl');
        try {
          // Извлекаем имя файла из пути на Яндекс.Диске
          final fileName = photoUrl.split('/').last;
          Logger.i('toRouteModel: имя файла: $fileName');
          final directory = await getApplicationDocumentsDirectory();
          final localFile = io.File('${directory.path}/$fileName');
          Logger.i('toRouteModel: Локальный путь для файла: ${localFile.path}');

          if (await localFile.exists()) {
            // Если файл уже существует локально, используем его
            final fileSize = await localFile.length();
            localPhotos.add(localFile.path);
            Logger.i('toRouteModel: Фото уже существует локально: ${localFile.path} (размер: $fileSize байт)');
          } else {
            try {
              // Получаем ссылку для скачивания напрямую
              Logger.i('toRouteModel: Запрашиваем ссылку для скачивания файла: $photoUrl');
              final downloadUrlResponse = await http.get(
                Uri.parse(
                    'https://cloud-api.yandex.net/v1/disk/resources/download?path=${Uri.encodeComponent(photoUrl)}'),
                headers: {
                  'Authorization': 'OAuth $token',
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'User-Agent': 'NotableMoments/1.0',
                },
              );

              Logger.i('toRouteModel: Ответ на запрос ссылки для скачивания: ${downloadUrlResponse.statusCode}');
              Logger.i('toRouteModel: Тело ответа: ${downloadUrlResponse.body}');

              if (downloadUrlResponse.statusCode == 200) {
                final downloadUrl = jsonDecode.jsonDecode(downloadUrlResponse.body)['href'];
                Logger.i('toRouteModel: Получена ссылка для скачивания: $downloadUrl');

                // Скачиваем файл
                final fileResponse = await http.get(
                  Uri.parse(downloadUrl),
                  headers: {'User-Agent': 'NotableMoments/1.0'},
                );

                Logger.i('toRouteModel: Ответ на скачивание файла: ${fileResponse.statusCode}');

                if (fileResponse.statusCode == 200) {
                  final bytes = fileResponse.bodyBytes;
                  Logger.i('toRouteModel: Получено ${bytes.length} байт');

                  // Создаем директорию, если она не существует
                  final directory = await getApplicationDocumentsDirectory();
                  if (!await directory.exists()) {
                    await directory.create(recursive: true);
                  }

                  // Сохраняем файл локально
                  await localFile.writeAsBytes(bytes);
                  final fileSize = await localFile.length();
                  Logger.i('toRouteModel: Файл сохранен локально: ${localFile.path} (размер: $fileSize байт)');

                  localPhotos.add(localFile.path);
                  Logger.i('toRouteModel: Фото загружено и сохранено локально: ${localFile.path}');
                } else {
                  Logger.e('toRouteModel: Ошибка скачивания файла: ${fileResponse.statusCode}');
                  // Если не удалось скачать, не добавляем фото
                }
              } else {
                Logger.e('toRouteModel: Ошибка получения ссылки для скачивания: ${downloadUrlResponse.statusCode}');
                // Если не удалось получить ссылку, не добавляем фото
              }
            } catch (e) {
              Logger.e('toRouteModel: Ошибка загрузки фото: $e');
              // При ошибке не добавляем фото
            }
          }
        } catch (e) {
          Logger.e('toRouteModel: Общая ошибка при обработке фото: $e');
          // При ошибке не добавляем фото
        }
      }

      routePoints.add(RoutePoint(
        name: p.title,
        description: p.description,
        latitude: p.point.latitude,
        longitude: p.point.longitude,
        tests: p.tests,
        photos: localPhotos,
      ));
    }

    return RouteModel(
      id: id,
      title: title,
      description: description,
      whyThisRoute: whyThisRoute,
      points: routePoints,
      taskCount: points.length,
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
