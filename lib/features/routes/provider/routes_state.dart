import 'package:notable_moments/features/routes/model/route_admin_model.dart';

class RoutesState {
  final List<RouteAdminModel> allRoutes;
  final bool isLoading;
  List<RouteAdminModel> get activeRoutes => allRoutes.where((route) => !route.isDraft).map((route) {
        final points = route.points.where((point) => !point.isDraft).toList();
        return route.copyWith(points: points, calculatedRoute: route.calculatedRoute);
      }).toList();

  RoutesState({required this.allRoutes, required this.isLoading});

  RoutesState copyWith({
    List<RouteAdminModel>? allRoutes,
    bool? isLoading,
  }) {
    return RoutesState(
      allRoutes: allRoutes ?? this.allRoutes,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static RoutesState initial() {
    return RoutesState(allRoutes: [], isLoading: true);
  }
}
