import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_image.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class PhotoGridWidget extends StatefulWidget {
  final List<XFile> photos;
  final ValueChanged<List<XFile>> onPhotosChanged;

  const PhotoGridWidget({
    super.key,
    required this.photos,
    required this.onPhotosChanged,
  });

  @override
  State<PhotoGridWidget> createState() => _PhotoGridWidgetState();
}

class _PhotoGridWidgetState extends State<PhotoGridWidget> {
  late List<XFile> _photos;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.photos);
    Logger.d('PhotoGridWidget: Инициализация с ${_photos.length} фото');
  }

  @override
  void didUpdateWidget(PhotoGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photos != widget.photos) {
      _photos = List.from(widget.photos);
    }
  }

  Future<void> _addPhotos() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _photos.addAll(picked);
      });
      widget.onPhotosChanged(_photos);
    }
  }

  // Метод для получения локального пути файла
  String _getLocalPath(String photoPath) {
    // Если это уже локальный путь, возвращаем как есть
    if (photoPath.startsWith('/data/') || photoPath.startsWith('/storage/')) {
      return photoPath;
    }

    // Если это путь Яндекс.Диска, извлекаем имя файла и возвращаем локальный путь
    if (photoPath.contains('/notable_moments/')) {
      final fileName = photoPath.split('/').last;
      return '/data/user/0/com.notablemoments.app/app_flutter/$fileName';
    }

    // Если это URL, возвращаем как есть (для сетевых изображений)
    return photoPath;
  }

  // Метод для удаления локального файла
  Future<void> _deleteLocalFile(String photoPath) async {
    try {
      // Если это локальный файл (не с Яндекс.Диска), удаляем его
      if (photoPath.startsWith('/data/') || photoPath.startsWith('/storage/')) {
        final file = File(photoPath);
        if (await file.exists()) {
          await file.delete();
          Logger.d('PhotoGridWidget: Удален локальный файл: $photoPath');
        }
      }
    } catch (e) {
      Logger.e('PhotoGridWidget: Ошибка при удалении локального файла: $e');
    }
  }

  void _showPhotoModal(int index) {
    final photoPath = _photos[index].path;
    final localPath = _getLocalPath(photoPath);

    Logger.d('PhotoGridWidget: Показываем фото - оригинальный путь: $photoPath, локальный путь: $localPath');

    showDialog(
      context: context,
      builder: (context) => Material(
        color: Colors.black,
        type: MaterialType.canvas,
        child: Stack(
          children: [
            Center(
              child: SizedBox.expand(
                child: AppImage(
                  localPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Кнопка удалить (слева сверху)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 32),
                onPressed: () async {
                  final photoToDelete = _photos[index];
                  final photoPathToDelete = photoToDelete.path;

                  setState(() {
                    _photos.removeAt(index);
                  });
                  widget.onPhotosChanged(_photos);

                  // Удаляем локальный файл, если это локальный путь
                  await _deleteLocalFile(photoPathToDelete);

                  Navigator.of(context).pop();
                },
              ),
            ),
            // Кнопка закрыть (справа сверху)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_photos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final photoPath = _photos[index].path;
              final localPath = _getLocalPath(photoPath);

              return AppGestureDetector(
                onTap: () => _showPhotoModal(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(
                    localPath,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        AppButton(
          title: 'Добавить фото',
          onTap: _addPhotos,
        ),
      ],
    );
  }
}
