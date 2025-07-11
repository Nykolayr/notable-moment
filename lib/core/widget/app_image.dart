import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:notable_moments/core/helpers/image_error_handler.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_loading_icon.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _currentUrl = widget.url;
      _isRetrying = false;
    }
  }

  bool get isNetwork => _currentUrl?.startsWith('http') ?? false;

  Widget frame(Widget child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius == null ? null : BorderRadius.circular(widget.borderRadius!),
        ),
        child: child,
      );

  Widget errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) => 
      Center(child: AppIcon.imageNo.svgPricture);

  Widget loadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) => 
      loadingProgress == null //
          ? child
          : AppLoadingIcon(size: widget.loadingSize);

  /// Обработчик ошибок для сетевых изображений
  Widget _errorWidget(BuildContext context, String url, dynamic error) {
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
    // Показываем спецсимвол вместо svg-заглушки
    return const Center(child: Text('🖼️', style: TextStyle(fontSize: 48)));
  }

  Widget get image => frame(
        isNetwork
            ? CachedNetworkImage(
                imageUrl: _currentUrl!,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
                placeholder: (BuildContext context, String url) => AppLoadingIcon(size: widget.loadingSize),
                errorWidget: _errorWidget,
                // Добавляем дополнительные опции для лучшей обработки ошибок
                httpHeaders: const {
                  'Cache-Control': 'max-age=3600',
                },
                // Увеличиваем время ожидания
                maxWidthDiskCache: 1000,
                maxHeightDiskCache: 1000,
              )
            : Image.file(
                File(_currentUrl!),
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                errorBuilder: errorBuilder,
              ),
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
