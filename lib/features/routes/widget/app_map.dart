// lib/features/routes/widget/app_map.dart

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/routes/edit_routes_screen.dart';

class AppMap extends StatefulWidget {
  final List<MapObject> mapObjects;
  const AppMap({
    super.key,
    required this.onMapCreated,
    required this.mapObjects,
    this.showControls = true,
    this.disableTaps = false,
    this.animateToKrasnoyarsk = true,
    this.onMapTap,
    this.showEditButton = true,
  });

  final void Function(YandexMapController controller) onMapCreated;
  final bool showControls;
  final bool disableTaps;
  final bool animateToKrasnoyarsk;
  final void Function(Point point)? onMapTap;
  final bool showEditButton;

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  YandexMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.disableTaps,
      child: Stack(
        fit: StackFit.expand,
        children: [
          YandexMap(
            mapObjects: widget.mapObjects,
            onMapCreated: (controller) async {
              _controller = controller;
              widget.onMapCreated(controller);
              if (widget.animateToKrasnoyarsk) {
                await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: Point(latitude: 56.0267294, longitude: 92.865734),
                      zoom: 12,
                    ),
                  ),
                );
              }
            },
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
                      onTap: () => _controller?.moveCamera(CameraUpdate.zoomIn()),
                    ),
                    const SizedBox(height: 8),
                    AppButton.icon(
                      icon: AppIcon.minus,
                      onTap: () => _controller?.moveCamera(CameraUpdate.zoomOut()),
                    ),
                    const SizedBox(height: 8),
                    AppButton.icon(
                      icon: AppIcon.location,
                      onTap: () {
                        _controller?.moveCamera(
                          CameraUpdate.newCameraPosition(
                            const CameraPosition(
                              target: Point(latitude: 56.0267294, longitude: 92.865734),
                              zoom: 12,
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.showEditButton) ...[
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
