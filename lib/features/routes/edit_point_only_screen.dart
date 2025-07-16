// lib/features/routes/edit_point_only_screen.dart

import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/widget/point_select_map_frame.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class EditPointOnlyScreen extends StatefulWidget {
  const EditPointOnlyScreen({super.key, required this.point});

  final Point? point;

  @override
  State<EditPointOnlyScreen> createState() => _EditPointScreenState();
}

class _EditPointScreenState extends State<EditPointOnlyScreen> {
  late bool isNew;
  Point? point;
  YandexMapController? mapController;
  List<MapObject> mapObjects = [];

  @override
  void initState() {
    super.initState();
    isNew = widget.point == null;
    point = widget.point;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: isNew ? 'Новая локация' : 'Редактирование локации',
      ),
      useSafeAreaBottom: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PointSelectMapFrame(
            point: point,
            onPointChanged: (newPoint) {
              setState(() {
                point = newPoint;
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(18).add(context.safeArea),
              child: AppButton(
                title: 'Выбрать локацию',
                onTap: point != null ? () => context.pop(point) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
