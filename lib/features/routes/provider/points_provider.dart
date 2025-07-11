import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';

/// StateNotifier для управления списком точек маршрутов в админке
class PointsNotifier extends StateNotifier<List<PointAdminModel>> {
  PointsNotifier() : super([]);

  /// Установить сразу все точки
  void setPoints(List<PointAdminModel> points) {
    state = points;
  }

  /// Добавить новую точку
  void addPoint(PointAdminModel point) {
    state = [...state, point];
  }

  /// Обновить существующую точку
  void updatePoint(PointAdminModel updatedPoint) {
    state = [
      for (final point in state)
        if (point.id == updatedPoint.id) updatedPoint else point,
    ];
  }

  /// Удалить точку по id
  void removePoint(String id) {
    state = state.where((point) => point.id != id).toList();
  }

  /// Очистить все точки
  void clear() {
    state = [];
  }
}

/// Провайдер, используемый в админке и экранах редактирования
final pointsProvider = StateNotifierProvider<PointsNotifier, List<PointAdminModel>>(
  (ref) => PointsNotifier(),
);
