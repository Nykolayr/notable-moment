import 'package:yandex_maps_mapkit/mapkit.dart' as yminit;

extension CameraPositionExtension on yminit.CameraPosition {
  // copy with
  yminit.CameraPosition copyWith({
    yminit.Point? point,
    double? zoom,
    double? azimuth,
    double? tilt,
  }) =>
      yminit.CameraPosition(
        point ?? target,
        zoom: zoom ?? this.zoom,
        azimuth: azimuth ?? this.azimuth,
        tilt: tilt ?? this.tilt,
      );

  // delta zoom
  yminit.CameraPosition deltaZoom(double delta) => copyWith(zoom: zoom + delta);
}
