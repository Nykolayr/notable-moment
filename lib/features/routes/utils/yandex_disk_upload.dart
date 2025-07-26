import 'dart:convert';
import 'dart:io';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class YandexDiskUploader {
  static const String directToken = 'y0__xCw3KHvARjklzkg4I_N9ROv9a7sI_TuU4lR_RCZchM2mMFcXQ'; // Обновленный токен

  // Получение актуального токена
  static Future<String> getValidToken() async {
    return directToken;
  }

  // Создание и публикация папки
  static Future<void> ensurePublicFolder(String accessToken) async {
    const folderPath = '/notable_moments';

    Logger.i('Проверка существования папки: $folderPath');

    // Проверяем существование папки
    final checkResponse = await http.get(
      Uri.parse('https://cloud-api.yandex.net/v1/disk/resources?path=${Uri.encodeComponent(folderPath)}'),
      headers: {
        'Authorization': 'OAuth $accessToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'NotableMoments/1.0',
        'X-Requested-With': 'XMLHttpRequest'
      },
    );

    Logger.i('Ответ на проверку папки: ${checkResponse.statusCode}');
    Logger.i('Тело ответа: ${checkResponse.body}');

    // Если папки нет, создаём её
    if (checkResponse.statusCode == 404) {
      Logger.i('Папка не найдена, создаём новую');

      final createResponse = await http.put(
        Uri.parse('https://cloud-api.yandex.net/v1/disk/resources?path=${Uri.encodeComponent(folderPath)}'),
        headers: {
          'Authorization': 'OAuth $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'NotableMoments/1.0',
          'X-Requested-With': 'XMLHttpRequest'
        },
      );

      Logger.i('Ответ на создание папки: ${createResponse.statusCode}');
      Logger.i('Тело ответа: ${createResponse.body}');

      if (createResponse.statusCode == 201) {
        Logger.i('Папка успешно создана: $folderPath');

        // Публикуем только что созданную папку
        await _publishFolder(folderPath, accessToken);
      } else {
        Logger.e('Ошибка создания папки: ${createResponse.statusCode} - ${createResponse.body}');
        return;
      }
    } else if (checkResponse.statusCode == 200) {
      Logger.i('Папка уже существует');

      // Проверяем, опубликована ли папка
      try {
        final responseData = jsonDecode(checkResponse.body);
        if (responseData['public_url'] != null) {
          Logger.i('Папка уже опубликована. Публичная ссылка: ${responseData['public_url']}');
        } else {
          Logger.i('Папка существует, но не опубликована. Публикуем...');
          await _publishFolder(folderPath, accessToken);
        }
      } catch (e) {
        Logger.e('Ошибка при проверке публикации папки: $e');
        // На всякий случай пытаемся опубликовать
        await _publishFolder(folderPath, accessToken);
      }
    } else {
      Logger.e('Ошибка при проверке папки: ${checkResponse.statusCode} - ${checkResponse.body}');
    }
  }

  // Вспомогательный метод для публикации папки
  static Future<void> _publishFolder(String folderPath, String accessToken) async {
    Logger.i('Публикуем папку: $folderPath');

    final publishResponse = await http.put(
      Uri.parse('https://cloud-api.yandex.net/v1/disk/resources/publish?path=${Uri.encodeComponent(folderPath)}'),
      headers: {
        'Authorization': 'OAuth $accessToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'NotableMoments/1.0',
        'X-Requested-With': 'XMLHttpRequest'
      },
    );

    Logger.i('Ответ на публикацию папки: ${publishResponse.statusCode}');
    Logger.i('Тело ответа: ${publishResponse.body}');

    if (publishResponse.statusCode == 200) {
      try {
        final responseData = jsonDecode(publishResponse.body);
        final publicUrl = responseData['public_url'];
        Logger.i('Папка успешно опубликована: $folderPath');
        Logger.i('Публичная ссылка на папку: $publicUrl');
      } catch (e) {
        Logger.e('Ошибка при получении публичной ссылки: $e');
      }
    } else {
      Logger.e('Ошибка публикации папки: ${publishResponse.statusCode} - ${publishResponse.body}');
    }
  }

  // Загрузка фотографии в публичную папку
  static Future<String?> uploadPhotoToPublicFolder({
    required String filePath,
    required String token,
    required String pointId,
  }) async {
    try {
      // Получаем актуальный токен
      final validToken = await getValidToken();

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_point_${pointId}_${path.basename(filePath)}';
      final remotePath = '/notable_moments/$fileName';

      Logger.i('Начинаем загрузку файла: $filePath');
      Logger.i('Целевой путь на Яндекс.Диске: $remotePath');
      Logger.i('Используем токен: ${validToken.substring(0, 10)}...');

      // Проверяем существование файла
      final file = File(filePath);
      if (!await file.exists()) {
        Logger.e('Файл не существует: $filePath');
        return null;
      }

      final fileSize = await file.length();
      Logger.i('Размер файла: $fileSize байт');

      if (fileSize == 0) {
        Logger.e('Файл пустой: $filePath');
        return null;
      }

      // Получаем URL для загрузки
      try {
        final getUrlResponse = await http.get(
          Uri.parse(
            'https://cloud-api.yandex.net/v1/disk/resources/upload?path=${Uri.encodeComponent(remotePath)}&overwrite=true',
          ),
          headers: {
            'Authorization': 'OAuth $validToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'User-Agent': 'NotableMoments/1.0',
            'X-Requested-With': 'XMLHttpRequest'
          },
        );

        Logger.i('Ответ на запрос URL для загрузки: ${getUrlResponse.statusCode}');
        Logger.i('Тело ответа: ${getUrlResponse.body}');

        if (getUrlResponse.statusCode != 200) {
          Logger.e('Ошибка получения URL для загрузки: ${getUrlResponse.statusCode} - ${getUrlResponse.body}');
          return null;
        }

        final uploadUrl = jsonDecode(getUrlResponse.body)['href'];
        Logger.i('Получен URL для загрузки: $uploadUrl');

        // Загружаем файл
        final bytes = await file.readAsBytes();
        Logger.i('Прочитано байт из файла: ${bytes.length}');

        final uploadResponse = await http.put(
          Uri.parse(uploadUrl),
          headers: {'Content-Type': 'image/jpeg', 'User-Agent': 'NotableMoments/1.0'},
          body: bytes,
        );

        Logger.i('Ответ на загрузку файла: ${uploadResponse.statusCode}');
        Logger.i('Тело ответа: ${uploadResponse.body}');

        if (uploadResponse.statusCode != 201) {
          Logger.e('Ошибка загрузки файла: ${uploadResponse.statusCode} - ${uploadResponse.body}');
          return null;
        }

        Logger.i('Файл успешно загружен: $remotePath');

        // Публикуем файл для обеспечения доступа к нему
        final publishResponse = await http.put(
          Uri.parse('https://cloud-api.yandex.net/v1/disk/resources/publish?path=${Uri.encodeComponent(remotePath)}'),
          headers: {
            'Authorization': 'OAuth $validToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'User-Agent': 'NotableMoments/1.0',
            'X-Requested-With': 'XMLHttpRequest'
          },
        );

        Logger.i('Ответ на публикацию файла: ${publishResponse.statusCode}');

        if (publishResponse.statusCode != 200) {
          Logger.e('Ошибка публикации файла: ${publishResponse.statusCode}');
        } else {
          Logger.i('Файл успешно опубликован');
        }

        // Возвращаем путь к файлу на Яндекс.Диске
        return remotePath;
      } catch (e) {
        Logger.e('Ошибка HTTP запроса: $e');
        return null;
      }
    } catch (e) {
      Logger.e('Ошибка при загрузке фото: $e');
      return null;
    }
  }
}
