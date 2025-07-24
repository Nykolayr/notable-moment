import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RouteBuilder {
  /// Строит маршрут по дорогам через YandexDriving
  static Future<Polyline> buildRoutePolyline(List<Point> points) async {
    if (points.length < 2) return Polyline(points: points);
    try {
      Logger.i('RouteBuilder: Building route with ${points.length} points');
      final requestPoints =
          points.map((point) => RequestPoint(point: point, requestPointType: RequestPointType.wayPoint)).toList();
      Logger.i('RouteBuilder: Requesting driving route...');
      final drivingSession = await YandexDriving.requestRoutes(
        points: requestPoints,
        drivingOptions: DrivingOptions(),
      );
      Logger.i('RouteBuilder: Got driving session, waiting for result...');
      final drivingResult = await drivingSession.$2;
      Logger.i('RouteBuilder: Driving result received');
      Logger.i('RouteBuilder: Routes count: ${drivingResult.routes?.length ?? 0}');
      if (drivingResult.routes != null && drivingResult.routes!.isNotEmpty) {
        final route = drivingResult.routes!.first;
        Logger.i('RouteBuilder: Route geometry points: ${route.geometry.points.length}');
        Logger.i('RouteBuilder: Route distance: ${route.metadata.weight.distance.value}');
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
