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
import 'package:notable_moments/features/routes/constant/app_map_data.dart';
import 'package:notable_moments/features/questions/edit_test_screen.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:notable_moments/features/routes/widget/schedule_editor_widget.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;

import 'package:notable_moments/features/questions/model/question.dart';

class EditPointScreen extends StatefulWidget {
  const EditPointScreen({super.key, required this.pointAdmin});
  final PointAdminModel? pointAdmin;

  @override
  State<EditPointScreen> createState() => _EditPointScreenState();
}

class _EditPointScreenState extends State<EditPointScreen> {
  bool isNew = true;
  yandex_map.Point? point;
  final _imagePicker = ImagePicker();

  late final titleController = TextEditingController(text: widget.pointAdmin?.title);
  late final descriptionController = TextEditingController(text: widget.pointAdmin?.description);
  late final urlController = TextEditingController(text: widget.pointAdmin?.url);
  late final List<TextEditingController> phoneControllers =
      widget.pointAdmin?.phones.map((phone) => TextEditingController(text: phone)).toList() ??
          [TextEditingController()];
  late final List<String> photos = List.from(widget.pointAdmin?.photos ?? []);
  late WorkingHours schedule = widget.pointAdmin?.schedule ?? WorkingHours(periods: []);
  late bool isDraft = widget.pointAdmin?.isDraft ?? true;
  late List<QuestionTest> tests = widget.pointAdmin?.tests ?? [];

  yandex_map.MapWindow? _mapWindow;
  yandex_map.Map get map => _mapWindow!.map;

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

  void updatePoint(yandex_map.Point p) {
    setState(() {
      point = p;
    });
    map.mapObjects.clear();
    final placemark = map.mapObjects.addPlacemark()..geometry = p;
    placemark
      ..setIcon(AppMapData.placemarkOpened) // исправлено: используем строку пути
      ..setIconStyle(const yandex_map.IconStyle(scale: 1, zIndex: 20));
    map.animateToPoint(p, zoom: 15, duration: const Duration(milliseconds: 300));
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: isNew ? 'Новое место' : 'Редактирование места',
        backButtonTap: handleBack,
      ),
      body: ListView(
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
          SizedBox(
            height: 200,
            child: AppMap(
              onMapCreated: (mapWindow) {
                _mapWindow = mapWindow;
                if (point != null) {
                  updatePoint(point!);
                } else {
                  map.animateToPoint(AppMapData.krasnoyarskPoint, zoom: 12);
                }
              },
              onMapTap: (tappedPoint) {
                updatePoint(tappedPoint);
              },
              showEditButton: false,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            title: 'Сохранить',
            onTap: canSavePoint
                ? () {
                    return Navigator.of(context).pop(
                      PointAdminModel(
                        id: widget.pointAdmin?.id ?? 'temp-2${DateTime.now().millisecondsSinceEpoch}',
                        point: point!,
                        photos: photos,
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
    );
  }
}
