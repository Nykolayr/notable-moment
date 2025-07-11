import 'package:notable_moments/features/routes/model/route_admin_model.dart';

class RoutesState {
  final List<RouteAdminModel> allRoutes;
  List<RouteAdminModel> get activeRoutes => allRoutes.where((route) => !route.isDraft).map((route) {
        final points = route.points.where((point) => !point.isDraft).toList();
        return route.copyWith(points: points);
      }).toList();

  RoutesState({required this.allRoutes});

  RoutesState copyWith({
    List<RouteAdminModel>? allRoutes,
  }) {
    return RoutesState(
      allRoutes: allRoutes ?? this.allRoutes,
    );
  }

  static RoutesState initial() {
    return RoutesState(allRoutes: []);
  }
}
