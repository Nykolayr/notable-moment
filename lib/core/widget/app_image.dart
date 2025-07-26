import 'dart:io';
import 'dart:async';

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

class _AppImageState extends State<AppImage> {
  String? _currentUrl;
  bool _isRetrying = false;
  bool _hasTimedOut = false;
  Timer? _timeoutTimer;
  Object? _timeoutError;

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
    
    // Проверяем, не является ли это путем на Яндекс.Диске
    if (url.contains('/notable_moments/')) {
      Logger.e('isNetwork: Обнаружен путь Яндекс.Диска: $url, но файл должен быть скачан локально!');
      return false; // Считаем, что это локальный файл, чтобы избежать ошибок
    }
    
    return url.startsWith('http');
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

  Widget get image => frame(
        _hasTimedOut
            ? errorBuilder(context, _timeoutError ?? 'Timeout', null)
            : (isNetwork
                ? CachedNetworkImage(
                    imageUrl: _currentUrl!,
                    fit: widget.fit,
                    width: widget.width,
                    height: widget.height,
                    placeholder: (BuildContext context, String url) => AppLoadingIcon(size: widget.loadingSize),
                    errorWidget: _errorWidget,
                    httpHeaders: const {
                      'Cache-Control': 'max-age=3600',
                    },
                    maxWidthDiskCache: 1000,
                    maxHeightDiskCache: 1000,
                  )
                : Image.file(
                    File(_currentUrl!),
                    width: widget.width,
                    height: widget.height,
                    fit: widget.fit,
                    errorBuilder: errorBuilder,
                  )),
      );

  @override
  Widget build(BuildContext context) {
    return widget.borderRadius == null
        ? image
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius!), //
            child: image,
          );
  }
}
