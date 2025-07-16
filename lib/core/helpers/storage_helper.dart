import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class StorageHelper {
  static final _storage = FirebaseStorage.instance;
  static const _photoPath = 'photos';

  // Кэш для токена и времени его получения
  static String? _cachedToken;
  static DateTime? _tokenTimestamp;
  static const Duration _tokenCacheDuration = Duration(minutes: 30);

  // Кэш для обработанных URL'ов
  static final Map<String, String> _processedUrlsCache = {};
  static const Duration _urlCacheDuration = Duration(hours: 1);
  static final Map<String, DateTime> _urlCacheTimestamps = {};

  /// Uploads a file to Firebase Storage and returns the download URL
  static Future<String> uploadFile(File file) async {
    try {
      final ref = _storage.ref(_photoPath).child(_generateFileName(file));
      Logger.i('StorageHelper -- uploadFile ref: $ref');

      // Получаем актуальный токен перед загрузкой (с кэшированием)
      await _ensureValidToken();

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      Logger.e('StorageHelper -- uploadFile error: $e');

      // Если ошибка связана с правами доступа, возвращаем локальный путь
      if (e.toString().contains('412') || e.toString().contains('permissions')) {
        Logger.w('StorageHelper -- Firebase Storage permissions error, using local file path');
        return file.path;
      }

      rethrow;
    }
  }

  /// Uploads multiple files to Firebase Storage and returns their download URLs
  static Future<List<String>> uploadFiles(List<File> files) async {
    try {
      return await Future.wait(files.map(uploadFile));
    } catch (e) {
      Logger.e('StorageHelper -- uploadFiles error: $e');
      rethrow;
    }
  }

  /// Deletes a file from Firebase Storage
  static Future<void> deleteFile(String fileUrl) async {
    try {
      // Если это не Firebase URL, пропускаем удаление
      if (!fileUrl.contains('firebasestorage.googleapis.com')) {
        Logger.i('StorageHelper -- Skipping deletion of non-Firebase URL: $fileUrl');
        return;
      }

      final ref = _storage.refFromURL(fileUrl);

      // Получаем актуальный токен перед удалением (с кэшированием)
      await _ensureValidToken();

      await ref.delete();
    } catch (e) {
      Logger.e('StorageHelper -- deleteFile error: $e');

      // Не выбрасываем ошибку для не критичных операций
      if (e.toString().contains('412') || e.toString().contains('permissions')) {
        Logger.w('StorageHelper -- Firebase Storage permissions error, skipping deletion');
        return;
      }

      rethrow;
    }
  }

  /// Обновляет токен аутентификации для Firebase Storage с кэшированием
  static Future<void> _ensureValidToken() async {
    try {
      // Проверяем, не истек ли кэшированный токен
      if (_cachedToken != null && _tokenTimestamp != null) {
        final timeSinceToken = DateTime.now().difference(_tokenTimestamp!);
        if (timeSinceToken < _tokenCacheDuration) {
          // Убираем лог для уменьшения спама
          return;
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Принудительно обновляем токен только если кэш истек
        final newToken = await user.getIdToken(true);
        _cachedToken = newToken;
        _tokenTimestamp = DateTime.now();
        Logger.d('StorageHelper -- Token refreshed and cached');
      }
    } catch (e) {
      Logger.e('StorageHelper -- _ensureValidToken error: $e');

      // Если ошибка too-many-requests, используем кэшированный токен
      if (e.toString().contains('too-many-requests')) {
        Logger.w('StorageHelper -- Too many requests, using cached token if available');
        if (_cachedToken != null) {
          return;
        }
      }

      // Не выбрасываем ошибку, так как это может быть не критично
    }
  }

  /// Получает обновленный URL для файла с новым токеном
  static Future<String?> getRefreshedDownloadUrl(String fileUrl) async {
    try {
      if (!fileUrl.contains('firebasestorage.googleapis.com')) {
        return fileUrl;
      }

      // Проверяем кэш
      if (_processedUrlsCache.containsKey(fileUrl)) {
        final timestamp = _urlCacheTimestamps[fileUrl];
        if (timestamp != null && DateTime.now().difference(timestamp) < _urlCacheDuration) {
          // Убираем лог для уменьшения спама
          return _processedUrlsCache[fileUrl];
        }
      }

      final ref = _storage.refFromURL(fileUrl);

      // Получаем актуальный токен (с кэшированием)
      await _ensureValidToken();

      // Получаем новый URL с обновленным токеном
      final newUrl = await ref.getDownloadURL();

      // Кэшируем результат
      _processedUrlsCache[fileUrl] = newUrl;
      _urlCacheTimestamps[fileUrl] = DateTime.now();

      return newUrl;
    } catch (e) {
      Logger.e('StorageHelper -- getRefreshedDownloadUrl error: $e');

      // Если ошибка связана с правами доступа, возвращаем исходный URL
      if (e.toString().contains('412') || e.toString().contains('permissions')) {
        Logger.w('StorageHelper -- Firebase Storage permissions error, returning original URL');
        // Кэшируем результат ошибки
        _processedUrlsCache[fileUrl] = fileUrl;
        _urlCacheTimestamps[fileUrl] = DateTime.now();
        return fileUrl;
      }

      // Если ошибка too-many-requests, возвращаем исходный URL
      if (e.toString().contains('too-many-requests')) {
        Logger.w('StorageHelper -- Too many requests error, returning original URL');
        // Кэшируем результат ошибки
        _processedUrlsCache[fileUrl] = fileUrl;
        _urlCacheTimestamps[fileUrl] = DateTime.now();
        return fileUrl;
      }

      // Для любых других ошибок возвращаем исходный URL
      Logger.w('StorageHelper -- Unknown error, returning original URL');
      // Кэшируем результат ошибки
      _processedUrlsCache[fileUrl] = fileUrl;
      _urlCacheTimestamps[fileUrl] = DateTime.now();
      return fileUrl;
    }
  }

  /// Обрабатывает ошибку и пытается получить обновленный URL
  static Future<String?> handleStorageError(String fileUrl, dynamic error) async {
    // Если ошибка связана с правами доступа, возвращаем исходный URL
    if (error.toString().contains('412') || error.toString().contains('permissions')) {
      Logger.w('StorageHelper: Firebase Storage permissions error, returning original URL');
      return fileUrl;
    }

    // Если ошибка too-many-requests, возвращаем исходный URL
    if (error.toString().contains('too-many-requests')) {
      Logger.w('StorageHelper: Too many requests error, returning original URL');
      return fileUrl;
    }

    // Для любых других ошибок возвращаем исходный URL
    Logger.w('StorageHelper: Unknown error, returning original URL');
    return fileUrl;
  }

  static String _generateFileName(File file) {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    return fileName;
  }
}
