// lib/features/routes/edit_point_only_screen.dart

import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
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
          AppMap(
            onMapCreated: (controller) async {
              mapController = controller;
              if (point == null) {
                await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: Point(latitude: 56.0267294, longitude: 92.865734),
                      zoom: 12,
                    ),
                  ),
                );
              } else {
                updatePoint(point!);
              }
            },
            mapObjects: mapObjects,
            showEditButton: false,
            onMapTap: (tappedPoint) {
              updatePoint(tappedPoint);
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
