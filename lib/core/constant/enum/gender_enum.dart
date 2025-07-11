import 'package:collection/collection.dart';

enum Gender { male, female }

// extension label

extension GenderLabel on Gender {
  String get label => switch (this) {
        Gender.male => 'Мужской',
        Gender.female => 'Женский',
      };
}

// extension json

extension GenderJson on Gender {
  static Gender? fromJson(String json) {
    return Gender.values.firstWhereOrNull((g) => g.name == json);
  }
}
