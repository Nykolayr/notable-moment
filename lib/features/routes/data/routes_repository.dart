import 'package:cloud_firestore/cloud_firestore.dart';
import 'route_model.dart';

class RoutesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<RouteModel>> fetchRoutes() async {
    try {
      final snapshot = await _db.collection('routes').get();

      return snapshot.docs.map((doc) {
        return RouteModel.fromFirestore(doc.id, doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Не удалось загрузить маршруты: $e');
    }
  }

  Future<RouteModel?> getRouteById(String id) async {
    try {
      final doc = await _db.collection('routes').doc(id).get();

      if (!doc.exists) return null;
      return RouteModel.fromFirestore(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Ошибка при получении маршрута по id: $e');
    }
  }

  // При необходимости:
  // Future<void> createRoute(RouteModel route) async { ... }
  // Future<void> deleteRoute(String id) async { ... }
}
