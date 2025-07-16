import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/core/helpers/storage_helper.dart';

class ImageErrorHandler {
  /// Проверяет, является ли ошибка связанной с истекшим токеном Firebase Storage
  static bool isTokenExpiredError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('412') ||
        errorString.contains('precondition failed') ||
        errorString.contains('token expired') ||
        errorString.contains('unauthorized');
  }

  /// Обрабатывает ошибку изображения и возвращает обновленный URL если возможно
  static Future<String?> handleImageError(String url, dynamic error) async {
    if (isTokenExpiredError(error)) {
      Logger.i('ImageErrorHandler: Token expired error detected, attempting to refresh via StorageHelper');
      return await StorageHelper.getRefreshedDownloadUrl(url);
    }
    return null;
  }
}
