// lib/features/routes/edit_point_screen.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notable_moments/core/helpers/validator.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_checkbox.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';
import 'package:notable_moments/features/routes/widget/point_select_map_frame.dart';
import 'package:notable_moments/features/routes/widget/schedule_editor_widget.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/edit_test_screen.dart';
import 'package:notable_moments/features/routes/widget/photo_grid_widget.dart';
import 'package:notable_moments/features/routes/utils/yandex_disk_upload.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class EditPointScreen extends StatefulWidget {
  const EditPointScreen({super.key, required this.pointAdmin});
  final PointAdminModel? pointAdmin;

  @override
  State<EditPointScreen> createState() => _EditPointScreenState();
}

class _EditPointScreenState extends State<EditPointScreen> {
  bool isNew = true;
  Point? point;
  final _imagePicker = ImagePicker();
  bool _enableListViewScroll = true;
  List<XFile> _pickedPhotos = [];

  late final titleController = TextEditingController(text: widget.pointAdmin?.title);
  late final descriptionController = TextEditingController(text: widget.pointAdmin?.description);
  late final urlController = TextEditingController(text: widget.pointAdmin?.url);
  late final List<TextEditingController> phoneControllers =
      widget.pointAdmin?.phones.map((phone) => TextEditingController(text: phone)).toList() ??
          [TextEditingController()];
  late final List<String> photos = List.from(widget.pointAdmin?.photos ?? []);
  late WorkingHours schedule = widget.pointAdmin?.schedule ?? WorkingHours(periods: []);
  late bool isDraft = widget.pointAdmin?.isDraft ?? false;
  late List<QuestionTest> tests = widget.pointAdmin?.tests ?? [];

  YandexMapController? mapController;
  List<MapObject> mapObjects = [];

