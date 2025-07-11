import 'package:collection/collection.dart';

enum PointState {
  finished,
  active,
  disabled;

  bool get isDiabled => this == PointState.disabled;
  static PointState fromMap(String name) {
    return PointState.values.firstWhereOrNull((e) => e.name == name) ?? PointState.active;
  }
}
