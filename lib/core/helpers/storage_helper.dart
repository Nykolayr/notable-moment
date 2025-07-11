import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:notable_moments/core/helpers/image_error_handler.dart';

class StorageHelper {
  static final _storage = FirebaseStorage.instance;
  static const _photoPath = 'photos';

  /// Uploads a file to Firebase Storage and returns the download URL
  static Future<String> uploadFile(File file) async {
    try {
      final ref = _storage.ref(_photoPath).child(_generateFileName(file));
      debugPrint('StorageHelper -- uploadFile ref: $ref');
      
      // Получаем актуальный токен перед загрузкой
      await _ensureValidToken();
      
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageHelper -- uploadFile error: $e');
      rethrow;
    }
  }

  /// Uploads multiple files to Firebase Storage and returns their download URLs
  static Future<List<String>> uploadFiles(List<File> files) async {
    try {
      return await Future.wait(files.map(uploadFile));
    } catch (e) {
      debugPrint('StorageHelper -- uploadFiles error: $e');
      rethrow;
    }
  }

  /// Deletes a file from Firebase Storage
  static Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      
      // Получаем актуальный токен перед удалением
      await _ensureValidToken();
      
      await ref.delete();
    } catch (e) {
      debugPrint('StorageHelper -- deleteFile error: $e');
      rethrow;
    }
  }

  /// Обновляет токен аутентификации для Firebase Storage
  static Future<void> _ensureValidToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Принудительно обновляем токен
        await user.getIdToken(true);
      }
    } catch (e) {
      debugPrint('StorageHelper -- _ensureValidToken error: $e');
      // Не выбрасываем ошибку, так как это может быть не критично
    }
  }

  /// Получает обновленный URL для файла с новым токеном
  static Future<String?> getRefreshedDownloadUrl(String fileUrl) async {
    try {
      if (!fileUrl.contains('firebasestorage.googleapis.com')) {
        return fileUrl;
      }

      final ref = _storage.refFromURL(fileUrl);
      
      // Получаем актуальный токен
      await _ensureValidToken();
      
      // Получаем новый URL с обновленным токеном
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageHelper -- getRefreshedDownloadUrl error: $e');
      
      // Пытаемся обработать ошибку через ImageErrorHandler
      if (ImageErrorHandler.isTokenExpiredError(e)) {
        return await ImageErrorHandler.createRefreshedUrl(fileUrl);
      }
      
      return null;
    }
  }

  /// Обрабатывает ошибку и пытается получить обновленный URL
  static Future<String?> handleStorageError(String fileUrl, dynamic error) async {
    if (ImageErrorHandler.isTokenExpiredError(error)) {
      debugPrint('StorageHelper: Token expired error detected, attempting to refresh');
      return await ImageErrorHandler.createRefreshedUrl(fileUrl);
    }
    return null;
  }

  static String _generateFileName(File file) {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    return fileName;
  }
}