  @override
  void initState() {
    super.initState();
    isNew = widget.pointAdmin == null;
    if (!isNew) {
      point = widget.pointAdmin?.point;
      tests = widget.pointAdmin!.tests;
    }

    titleController.addListener(() => setState(() {}));
    descriptionController.addListener(() => setState(() {}));
    urlController.addListener(() => setState(() {}));
    for (var controller in phoneControllers) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    urlController.dispose();
    for (var controller in phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void addPhoneField() {
    setState(() {
      final controller = TextEditingController();
      controller.addListener(() => setState(() {}));
      phoneControllers.add(controller);
    });
  }

  void removePhoneField(int index) {
    setState(() {
      phoneControllers[index].dispose();
      phoneControllers.removeAt(index);
    });
  }

  Future<void> pickImage() async {
    if (photos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Максимум 3 фотографии')));
      return;
    }
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        photos.add(image.path);
      });
    }
  }

  void removeImage(int index) {
    appButtonDeleteDialog(
      context: context,
      title: 'Удалить фото',
      okText: 'Удалить',
      okStyle: AppButtonStyle.red,
      okCallBack: () => setState(() => photos.removeAt(index)),
    );
  }

  void updatePoint(Point p) {
    setState(() {
      point = p;
      mapObjects = [
        PlacemarkMapObject(
          mapId: const MapObjectId('edit_point'),
          point: p,
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/svg/placemark.svg'),
              scale: 1,
            ),
          ),
        ),
      ];
    });
    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: p, zoom: 15),
      ),
    );
  }

  bool get hasChanges {
    if (titleController.text != (widget.pointAdmin?.title ?? '')) return true;
    if (descriptionController.text != (widget.pointAdmin?.description ?? '')) return true;
    if (urlController.text != (widget.pointAdmin?.url ?? '')) return true;
    if (!ListEquality().equals(
      phoneControllers.map((e) => e.text).where((e) => e.isNotEmpty).toList(),
      widget.pointAdmin?.phones ?? [],
    )) {
      return true;
    }
    if (!ListEquality().equals(photos, widget.pointAdmin?.photos ?? [])) return true;
    if (schedule != (widget.pointAdmin?.schedule ?? WorkingHours(periods: []))) return true;
    if (isDraft != (widget.pointAdmin?.isDraft ?? true)) return true;
    if (point != widget.pointAdmin?.point) return true;
    return false;
  }

  bool get hasErrors {
    if (titleController.text.isEmpty) return true;
    for (final c in phoneControllers) {
      if (c.text.isNotEmpty && Validator.phoneMasked(c.text) != null) return true;
    }
    if (urlController.text.isNotEmpty && Validator.url(urlController.text) != null) return true;
    if (schedule.hasError) return true;
    return false;
  }

  bool get canSavePoint => titleController.text.isNotEmpty && point != null && tests.isNotEmpty;
  bool isUploading = false; // Добавляем флаг загрузки
  String? uploadingMessage;

  void handleBack() {
    if (hasChanges) {
      appButtonDeleteDialog(
        context: context,
        title: 'Несохраненные изменения',
        description: 'У вас есть несохраненные изменения. Выйти без сохранения?',
        okText: 'Выйти',
        okStyle: AppButtonStyle.red,
        okCallBack: () => Navigator.of(context).pop(),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  // Функция для загрузки фотографий на Яндекс.Диск
  Future<List<String>> uploadPhotosToYandexDisk() async {
    final List<String> uploadedPhotoPaths = [];

    // Загружаем только новые фотографии (локальные пути)
    final newPhotos = _pickedPhotos.where((photo) => !photo.path.startsWith('http')).toList();

    if (newPhotos.isEmpty) {
      // Если нет новых фотографий, возвращаем существующие
      return _pickedPhotos.map((photo) => photo.path).toList();
    }

    // Импортируем YandexDiskUploader
    final yandexDiskToken = 'y0__xCw3KHvARiIlTkgn7LJ9RO08dnTwoc4tJ3uGtIZnzAKFurOAA'; // Токен Яндекс.Диска
    final pointId = widget.pointAdmin?.id ?? 'temp-2${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Загружаем фотографии на Яндекс.Диск
      for (final photo in newPhotos) {
        final uploadedPath = await YandexDiskUploader.uploadPhotoToPublicFolder(
          filePath: photo.path,
          token: yandexDiskToken,
          pointId: pointId,
        );

        if (uploadedPath != null) {
          uploadedPhotoPaths.add(uploadedPath);
        }
      }

      // Добавляем существующие фотографии (URL)
      final existingPhotos =
          _pickedPhotos.where((photo) => photo.path.startsWith('http')).map((photo) => photo.path).toList();

      uploadedPhotoPaths.addAll(existingPhotos);

      return uploadedPhotoPaths;
    } catch (e) {
      Logger.e('Ошибка при загрузке фотографий на Яндекс.Диск: $e');
      // В случае ошибки возвращаем локальные пути
      return _pickedPhotos.map((photo) => photo.path).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: isNew ? 'Новое место' : 'Редактирование места',
        backButtonTap: handleBack,
      ),
      body: Stack(
        children: [
          ListView(
            physics:
                _enableListViewScroll ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              AppCheckbox(
                title: 'Черновик (скрыт)',
                value: isDraft,
                onChange: (v) => setState(() => isDraft = v),
              ),
              const SizedBox(height: 12),
              AppInput(controller: titleController, label: 'Название'),
              const SizedBox(height: 12),
              AppInput(controller: descriptionController, label: 'Описание', maxLines: 3),
              const SizedBox(height: 12),
              AppInput(controller: urlController, label: 'Ссылка', validator: Validator.url),
              const SizedBox(height: 12),
              ScheduleEditorWidget(
                schedule: schedule,
                onScheduleChanged: (s) => setState(() => schedule = s),
              ),
              const SizedBox(height: 12),
              // --- Список тестов ---
              if (tests.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Тесты',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        final test = tests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              final result = await Navigator.of(context).push<QuestionTest>(
                                MaterialPageRoute(
                                  builder: (_) => EditTestScreen(test: test),
                                ),
                              );

                              if (result != null && result.id != 'empty') {
                                setState(() {
                                  tests[index] = result;
                                });
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(test.type.icon, color: Colors.black),
                              ),
                              title: Text(
                                test.text.isEmpty ? 'Без названия' : test.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  setState(() {
                                    tests.removeAt(index);
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              AppButton(
                title: 'Добавить тест',
                onTap: () async {
                  final result = await Navigator.of(context).push<QuestionTest>(
                    MaterialPageRoute(
                      builder: (context) => EditTestScreen(test: null),
                    ),
                  );
                  if (result != null && result.id != 'empty') {
                    setState(() {
                      tests.add(result);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              PhotoGridWidget(
                photos: _pickedPhotos,
                onPhotosChanged: (newPhotos) {
                  setState(() {
                    _pickedPhotos = newPhotos;
                  });
                },
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 200,
                child: Listener(
                  onPointerDown: (_) {
                    // Отключаем прокрутку ListView при начале взаимодействия с картой
                    setState(() {
                      _enableListViewScroll = false;
                    });
                  },
                  onPointerUp: (_) {
                    // Включаем прокрутку ListView после завершения взаимодействия
                    setState(() {
                      _enableListViewScroll = true;
                    });
                  },
                  onPointerCancel: (_) {
                    // Включаем прокрутку, если жест был отменён
                    setState(() {
                      _enableListViewScroll = true;
                    });
                  },
                  child: PointSelectMapFrame(
                    point: point,
                    onPointChanged: (newPoint) {
                      setState(() {
                        point = newPoint;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                title: 'Сохранить',
                onTap: canSavePoint
                    ? () async {
                        // Показываем индикатор загрузки
                        setState(() {
                          isUploading = true;
                        });

                        Logger.i('Начинаем сохранение точки с фотографиями');
                        Logger.i('Количество выбранных фотографий: ${_pickedPhotos.length}');

                        List<String> uploadedPhotos = [];
                        int totalPhotos = _pickedPhotos.length;
                        int uploadedCount = 0;
                        int failedCount = 0;

                        setState(() {
                          isUploading = true;
                        });

                        try {
                          final pointId = widget.pointAdmin?.id ?? 'temp-2${DateTime.now().millisecondsSinceEpoch}';

                          Logger.i('ID точки для загрузки фото: $pointId');
                          final token = await YandexDiskUploader.getValidToken();

                          // Проверяем/создаем публичную папку на Яндекс.Диске
                          Logger.i('Проверяем наличие публичной папки на Яндекс.Диске');
                          await YandexDiskUploader.ensurePublicFolder(token);

                          // Загружаем только новые фотографии (локальные пути)
                          int photoIndex = 0;
                          for (var photo in _pickedPhotos) {
                            photoIndex++;
                            setState(() {
                              uploadingMessage = 'Загрузка фото $photoIndex из $totalPhotos...';
                            });

                            if (!photo.path.startsWith('http')) {
                              Logger.i('Загружаем фото #$photoIndex: ${photo.path}');
                              final uploadedPath = await YandexDiskUploader.uploadPhotoToPublicFolder(
                                filePath: photo.path,
                                token: token,
                                pointId: pointId,
                              );

                              if (uploadedPath != null) {
                                Logger.i('Фото #$photoIndex успешно загружено: $uploadedPath');
                                uploadedPhotos.add(uploadedPath);
                                uploadedCount++;
                              } else {
                                Logger.e('Ошибка загрузки фото #$photoIndex');
                                failedCount++;
                              }
                            } else {
                              // Если это уже URL, добавляем его как есть
                              Logger.i('Фото #$photoIndex уже загружено: ${photo.path}');
                              uploadedPhotos.add(photo.path);
                              uploadedCount++;
                            }
                          }

                          Logger.i('Всего загружено фотографий: $uploadedCount из $totalPhotos');
                          if (failedCount > 0) {
                            Logger.e('Не удалось загрузить $failedCount фотографий');
                          }
                        } catch (e) {
                          Logger.e('Ошибка при загрузке фотографий на Яндекс.Диск: $e');
                          // В случае ошибки используем локальные пути
                          uploadedPhotos = _pickedPhotos.map((photo) => photo.path).toList();
                        }

                        // Скрываем индикатор загрузки
                        setState(() {
                          isUploading = false;
                        });

                        Logger.i('Создаем объект PointAdminModel с ${uploadedPhotos.length} фотографиями');

                        // Создаем и возвращаем объект PointAdminModel
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop(
                          PointAdminModel(
                            id: widget.pointAdmin?.id ?? 'temp-2${DateTime.now().millisecondsSinceEpoch}',
                            point: point!,
                            photos: uploadedPhotos,
                            title: titleController.text,
                            description: descriptionController.text,
                            schedule: schedule,
                            phones: phoneControllers.map((c) => c.text).where((p) => p.isNotEmpty).toList(),
                            url: urlController.text,
                            order: widget.pointAdmin?.order ?? -1,
                            isDraft: isDraft,
                            tests: tests,
                          ),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 20),
            ],
          ),
          // Индикатор загрузки
          if (isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      uploadingMessage ?? 'Загрузка фотографий...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
