import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RouteBuilder {
  /// Строит маршрут по дорогам через YandexDriving
  static Future<Polyline> buildRoutePolyline(List<Point> points) async {
    if (points.length < 2) return Polyline(points: points);
    try {
      final requestPoints =
          points.map((point) => RequestPoint(point: point, requestPointType: RequestPointType.wayPoint)).toList();

      final drivingSession = await YandexDriving.requestRoutes(
        points: requestPoints,
        drivingOptions: DrivingOptions(),
      );

      final drivingResult = await drivingSession.$2;
      if (drivingResult.routes != null && drivingResult.routes!.isNotEmpty) {
        final route = drivingResult.routes!.first;
        return route.geometry;
      } else {
        Logger.w('RouteBuilder: No routes returned from YandexDriving');
      }
    } catch (e) {
      Logger.e('RouteBuilder: Error building driving route: $e');
    }
    Logger.w('RouteBuilder: Using fallback polyline (straight line)');
    return Polyline(points: points);
  }
}
