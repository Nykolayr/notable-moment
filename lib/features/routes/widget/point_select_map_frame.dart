import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/theme/app_icon.dart';

class PointSelectMapFrame extends StatefulWidget {
  final Point? point;
  final void Function(Point) onPointChanged;
  final double height;

  const PointSelectMapFrame({
    super.key,
    required this.point,
    required this.onPointChanged,
    this.height = 220,
  });

  @override
  State<PointSelectMapFrame> createState() => _PointSelectMapFrameState();
}

class _PointSelectMapFrameState extends State<PointSelectMapFrame> {
  YandexMapController? mapController;
  Point? _currentPoint;

  @override
  void initState() {
    super.initState();

    _currentPoint = widget.point;
    Logger.i('2 === ${_currentPoint?.toJson()}');
  }

  @override
  void didUpdateWidget(covariant PointSelectMapFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.point != oldWidget.point) {
      setState(() {
        _currentPoint = widget.point;
      });
    }
  }

  List<MapObject> get _mapObjects {
    Logger.i('${_currentPoint?.toJson()}');
    if (_currentPoint == null) return [];
    return [
      PlacemarkMapObject(
        mapId: const MapObjectId('selected_point'),
        point: _currentPoint!,
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
            scale: 1,
          ),
        ),
        zIndex: 2000,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          YandexMap(
            mapObjects: _mapObjects,
            onMapCreated: (controller) async {
              mapController = controller;
              if (_currentPoint != null) {
                await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _currentPoint!, zoom: 15),
                  ),
                );
              } else {
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
            onMapTap: (point) {
              setState(() {
                _currentPoint = point;
              });
              widget.onPointChanged(point);
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.icon(
                    icon: AppIcon.plus,
                    onTap: () => mapController?.moveCamera(CameraUpdate.zoomIn()),
                  ),
                  const SizedBox(height: 4),
                  AppButton.icon(
                    icon: AppIcon.minus,
                    onTap: () => mapController?.moveCamera(CameraUpdate.zoomOut()),
                  ),
                  const SizedBox(height: 4),
                  AppButton.icon(
                    icon: AppIcon.location,
                    onTap: () => mapController?.moveCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          target: Point(latitude: 56.0267294, longitude: 92.865734),
                          zoom: 12,
                        ),
                      ),
                    ),
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
