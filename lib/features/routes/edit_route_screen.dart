import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/helpers/validator.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_checkbox.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_label.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/edit_point_screen.dart';
import 'package:notable_moments/features/routes/edit_route_map_screen.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';
import 'package:notable_moments/features/routes/widget/point_widget.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class EditRouteScreen extends ConsumerStatefulWidget {
  const EditRouteScreen({super.key, required this.routeId});

  final String? routeId;

  @override
  ConsumerState<EditRouteScreen> createState() => _EditRouteScreenState();
}

class _EditRouteScreenState extends ConsumerState<EditRouteScreen> {
  late bool isNew = widget.routeId == null;

  late final RouteAdminModel _route;
  late bool isDraft = true;
  late final titleController = TextEditingController();
  late final descriptionController = TextEditingController();
  late final urlController = TextEditingController();
  late final whyThisRouteController = TextEditingController();
  late List<PointAdminModel> points = [];
  late Polyline polyline = Polyline(points: []);

  bool get hasError => titleController.text.isEmpty;
  bool get canSave => hasChanges && !hasError;
  bool isLoading = false;

  RouteAdminModel _initializeRoute() {
    final emptyRoute = RouteAdminModel(
      id: '',
      title: '',
      description: '',
      url: '',
      whyThisRoute: '',
      points: [],
      isDraft: false,
      polyline: Polyline(points: []),
      order: 0,
    );

    if (widget.routeId == null) return emptyRoute;
    return ref.read(routesProvider).allRoutes.where((it) => it.id == widget.routeId).firstOrNull ?? emptyRoute;
  }

  @override
  void initState() {
    super.initState();

    _route = _initializeRoute();
    isDraft = _route.isDraft;
    titleController.text = _route.title;
    descriptionController.text = _route.description;
    urlController.text = _route.url;
    whyThisRouteController.text = _route.whyThisRoute;
    points = List.from(_route.points);
    polyline = _route.polyline;

    titleController.addListener(() => setState(() {}));
    descriptionController.addListener(() => setState(() {}));
    urlController.addListener(() => setState(() {}));
    whyThisRouteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    urlController.dispose();
    whyThisRouteController.dispose();
    super.dispose();
  }

  bool get hasChanges {
    if (titleController.text != _route.title) return true;
    if (descriptionController.text != _route.description) return true;
    if (urlController.text != _route.url) return true;
    if (whyThisRouteController.text != _route.whyThisRoute) return true;
    if (!ListEquality().equals(points, _route.points)) return true;
    if (isDraft != _route.isDraft) return true;

    return false;
  }

  // Новый метод: просто соединяем активные точки прямой линией
  void calculatePolyline() {
    final activePoints = points.where((it) => it.isActive).toList();
    if (activePoints.length < 2) {
      setState(() {
        polyline = Polyline(points: []);
      });
      return;
    }
    setState(() {
      polyline = Polyline(points: activePoints.map((e) => e.point).toList());
    });
  }

  void handleBack() async {
    if (hasChanges) {
      appButtonDeleteDialog(
        context: context,
        title: 'Несохраненные изменения',
        description: 'У вас есть несохраненные изменения. Вы уверены, что хотите выйти?',
        okText: 'Выйти',
        okStyle: AppButtonStyle.red,
        okCallBack: () => context.pop(),
      );
    } else {
      context.pop();
    }
  }

  RouteAdminModel get route => _route.copyWith(
        title: titleController.text,
        description: descriptionController.text,
        whyThisRoute: whyThisRouteController.text,
        url: urlController.text,
        points: points,
        isDraft: isDraft,
        polyline: polyline,
      );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: isNew ? 'Новый маршрут' : 'Редактирование маршрута',
        backButtonTap: handleBack,
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          AppCheckbox(
            title: 'Черновик (скрыт)',
            value: isDraft,
            onChange: (value) => setState(() => isDraft = value),
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: titleController,
            label: 'Название маршрута',
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: descriptionController,
            label: 'Описание маршрута',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: whyThisRouteController,
            label: 'Почему этот маршрут',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          AppInput(
            controller: urlController,
            label: 'Ссылка на маршрут',
            validator: Validator.url,
          ),
          const SizedBox(height: 16),
          if (points.isNotEmpty) AppLabel('Места', bottomPadding: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: points.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = points.removeAt(oldIndex);
                points.insert(newIndex, item);

                // Update order for all points
                for (var i = 0; i < points.length; i++) {
                  points[i] = points[i].copyWith(order: i);
                }
              });
              calculatePolyline();
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final elevation = Curves.easeInOut.transform(animation.value);
                  final point = points[index];
                  return Material(
                    elevation: elevation,
                    borderRadius: BorderRadius.circular(8),
                    child: PointWidget(point: point, onRemove: () {}),
                  );
                },
              );
            },
            itemBuilder: (context, index) {
              final point = points[index];
              return Padding(
                key: ValueKey(point),
                padding: EdgeInsets.only(bottom: index == points.length - 1 ? 0 : 8),
                child: AppGestureDetector(
                  onTap: () async {
                    final newPoint = await Navigator.of(context).push<PointAdminModel?>(
                      MaterialPageRoute(
                        builder: (context) => EditPointScreen(pointAdmin: point),
                      ),
                    );
                    if (!context.mounted) return;
                    if (newPoint == null) return;

                    points[index] = newPoint;
                    setState(() {});
                    calculatePolyline();

                    // Автоматически сохраняем маршрут после редактирования точки
                    if (!isNew) {
                      await ref.read(routesProvider.notifier).updateRoute(route);
                    }
                  },
                  child: PointWidget(
                    point: point,
                    onRemove: () {
                      points.removeAt(index);
                      setState(() {});
                      calculatePolyline();
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            title: 'Добавить место',
            onTap: () async {
              final point = await Navigator.of(context).push<PointAdminModel?>(
                MaterialPageRoute(
                  builder: (context) => EditPointScreen(pointAdmin: null),
                ),
              );
              if (!context.mounted) return;
              if (point == null) return;

              points.add(point.copyWith(order: points.length));
              setState(() {});
              calculatePolyline();

              // Автоматически сохраняем маршрут после добавления новой точки
              if (!isNew) {
                await ref.read(routesProvider.notifier).updateRoute(route);
              }
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            title: 'Предпросмотр маршрута',
            isLoading: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditRouteMapScreen(route: route),
              ),
            ),
          ),
          const SizedBox(height: 20),
          isNew
              ? AppButton(
                  title: 'Создать',
                  isLoading: isLoading,
                  onTap: canSave
                      ? () async {
                          setState(() {
                            isLoading = true;
                          });

                          calculatePolyline();
                          final res = await ref.read(routesProvider.notifier).createRoute(
                                title: titleController.text,
                                description: descriptionController.text,
                                url: urlController.text,
                                whyThisRoute: whyThisRouteController.text,
                                points: points,
                                isDraft: isDraft,
                                polyline: polyline,
                              );
                          if (!context.mounted) return;
                          setState(() {
                            isLoading = false;
                          });
                          if (res) {
                            context.pop(true);
                          } else {
                            context.showErrorSnackBar('Ошибка при создании маршрута');
                          }
                        }
                      : null,
                )
              : AppButton(
                  title: 'Сохранить',
                  isLoading: isLoading,
                  onTap: canSave
                      ? () async {
                          setState(() {
                            isLoading = true;
                          });
                          calculatePolyline();
                          await ref.read(routesProvider.notifier).updateRoute(route);
                          if (!context.mounted) return;
                          setState(() {
                            isLoading = false;
                          });
                          context.pop(true);
                        }
                      : null,
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
