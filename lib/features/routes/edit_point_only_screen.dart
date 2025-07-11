// lib/features/routes/edit_point_only_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/constant/app_map_data.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;

class EditPointOnlyScreen extends ConsumerStatefulWidget {
  const EditPointOnlyScreen({super.key, required this.point});

  final yandex_map.Point? point;

  @override
  ConsumerState<EditPointOnlyScreen> createState() => _EditPointScreenState();
}

class _EditPointScreenState extends ConsumerState<EditPointOnlyScreen> {
  late bool isNew;
  yandex_map.Point? point;

  late yandex_map.MapWindow _mapWindow;
  yandex_map.Map get map => _mapWindow.map;

  late final _inputListener = MapInputListenerImpl(
    onMapTapCallback: (map, point) {
      debugPrint('Tap: $point');
      addSelectedPoint(point);
    },
    onMapLongTapCallback: (map, point) {},
  );

  @override
  void initState() {
    super.initState();
    isNew = widget.point == null;
    point = widget.point;
  }

  void replacePoint(yandex_map.Point point) {
    map.mapObjects.clear();
    map.mapObjects.addPlacemark()
      ..geometry = point
      ..setIcon(AppMapData.placemarkOpened)
      ..setIconStyle(const yandex_map.IconStyle(scale: 1, zIndex: 20.0));
  }

  void addSelectedPoint(yandex_map.Point point) {
    replacePoint(point);
    map.animateToPoint(
      point,
      zoom: 15,
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      this.point = point;
    });
  }

  @override
  void dispose() {
    map.removeInputListener(_inputListener);
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
            onMapCreated: (yandex_map.MapWindow mapWindow) {
              _mapWindow = mapWindow;
              map.addInputListener(_inputListener);

              if (point == null) {
                map.animateToPoint(
                  AppMapData.krasnoyarskPoint,
                  zoom: 12,
                  duration: const Duration(milliseconds: 500),
                );
              } else {
                map.animateToPoint(point!, zoom: 15, duration: const Duration(milliseconds: 500));
                replacePoint(point!);
              }
            },
            showEditButton: false,
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

final class MapInputListenerImpl implements yandex_map.MapInputListener {
  final void Function(yandex_map.Map, yandex_map.Point) onMapTapCallback;
  final void Function(yandex_map.Map, yandex_map.Point) onMapLongTapCallback;

  const MapInputListenerImpl({
    required this.onMapTapCallback,
    required this.onMapLongTapCallback,
  });

  @override
  void onMapTap(yandex_map.Map map, yandex_map.Point point) => onMapTapCallback(map, point);

  @override
  void onMapLongTap(yandex_map.Map map, yandex_map.Point point) => onMapLongTapCallback(map, point);
}
