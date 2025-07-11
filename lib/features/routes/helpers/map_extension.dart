// lib/features/routes/helpers/map_extension.dart

import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_images.dart';
import 'package:notable_moments/features/routes/constant/app_map_data.dart';
import 'package:notable_moments/features/routes/helpers/camera_position_extension.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;

/// Extension для удобной работы с картой
typedef YMap = yandex_map.Map;

typedef YPoint = yandex_map.Point;
typedef YPolyline = yandex_map.Polyline;
typedef YCameraPosition = yandex_map.CameraPosition;
typedef YAnimationType = yandex_map.AnimationType;
typedef YAnimation = yandex_map.Animation;

extension MapExtension on YMap {
  void animateToKrasnoyarsk({
    double zoom = 12,
    double azimuth = 0,
    double tilt = 0,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    animateToPoint(
      AppMapData.krasnoyarskPoint,
      zoom: zoom,
      azimuth: azimuth,
      tilt: tilt,
      duration: duration,
    );
  }

  void animateToPoint(
    YPoint point, {
    double zoom = 16,
    double azimuth = 0,
    double tilt = 0,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    final position = YCameraPosition(point, zoom: zoom, azimuth: azimuth, tilt: tilt);
    animateToCameraPosition(position, duration: duration);
  }

  void animateToCameraPosition(
    YCameraPosition position, {
    Duration duration = const Duration(milliseconds: 500),
    YAnimationType animationType = YAnimationType.Smooth,
  }) {
    moveWithAnimation(
      position,
      YAnimation(animationType, duration: duration.inMilliseconds / 1000),
    );
  }

  void changeZoomWithDelta(double delta) {
    final current = cameraPosition;
    animateToCameraPosition(current.deltaZoom(delta));
  }

  yandex_map.PolylineMapObject addPolyline(
    YPolyline polyline, {
    bool Function(yandex_map.MapObject, YPoint)? onTap,
  }) {
    final polylineObject = mapObjects.addPolylineWithGeometry(polyline);
    polylineObject.style = yandex_map.LineStyle(strokeWidth: 4, innerOutlineEnabled: true);
    polylineObject.setStrokeColor(AppColor.primary);
    polylineObject.zIndex = 100;
    if (onTap != null) {
      polylineObject.addTapListener(MapObjectTapListenerImpl(onMapObjectTapped: onTap));
    }
    return polylineObject;
  }

  yandex_map.PlacemarkMapObject addPlacemark(
    YPoint point, {
    String icon = AppImages.placemarkOpened,
    int size = 72,
    double scale = 1,
    double zIndex = 20,
    bool Function(yandex_map.MapObject, YPoint)? onTap,
  }) {
    final placemark = mapObjects.addPlacemark();
    placemark.geometry = point;
    placemark.setIcon(AppMapData.fromAsset(icon, size: size));
    placemark.setIconStyle(yandex_map.IconStyle(scale: scale, zIndex: zIndex));
    if (onTap != null) {
      placemark.addTapListener(MapObjectTapListenerImpl(onMapObjectTapped: onTap));
    }
    return placemark;
  }

  void addRoute(
    RouteAdminModel route, {
    bool Function(yandex_map.MapObject, YPoint)? onTap,
  }) {
    addPolyline(route.polyline, onTap: onTap);
    for (var i = 0; i < route.points.length; i++) {
      final point = route.points[i].point;
      final icon = i == 0
          ? AppImages.placemarkBeginOpened
          : i == route.points.length - 1
              ? AppImages.placemarkEndOpened
              : AppImages.placemarkOpened;
      addPlacemark(point, icon: icon, onTap: onTap);
    }
  }
}

extension PointExtension on YPoint {
  Map<String, dynamic> toMap() => {'latitude': latitude, 'longitude': longitude};

  static YPoint fromMap(Map<String, dynamic> map) =>
      YPoint(latitude: map['latitude'] as double, longitude: map['longitude'] as double);
}

extension PolylineExtension on YPolyline {
  Map<String, dynamic> toMap() => {
        'points': points.map((p) => p.toMap()).toList(),
      };

  static YPolyline fromMap(Map<String, dynamic> map) => YPolyline(
        (map['points'] as List).map((e) => PointExtension.fromMap(e)).toList(),
      );
}

final class MapObjectTapListenerImpl implements yandex_map.MapObjectTapListener {
  final bool Function(yandex_map.MapObject, YPoint) onMapObjectTapped;

  const MapObjectTapListenerImpl({required this.onMapObjectTapped});

  @override
  bool onMapObjectTap(yandex_map.MapObject mapObject, YPoint point) => onMapObjectTapped(mapObject, point);
}
