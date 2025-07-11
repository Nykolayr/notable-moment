// lib/features/routes/widget/app_map.dart

import 'package:flutter/material.dart';
import 'package:notable_moments/core/helpers/yandex_maps_manager.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/routes/constant/app_map_data.dart';
import 'package:notable_moments/features/routes/edit_routes_screen.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;
import 'package:yandex_maps_mapkit/yandex_map.dart' as yandex_map;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppMap extends ConsumerStatefulWidget {
  const AppMap({
    super.key,
    required this.onMapCreated,
    this.showControls = true,
    this.disableTaps = false,
    this.animateToKrasnoyarsk = true,
    this.onMapTap,
    this.showEditButton = true,
  });

  final void Function(yandex_map.MapWindow mapWindow) onMapCreated;
  final bool showControls;
  final bool disableTaps;
  final bool animateToKrasnoyarsk;
  final void Function(yandex_map.Point point)? onMapTap;
  final bool showEditButton;

  @override
  ConsumerState<AppMap> createState() => _AppMapState();
}

class _AppMapState extends ConsumerState<AppMap> {
  late yandex_map.MapWindow _mapWindow;
  yandex_map.Map get map => _mapWindow.map;
  final _mapsManager = YandexMapsManager();
  yandex_map.MapInputListener? _inputListener;

  @override
  void initState() {
    super.initState();
    _mapsManager.start();
  }

  @override
  void dispose() {
    if (_inputListener != null) {
      map.removeInputListener(_inputListener!);
    }
    _mapsManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return AbsorbPointer(
      absorbing: widget.disableTaps,
      child: Stack(
        fit: StackFit.expand,
        children: [
          yandex_map.YandexMap(
            onMapCreated: (yandex_map.MapWindow mapWindow) {
              _mapWindow = mapWindow;
              if (widget.animateToKrasnoyarsk) {
                map.animateToPoint(
                  AppMapData.krasnoyarskPoint,
                  zoom: 12,
                );
              }

              // Добавляем обработчик тапов если он передан
              if (widget.onMapTap != null) {
                _inputListener = MapInputListenerImpl(
                  onMapTapCallback: (map, point) => widget.onMapTap!(point),
                  onMapLongTapCallback: (map, point) {},
                );
                map.addInputListener(_inputListener!);
              }

              widget.onMapCreated(_mapWindow);
            },
            platformViewType: yandex_map.PlatformViewType.Hybrid,
          ),
          if (widget.showControls)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton.icon(
                      icon: AppIcon.plus,
                      onTap: () => map.changeZoomWithDelta(1),
                    ),
                    const SizedBox(height: 8),
                    AppButton.icon(
                      icon: AppIcon.minus,
                      onTap: () => map.changeZoomWithDelta(-1),
                    ),
                    const SizedBox(height: 8),
                    AppButton.icon(
                      icon: AppIcon.location,
                      onTap: () {
                        map.animateToPoint(
                          AppMapData.krasnoyarskPoint,
                          zoom: 12,
                        );
                      },
                    ),
                    if (profileState.isAdmin && widget.showEditButton) ...[
                      const SizedBox(height: 8),
                      AppButton.icon(
                        icon: AppIcon.edit,
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => const EditRoutesScreen(),
                            ),
                          )
                              .then((_) async {
                            await Future.delayed(const Duration(milliseconds: 1000));
                            // можно вызвать повторный рендер или обновление карты
                          });
                        },
                      ),
                    ],
                  ],
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
