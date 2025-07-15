// lib/features/profile/provider/profile_state.dart

import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/core/constant/enum/gender_enum.dart';
import 'package:notable_moments/features/profile/model/status_enum.dart';

class ProfileState {
  final String uid; // ✅ Новый uid
  final String? name;
  final int avatarId;
  final DateTime? birthday;
  final Gender? gender;
  final String? school;
  final Status status;
  final bool isRegistration;
  final bool isAdmin;

  // ✅ Для квестов
  final int suscoins;
  final int energy;
  final int streak;

  /// Нужно ли заполнить профиль
  bool get needToFill => name == null || birthday == null || gender == null || school == null;

  /// Показывать ли загрузку
  bool get showLoading => status == Status.loading;

  /// Пустое состояние
  ProfileState.empty()
      : uid = '',
        name = null,
        avatarId = 0,
        birthday = null,
        gender = null,
        school = null,
        isRegistration = false,
        status = Status.initial,
        isAdmin = false,
        suscoins = 0,
        energy = 3, // energy по умолчанию теперь 3
        streak = 0;

  /// Основной конструктор
  const ProfileState({
    required this.uid,
    required this.name,
    required this.avatarId,
    this.birthday,
    this.gender,
    this.school,
    this.status = Status.initial,
    this.isRegistration = false,
    this.isAdmin = false,
    this.suscoins = 0,
    this.energy = 0,
    this.streak = 0,
  });

  /// copyWith
  ProfileState copyWith({
    String? uid,
    String? name,
    int? avatarId,
    DateTime? birthday,
    Gender? gender,
    String? school,
    Status? status,
    bool? isRegistration,
    bool? isAdmin,
    int? suscoins,
    int? energy,
    int? streak,
  }) =>
      ProfileState(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        avatarId: avatarId ?? this.avatarId,
        birthday: birthday ?? this.birthday,
        gender: gender ?? this.gender,
        school: school ?? this.school,
        status: status ?? this.status,
        isRegistration: isRegistration ?? this.isRegistration,
        isAdmin: isAdmin ?? this.isAdmin,
        suscoins: suscoins ?? this.suscoins,
        energy: energy ?? this.energy,
        streak: streak ?? this.streak,
      );

  /// fromJson
  factory ProfileState.fromJson(Map<String, dynamic> json) {
    ProfileState state = ProfileState.empty();

    for (var key in json.keys) {
      try {
        switch (key) {
          case 'uid':
            state = state.copyWith(uid: json[key] ?? '');
            break;
          case 'name':
            state = state.copyWith(name: json[key]);
            break;
          case 'avatarId':
            state = state.copyWith(avatarId: json[key]);
            break;
          case 'birthday':
            state = state.copyWith(birthday: DateTime.tryParse(json[key]));
            break;
          case 'gender':
            state = state.copyWith(gender: GenderJson.fromJson(json[key]));
            break;
          case 'school':
            state = state.copyWith(school: json[key]);
            break;
          case 'role':
            state = state.copyWith(isAdmin: json[key] == 'admin');
            break;
          case 'suscoins':
            state = state.copyWith(
              suscoins: json[key] is int ? json[key] : int.tryParse(json[key].toString()) ?? 0,
            );
            break;
          case 'energy':
            state = state.copyWith(
              energy: json[key] is int ? json[key] : int.tryParse(json[key].toString()) ?? 0,
            );
            break;
          case 'streak':
            state = state.copyWith(
              streak: json[key] is int ? json[key] : int.tryParse(json[key].toString()) ?? 0,
            );
            break;
        }
      } catch (e) {
        Logger.e('ProfileState.fromJson error on $key: $e');
      }
    }

    return state;
  }

  @override
  String toString() =>
      'ProfileState(uid: $uid, name: $name, avatarId: $avatarId, birthday: $birthday, gender: $gender, '
      'school: $school, status: $status, isAdmin: $isAdmin, suscoins: $suscoins, energy: $energy, streak: $streak)';
}
