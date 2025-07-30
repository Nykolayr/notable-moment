import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
// ignore: library_prefixes
import 'dart:convert' as jsonDecode;
// ignore: depend_on_referenced_packages
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
    final List<RoutePoint> routePoints = [];

    // Получаем токен один раз для всех запросов
    final token = await YandexDiskUploader.getValidToken();

    for (var p in points) {
      final List<String> localPhotos = [];

      for (var photoUrl in p.photos) {
        try {
          // Проверяем, что путь к фото не пустой
          if (photoUrl.isEmpty) {
            Logger.w('toRouteModel: Пустой путь к фото, пропускаем');
            continue;
          }

          // Извлекаем имя файла из пути на Яндекс.Диске
          final fileName = photoUrl.split('/').last;
          final directory = await getApplicationDocumentsDirectory();

          // Проверяем файл в папке notable_moments (где сохраняются локальные копии)
          final localFile = io.File('${directory.path}/notable_moments/$fileName');

          // Также проверяем файл в корневой папке (для обратной совместимости)
          final rootFile = io.File('${directory.path}/$fileName');

          Logger.d('toRouteModel: Ищем файл: $fileName');
          Logger.d('toRouteModel: Путь в notable_moments: ${localFile.path}');
          Logger.d('toRouteModel: Путь в корневой папке: ${rootFile.path}');

          if (await localFile.exists()) {
            // Если файл существует в папке notable_moments, используем его
            final fileSize = await localFile.length();
            localPhotos.add(localFile.path);
            Logger.d('toRouteModel: Фото найдено в notable_moments: $fileName ($fileSize байт)');
          } else if (await rootFile.exists()) {
            // Если файл существует в корневой папке, используем его
            final fileSize = await rootFile.length();
            localPhotos.add(rootFile.path);
            Logger.d('toRouteModel: Фото найдено в корневой папке: $fileName ($fileSize байт)');
          } else {
            Logger.d('toRouteModel: Файл не найден локально, скачиваем с Яндекс.Диска: $fileName');
            Logger.d('toRouteModel: Полный путь на Яндекс.Диске: $photoUrl');
            try {
              // Получаем ссылку для скачивания напрямую
              Logger.d('toRouteModel: Скачиваем фото: $fileName');
              Logger.d('toRouteModel: Используем токен: ${token.substring(0, 10)}...');

              final requestUrl =
                  'https://cloud-api.yandex.net/v1/disk/resources/download?path=${Uri.encodeComponent(photoUrl)}';
              Logger.d('toRouteModel: URL запроса: $requestUrl');

              final downloadUrlResponse = await http.get(
                Uri.parse(requestUrl),
                headers: {
                  'Authorization': 'OAuth $token',
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'User-Agent': 'NotableMoments/1.0',
                },
              );

              Logger.d('toRouteModel: Ответ на запрос ссылки для скачивания: ${downloadUrlResponse.statusCode}');
              Logger.d('toRouteModel: Тело ответа: ${downloadUrlResponse.body}');

              if (downloadUrlResponse.statusCode == 200) {
                final responseData = jsonDecode.jsonDecode(downloadUrlResponse.body);
                final downloadUrl = responseData['href'];
                Logger.d('toRouteModel: Получена ссылка для скачивания: $downloadUrl');

                // Скачиваем файл
                final fileResponse = await http.get(
                  Uri.parse(downloadUrl),
                  headers: {'User-Agent': 'NotableMoments/1.0'},
                );

                Logger.d('toRouteModel: Ответ на скачивание файла: ${fileResponse.statusCode}');
                Logger.d('toRouteModel: Размер скачанного файла: ${fileResponse.bodyBytes.length} байт');

                if (fileResponse.statusCode == 200) {
                  final bytes = fileResponse.bodyBytes;

                  // Создаем директорию notable_moments, если она не существует
                  final notableMomentsDir = io.Directory('${directory.path}/notable_moments');
                  if (!await notableMomentsDir.exists()) {
                    await notableMomentsDir.create(recursive: true);
                    Logger.d('toRouteModel: Создана директория: ${notableMomentsDir.path}');
                  }

                  // Сохраняем файл локально в папку notable_moments
                  await localFile.writeAsBytes(bytes);
                  final fileSize = await localFile.length();
                  Logger.d('toRouteModel: Фото загружено в notable_moments: $fileName ($fileSize байт)');
                  Logger.d('toRouteModel: Локальный путь: ${localFile.path}');

                  localPhotos.add(localFile.path);
                } else {
                  Logger.e('toRouteModel: Ошибка скачивания файла: ${fileResponse.statusCode}');
                  Logger.e('toRouteModel: Тело ответа при скачивании: ${fileResponse.body}');
                }
              } else {
                Logger.e('toRouteModel: Ошибка получения ссылки для скачивания: ${downloadUrlResponse.statusCode}');
                Logger.e('toRouteModel: Тело ответа при запросе ссылки: ${downloadUrlResponse.body}');
              }
            } catch (e) {
              Logger.e('toRouteModel: Ошибка загрузки фото: $e');
            }
          }
        } catch (e) {
          Logger.e('toRouteModel: Общая ошибка при обработке фото: $e');
        }
      }

      Logger.d('toRouteModel: Точка "${p.title}": обработано ${localPhotos.length} из ${p.photos.length} фото');

      routePoints.add(
        RoutePoint(
          name: p.title,
          description: p.description,
          latitude: p.point.latitude,
          longitude: p.point.longitude,
          tests: p.tests,
          photos: localPhotos,
        ),
      );
    }

    final routeModel = RouteModel(
      id: id,
      title: title,
      description: description,
      whyThisRoute: whyThisRoute,
      points: routePoints,
      taskCount: points.length,
    );

    return routeModel;
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
