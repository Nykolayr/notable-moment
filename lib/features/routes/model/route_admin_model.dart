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
import 'package:notable_moments/core/constants/app_constants.dart';

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
            continue;
          }

          // Извлекаем имя файла из пути на Яндекс.Диске
          final fileName = photoUrl.split('/').last;
          final directory = await getApplicationDocumentsDirectory();

          // Проверяем файл в папке notable (где сохраняются локальные копии)
          final localFile = io.File('${directory.path}/notable/$fileName');

          // Также проверяем файл в корневой папке (для обратной совместимости)
          final rootFile = io.File('${directory.path}/$fileName');

          if (await localFile.exists()) {
            // Если файл существует в папке notable, используем его
            localPhotos.add(localFile.path);
          } else if (await rootFile.exists()) {
            // Если файл существует в корневой папке, используем его
            localPhotos.add(rootFile.path);
          } else {
            try {
              // Получаем ссылку для скачивания напрямую
              final requestUrl =
                  'https://cloud-api.yandex.net/v1/disk/resources/download?path=${Uri.encodeComponent(photoUrl)}';

              final downloadUrlResponse = await http.get(
                Uri.parse(requestUrl),
                headers: {
                  'Authorization': 'OAuth $token',
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'User-Agent': 'NotableMoments/1.0',
                },
              );

              if (downloadUrlResponse.statusCode == 200) {
                final responseData = jsonDecode.jsonDecode(downloadUrlResponse.body);
                final downloadUrl = responseData['href'];

                // Скачиваем файл
                final fileResponse = await http.get(
                  Uri.parse(downloadUrl),
                  headers: {'User-Agent': 'NotableMoments/1.0'},
                );

                if (fileResponse.statusCode == 200) {
                  final bytes = fileResponse.bodyBytes;

                  // Создаем директорию notable, если она не существует
                  final notableDir = io.Directory('${directory.path}/notable');
                  if (!await notableDir.exists()) {
                    await notableDir.create(recursive: true);
                  }

                  // Сохраняем файл локально в папку notable
                  await localFile.writeAsBytes(bytes);
                  localPhotos.add(localFile.path);
                } else {
                  Logger.e('toRouteModel: Ошибка скачивания файла: ${fileResponse.statusCode}');
                  // Если не удалось скачать, оставляем путь на Яндекс.Диск
                  localPhotos.add(photoUrl);
                }
              } else {
                Logger.e('toRouteModel: Ошибка получения ссылки для скачивания: ${downloadUrlResponse.statusCode}');
                // Если не удалось получить ссылку, оставляем путь на Яндекс.Диск
                localPhotos.add(photoUrl);
              }
            } catch (e) {
              Logger.e('toRouteModel: Ошибка загрузки фото: $e');
              // В случае ошибки оставляем путь на Яндекс.Диск
              localPhotos.add(photoUrl);
            }
          }
        } catch (e) {
          Logger.e('toRouteModel: Общая ошибка при обработке фото: $e');
        }
      }

      routePoints.add(
        RoutePoint(
          name: p.title,
          description: p.description,
          latitude: p.latitude,
          longitude: p.longitude,
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

  // Быстрое преобразование с путями на Яндекс.Диск
  RouteModel toRouteModelFast() {
    return RouteModel(
      id: id,
      title: title,
      description: description,
      whyThisRoute: whyThisRoute,
      points: points
          .map(
            (p) => RoutePoint(
              name: p.title,
              description: p.description,
              latitude: p.latitude,
              longitude: p.longitude,
              tests: p.tests,
              photos: p.photos, // Оставляем пути на Яндекс.Диск
            ),
          )
          .toList(),
      taskCount: points.length,
    );
  }

  // Асинхронная замена путей на Яндекс.Диск на локальные пути
  Future<RouteModel> toRouteModelWithLocalPhotos() async {
    final localPoints = <RoutePoint>[];

    for (final point in points) {
      final localPhotos = <String>[];

      for (final photoPath in point.photos) {
        if (photoPath.contains('/notable_moments/')) {
          // Это путь на Яндекс.Диск, скачиваем файл
          try {
            final fileName = photoPath.split('/').last;
            final directory = await getApplicationDocumentsDirectory();
            final localPath = '${directory.path}/notable/$fileName';

            final localFile = io.File(localPath);
            if (await localFile.exists()) {
              localPhotos.add(localPath);
            } else {
              // Скачиваем с Яндекс.Диска
              final yandexDiskToken = AppConstants.yandexDiskToken;
              final requestUrl =
                  'https://cloud-api.yandex.net/v1/disk/resources/download?path=${Uri.encodeComponent(photoPath)}';
              final downloadUrlResponse = await http.get(
                Uri.parse(requestUrl),
                headers: {'Authorization': 'OAuth $yandexDiskToken'},
              );

              if (downloadUrlResponse.statusCode == 200) {
                final responseData = jsonDecode.jsonDecode(downloadUrlResponse.body);
                final downloadUrl = responseData['href'];
                final fileResponse = await http.get(Uri.parse(downloadUrl));

                if (fileResponse.statusCode == 200) {
                  // Создаем директорию если не существует
                  final localDirPath = '${directory.path}/notable';
                  await io.Directory(localDirPath).create(recursive: true);

                  // Сохраняем файл локально
                  await localFile.writeAsBytes(fileResponse.bodyBytes);
                  localPhotos.add(localPath);
                } else {
                  // Если не удалось скачать, НЕ добавляем путь в список
                  Logger.e(
                    'toRouteModelWithLocalPhotos: Ошибка скачивания: ${fileResponse.statusCode}, пропускаем файл',
                  );
                }
              } else {
                // Если не удалось получить ссылку, НЕ добавляем путь в список
                Logger.e(
                  'toRouteModelWithLocalPhotos: Ошибка получения ссылки: ${downloadUrlResponse.statusCode}, пропускаем файл',
                );
              }
            }
          } catch (e) {
            // В случае ошибки НЕ добавляем путь в список
            Logger.e('toRouteModelWithLocalPhotos: Ошибка обработки фото: $e, пропускаем файл');
          }
        } else {
          // Это уже локальный путь
          localPhotos.add(photoPath);
        }
      }

      localPoints.add(
        RoutePoint(
          name: point.title,
          description: point.description,
          latitude: point.latitude,
          longitude: point.longitude,
          tests: point.tests,
          photos: localPhotos,
        ),
      );
    }

    return RouteModel(
      id: id,
      title: title,
      description: description,
      whyThisRoute: whyThisRoute,
      points: localPoints,
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
