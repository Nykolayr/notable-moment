import 'package:flutter/foundation.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';

/// Глобальный менеджер для управления жизненным циклом Yandex Maps
/// Предотвращает двойную инициализацию плагина
class YandexMapsManager {
  static final YandexMapsManager _instance = YandexMapsManager._internal();
  factory YandexMapsManager() => _instance;
  YandexMapsManager._internal();

  bool _isStarted = false;
  int _activeMapsCount = 0;
  bool _isInitializing = false;

  /// Запускает Yandex Maps если еще не запущен
  void start() {
    try {
      if (_isInitializing) {
        debugPrint('YandexMapsManager: Already initializing, skipping');
        return;
      }
      
      if (!_isStarted) {
        _isInitializing = true;
        debugPrint('YandexMapsManager: Starting mapkit');
        mapkit.onStart();
        _isStarted = true;
        _isInitializing = false;
      }
      _activeMapsCount++;
      debugPrint('YandexMapsManager: Active maps count: $_activeMapsCount');
    } catch (e) {
      _isInitializing = false;
      debugPrint('YandexMapsManager: Error starting mapkit: $e');
      // Не выбрасываем ошибку, чтобы не прерывать работу приложения
    }
  }

  /// Останавливает Yandex Maps если нет активных карт
  void stop() {
    try {
      _activeMapsCount--;
      debugPrint('YandexMapsManager: Active maps count: $_activeMapsCount');
      
      if (_activeMapsCount <= 0) {
        _activeMapsCount = 0;
        if (_isStarted) {
          debugPrint('YandexMapsManager: Stopping mapkit');
          mapkit.onStop();
          _isStarted = false;
        }
      }
    } catch (e) {
      debugPrint('YandexMapsManager: Error stopping mapkit: $e');
      // Сбрасываем состояние в случае ошибки
      _activeMapsCount = 0;
      _isStarted = false;
    }
  }

  /// Принудительно останавливает Yandex Maps
  void forceStop() {
    try {
      debugPrint('YandexMapsManager: Force stopping mapkit');
      mapkit.onStop();
      _isStarted = false;
      _activeMapsCount = 0;
      _isInitializing = false;
    } catch (e) {
      debugPrint('YandexMapsManager: Error force stopping mapkit: $e');
      // Сбрасываем состояние в случае ошибки
      _isStarted = false;
      _activeMapsCount = 0;
      _isInitializing = false;
    }
  }

  /// Проверяет, запущен ли Yandex Maps
  bool get isStarted => _isStarted;

  /// Возвращает количество активных карт
  int get activeMapsCount => _activeMapsCount;

  /// Проверяет, инициализируется ли карта в данный момент
  bool get isInitializing => _isInitializing;
} 