import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:notable_moments/core/helpers/image_error_handler.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/widget/app_loading_icon.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImage extends StatefulWidget {
  const AppImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.loadingSize = 16,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double? borderRadius;
  final double loadingSize;

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> with AutomaticKeepAliveClientMixin {
  String? _currentUrl;
  bool _isRetrying = false;
  bool _hasTimedOut = false;
  Timer? _timeoutTimer;
  Object? _timeoutError;
  Widget? _cachedWidget;

  // Глобальный кэш для локальных изображений
  static final Map<String, Uint8List> _imageBytesCache = {};
  static final Map<String, Image> _imageCache = {};

  @override
  bool get wantKeepAlive => true; // Сохраняем состояние виджета при прокрутке

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _startTimeout();
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _currentUrl = widget.url;
      _isRetrying = false;
      _hasTimedOut = false;
      _timeoutError = null;
      _cachedWidget = null; // Сбрасываем кэшированный виджет при изменении URL
      _startTimeout();
    }
  }

  void _startTimeout() {
    _timeoutTimer?.cancel();
    if (isNetwork) {
      _timeoutTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !_hasTimedOut) {
          setState(() {
            _hasTimedOut = true;
            _timeoutError = 'Timeout: изображение не загрузилось за 3 секунды';
          });
          Logger.e('Timeout: изображение ${_currentUrl ?? ''} не загрузилось за 3 секунды');
        }
      });
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  bool get isNetwork {
    final url = _currentUrl ?? '';

    // Проверяем, не является ли это локальным файлом в папке notable_moments
    if (url.contains('/notable_moments/') || url.contains('/app_flutter/notable_moments/')) {
      Logger.d('isNetwork: Обнаружен локальный файл в папке notable_moments: $url');
      return false; // Считаем, что это локальный файл
    }

    return url.startsWith('http');
  }

  // Метод для получения кэшированного локального изображения
  Future<Widget> _getCachedLocalImage(String filePath) async {
    Logger.d('AppImage: Ищем локальный файл: $filePath');

    // Проверяем кэш изображений
    if (_imageCache.containsKey(filePath)) {
      Logger.d('AppImage: Файл найден в кэше изображений: $filePath');
      return _imageCache[filePath]!;
    }

    // Проверяем кэш байтов
    if (_imageBytesCache.containsKey(filePath)) {
      Logger.d('AppImage: Файл найден в кэше байтов: $filePath');
      final image = Image.memory(
        _imageBytesCache[filePath]!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: errorBuilder,
      );
      _imageCache[filePath] = image;
      return image;
    }

    // Загружаем новое изображение
    try {
      final file = File(filePath);
      Logger.d('AppImage: Проверяем существование файла: $filePath');
      if (await file.exists()) {
        final fileSize = await file.length();
        Logger.d('AppImage: Файл существует, размер: $fileSize байт');
        final bytes = await file.readAsBytes();

        // Кэшируем байты
        _imageBytesCache[filePath] = bytes;

        // Создаем изображение
        final image = Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: errorBuilder,
        );

        // Кэшируем изображение
        _imageCache[filePath] = image;

        // Ограничиваем размер кэша (максимум 50 изображений)
        if (_imageBytesCache.length > 50) {
          final firstKey = _imageBytesCache.keys.first;
          _imageBytesCache.remove(firstKey);
          _imageCache.remove(firstKey);
        }

        return image;
      } else {
        Logger.e('AppImage: Файл не существует: $filePath');
        return _getErrorImage();
      }
    } catch (e) {
      Logger.e('AppImage: Ошибка загрузки изображения: $e');
      return _getErrorImage();
    }
  }

  // Метод для получения изображения ошибки
  Widget _getErrorImage() {
    return Center(
      child: SvgPicture.asset(
        AppIcon.imageNo,
        width: 64,
        height: 64,
        colorFilter: const ColorFilter.mode(Color(0xFFF4F4F6), BlendMode.srcIn),
      ),
    );
  }

  Widget frame(Widget child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius == null ? null : BorderRadius.circular(widget.borderRadius!),
        ),
        child: child,
      );

  Widget errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    // ignore: avoid_print
    print('Ошибка загрузки локального изображения: $error');
    return Center(
      child: SvgPicture.asset(
        AppIcon.imageNo,
        width: 64,
        height: 64,
        colorFilter: const ColorFilter.mode(Color(0xFFF4F4F6), BlendMode.srcIn),
      ),
    );
  }

  Widget loadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (_hasTimedOut) {
      return errorBuilder(context, _timeoutError ?? 'Timeout', null);
    }
    if (loadingProgress == null) {
      _timeoutTimer?.cancel(); // загрузка завершена
      return child;
    }
    return AppLoadingIcon(size: widget.loadingSize);
  }

  /// Обработчик ошибок для сетевых изображений
  Widget _errorWidget(BuildContext context, String url, dynamic error) {
    Logger.e('Ошибка загрузки сетевого изображения ($url): $error');
    // Проверяем, является ли это ошибкой истекшего токена
    if (ImageErrorHandler.isTokenExpiredError(error)) {
      if (!_isRetrying) {
        _isRetrying = true;
        ImageErrorHandler.handleImageError(url, error).then((newUrl) {
          if (!mounted) return;
          if (newUrl != null) {
            setState(() {
              _currentUrl = newUrl;
            });
          }
        });
      }
    }
    // SVG крупный и светло-серый
    return Center(
      child: SvgPicture.asset(
        AppIcon.imageNo,
        width: 64,
        height: 64,
        colorFilter: const ColorFilter.mode(Color(0xFFF4F4F6), BlendMode.srcIn),
      ),
    );
  }

  Widget get image {
    // Если у нас есть кэшированный виджет, возвращаем его
    if (_cachedWidget != null) {
      return frame(_cachedWidget!);
    }

    final widget = _hasTimedOut
        ? errorBuilder(context, _timeoutError ?? 'Timeout', null)
        : (isNetwork
            ? CachedNetworkImage(
                imageUrl: _currentUrl!,
                fit: this.widget.fit,
                width: this.widget.width,
                height: this.widget.height,
                placeholder: (BuildContext context, String url) => AppLoadingIcon(size: this.widget.loadingSize),
                errorWidget: _errorWidget,
                httpHeaders: const {
                  'Cache-Control': 'max-age=3600',
                },
                maxWidthDiskCache: 1000,
                maxHeightDiskCache: 1000,
              )
            : FutureBuilder<Widget>(
                future: _getCachedLocalImage(_currentUrl!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AppLoadingIcon(size: this.widget.loadingSize);
                  } else if (snapshot.hasError) {
                    return errorBuilder(context, snapshot.error!, null);
                  } else if (snapshot.hasData) {
                    // Кэшируем готовый виджет
                    _cachedWidget = snapshot.data!;
                    return snapshot.data!;
                  } else {
                    return errorBuilder(context, 'Не удалось загрузить изображение', null);
                  }
                },
              ));

    return frame(widget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Необходимо для AutomaticKeepAliveClientMixin

    final imageWidget = widget.borderRadius == null
        ? image
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius!), //
            child: image,
          );

    // Оборачиваем в RepaintBoundary для оптимизации отрисовки
    return RepaintBoundary(child: imageWidget);
  }
}
