import 'package:notable_moments/features/routes/enum/map_point_type_enum.dart';

class MapPoint {
  final double latitude;
  final double longitude;
  final MapPointType type;
  MapPoint(this.latitude, this.longitude, this.type);
}

class MapPointPlace extends MapPoint {
  final String title;
  final String description;

  MapPointPlace(
    double latitude,
    double longitude,
    this.title, //
    this.description,
  ) : super(latitude, longitude, MapPointType.place);
}

class MapPointRoute extends MapPoint {
  MapPointRoute(double latitude, double longitude) : super(latitude, longitude, MapPointType.route);
}
