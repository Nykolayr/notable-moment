import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/core/helpers/storage_helper.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/utils/yandex_disk_upload.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RoutesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'routes';

  CollectionReference<Map<String, dynamic>> get _routesCollection => _firestore.collection(_collection);

  // Метод для инициализации сервиса
  Future<void> init() async {
    await ensureYandexDiskFolder();
  }

  // Проверяет наличие папки на Яндекс.Диске и делает её публичной
  Future<void> ensureYandexDiskFolder() async {
    try {
      final token = await YandexDiskUploader.getValidToken();
      await YandexDiskUploader.ensurePublicFolder(token);
    } catch (e) {
      Logger.e('routesService -- ensureYandexDiskFolder error: $e');
    }
  }

  Future<Either<String, RouteAdminModel>> createRoute({
    required String title,
    required String description,
    required String url,
    required String whyThisRoute,
    required List<PointAdminModel> points,
    bool isDraft = false,
    required Polyline polyline,
  }) async {
    try {
      final docRef = _routesCollection.doc();
      final processedPoints = await _processPointPhotos(points);

      final route = RouteAdminModel(
        id: docRef.id,
        order: DateTime.now().millisecondsSinceEpoch,
        title: title.trim(),
        description: description.trim(),
        url: url.trim(),
        whyThisRoute: whyThisRoute.trim(),
        points: processedPoints,
        isDraft: isDraft,
        polyline: polyline,
      );

      final routeData = route.toMap();
      routeData['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(routeData);
      return Right(route);
    } catch (e) {
      Logger.e('routesService -- createRoute error: $e');

      return Left(e.toString());
    }
  }

  Future<List<String>> _uploadPhotosIfNeeded(List<String> photos) async {
    final token = await YandexDiskUploader.getValidToken();

    final photoUploads = photos.map((photo) async {
      if (photo.startsWith('http')) {
        // Если это уже URL, возвращаем его как есть
        Logger.i('routesService -- Используем URL: $photo');
        return photo;
      }

      // Для локальных файлов пытаемся загрузить на Яндекс.Диск
      try {
        Logger.i('routesService -- Локальный путь к файлу: $photo');
        final uploadedPath = await YandexDiskUploader.uploadPhotoToPublicFolder(
          filePath: photo,
          token: token,
          pointId: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        return uploadedPath ?? photo; // Если загрузка не удалась, возвращаем локальный путь
      } catch (e) {
        Logger.e('routesService -- _uploadPhotosIfNeeded error uploading file: $e');
        // При ошибке возвращаем локальный путь
        return photo;
      }
    }).toList();

    return await Future.wait(photoUploads);
  }

  Future<List<PointAdminModel>> _processPointPhotos(List<PointAdminModel> points) async {
    return await Future.wait<PointAdminModel>(
      points.map((point) async {
        final updatedPhotos = await _uploadPhotosIfNeeded(point.photos);
        return point.copyWith(photos: updatedPhotos);
      }),
    );
  }

  Future<void> updateRoute(RouteAdminModel route) async {
    try {
      // Get the existing route to compare photos
      final existingDoc = await _routesCollection.doc(route.id).get();
      final existingRoute = RouteAdminModel.fromMap(existingDoc.data()!);

      // Find and delete removed photos
      for (var i = 0; i < existingRoute.points.length; i++) {
        final existingPoint = existingRoute.points[i];
        final updatedPoint = route.points.firstWhere(
          (p) => p.point == existingPoint.point,
          orElse: () => existingPoint,
        );

        final removedPhotos = existingPoint.photos
            .where((photo) => !updatedPoint.photos.contains(photo) && photo.startsWith('http'))
            .toList();

        for (final photo in removedPhotos) {
          try {
            await StorageHelper.deleteFile(photo);
          } catch (e) {
            Logger.e('routesService -- updateRoute error deleting photo: $e');
            // Продолжаем выполнение даже если не удалось удалить фото
          }
        }
      }

      // Process and upload new photos
      final updatedPoints = await _processPointPhotos(route.points);
      final updatedRoute = route.copyWith(points: updatedPoints);

      await _routesCollection.doc(route.id).update(updatedRoute.toMap());
    } catch (e) {
      Logger.e('routesService -- updateRoute error: $e');
      rethrow;
    }
  }

  Future<void> updateRoutesInBatch(List<RouteAdminModel> routes) async {
    final batch = _firestore.batch();
    for (final route in routes) {
      batch.update(_routesCollection.doc(route.id), route.toMap());
    }
    await batch.commit();
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      // Get the route data before deletion
      final routeDoc = await _routesCollection.doc(routeId).get();
      if (routeDoc.exists) {
        final route = RouteAdminModel.fromMap(routeDoc.data()!);

        // Collect all photo URLs that need to be deleted
        final photosToDelete =
            route.points.expand((point) => point.photos).where((photo) => photo.startsWith('http')).toList();

        // Delete all photos in parallel with error handling
        await Future.wait(
          photosToDelete.map((photo) async {
            try {
              await StorageHelper.deleteFile(photo);
            } catch (e) {
              Logger.e('routesService -- deleteRoute error deleting photo: $e');
              // Продолжаем выполнение даже если не удалось удалить фото
            }
          }),
        );
      }

      // Delete the route document
      await _routesCollection.doc(routeId).delete();
    } catch (e) {
      Logger.e('routesService -- deleteRoute error: $e');
      rethrow;
    }
  }

  Stream<List<RouteAdminModel>> watchRoutes() {
    return _routesCollection.orderBy('order', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RouteAdminModel.fromMap(doc.data())).toList();
    });
  }

  Future<List<RouteAdminModel>> getRoutes() async {
    final snapshot = await _routesCollection.orderBy('order', descending: true).get();
    return snapshot.docs.map((doc) => RouteAdminModel.fromMap(doc.data())).toList();
  }

  Future<void> clearAllPhotos() async {
    try {
      Logger.i('routesService -- clearAllPhotos: начало очистки всех фото');

      // Получаем все маршруты
      final routes = await getRoutes();

      // Очищаем фото у всех точек
      final updatedRoutes = routes.map((route) {
        final updatedPoints = route.points.map((point) => point.copyWith(photos: [])).toList();
        return route.copyWith(points: updatedPoints);
      }).toList();

      // Сохраняем изменения на бэкенде
      final batch = _firestore.batch();
      for (final route in updatedRoutes) {
        batch.update(_routesCollection.doc(route.id), route.toMap());
      }
      await batch.commit();

      Logger.i('routesService -- clearAllPhotos: все фото успешно очищены');
    } catch (e) {
      Logger.e('routesService -- clearAllPhotos error: $e');
      rethrow;
    }
  }
}
