import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  /// Обновляет токен аутентификации Firebase
  static Future<String?> refreshFirebaseToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('ImageErrorHandler: No authenticated user');
        return null;
      }

      // Принудительно обновляем токен
      final token = await user.getIdToken(true);
      debugPrint('ImageErrorHandler: Token refreshed successfully');
      return token;
    } catch (e) {
      debugPrint('ImageErrorHandler: Error refreshing token: $e');
      return null;
    }
  }

  /// Создает новый URL с обновленным токеном для Firebase Storage
  static Future<String?> createRefreshedUrl(String originalUrl) async {
    try {
      if (!originalUrl.contains('firebasestorage.googleapis.com')) {
        return originalUrl;
      }

      final token = await refreshFirebaseToken();
      if (token == null) return null;

      final uri = Uri.parse(originalUrl);
      final newQueryParams = Map<String, String>.from(uri.queryParameters);
      newQueryParams['token'] = token;
      
      final newUri = uri.replace(queryParameters: newQueryParams);
      return newUri.toString();
    } catch (e) {
      debugPrint('ImageErrorHandler: Error creating refreshed URL: $e');
      return null;
    }
  }

  /// Обрабатывает ошибку изображения и возвращает обновленный URL если возможно
  static Future<String?> handleImageError(String url, dynamic error) async {
    if (isTokenExpiredError(error)) {
      debugPrint('ImageErrorHandler: Token expired error detected, attempting to refresh');
      return await createRefreshedUrl(url);
    }
    return null;
  }
} 