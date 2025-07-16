import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class FirebaseTestHelper {
  /// Проверяет подключение к Firebase Auth
  static Future<bool> testAuthConnection() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Logger.i('FirebaseTestHelper: Auth connection successful, user: ${user.email}');
        return true;
      } else {
        Logger.w('FirebaseTestHelper: No authenticated user');
        return false;
      }
    } catch (e) {
      Logger.e('FirebaseTestHelper: Auth connection failed: $e');
      return false;
    }
  }

  /// Проверяет подключение к Firebase Storage
  static Future<bool> testStorageConnection() async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref('test-connection');

      // Пытаемся получить метаданные (это не создаст файл)
      await ref.getMetadata();
      Logger.i('FirebaseTestHelper: Storage connection successful');
      return true;
    } catch (e) {
      Logger.e('FirebaseTestHelper: Storage connection failed: $e');

      // Проверяем тип ошибки
      if (e.toString().contains('412')) {
        Logger.e('FirebaseTestHelper: Storage permissions error (412) - check service account');
      } else if (e.toString().contains('too-many-requests')) {
        Logger.e('FirebaseTestHelper: Too many requests - rate limiting');
      }

      return false;
    }
  }

  /// Полная диагностика Firebase
  static Future<Map<String, bool>> runDiagnostics() async {
    Logger.i('FirebaseTestHelper: Starting Firebase diagnostics...');

    final results = <String, bool>{};

    results['auth'] = await testAuthConnection();
    results['storage'] = await testStorageConnection();

    Logger.i('FirebaseTestHelper: Diagnostics completed: $results');
    return results;
  }
}
