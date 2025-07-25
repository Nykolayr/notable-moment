import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_image.dart';

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

  void _showPhotoModal(int index) {
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
                  _photos[index].path,
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
                onPressed: () {
                  setState(() {
                    _photos.removeAt(index);
                  });
                  widget.onPhotosChanged(_photos);
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
            itemBuilder: (context, index) => AppGestureDetector(
              onTap: () => _showPhotoModal(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppImage(
                  _photos[index].path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
