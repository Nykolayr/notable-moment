// lib/features/profile/provider/profile_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notable_moments/core/constant/enum/gender_enum.dart';
import 'package:notable_moments/features/profile/model/status_enum.dart';
import 'package:notable_moments/features/profile/provider/profile_service.dart';
import 'package:notable_moments/features/profile/provider/profile_state.dart';

/// Глобальный провайдер профиля
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileNotifier(profileService);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;

  ProfileNotifier(this._profileService) : super(ProfileState.empty()) {
    loadProfile();
  }

  /// Загружает профиль пользователя из Firestore
  Future<void> loadProfile() async {
    try {
      state = state.copyWith(status: Status.loading);
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('profileProvider -- loadProfile: пользователь не авторизован');
        state = state.copyWith(status: Status.loaded);
        return;
      }

      final profileMap = await _profileService.loadProfile();

      if (profileMap == null) {
        debugPrint('profileProvider -- loadProfile: профиль не найден');
        state = state.copyWith(status: Status.loaded);
        return;
      }

      final newState = ProfileState.fromJson(profileMap).copyWith(status: Status.loaded);
      debugPrint('profileProvider -- loadProfile: $newState');
      state = newState;
    } catch (e) {
      debugPrint('profileProvider -- loadProfile error: $e');
      state = state.copyWith(status: Status.loaded);
    }
  }

  Future<void> refreshProfile() async {
    debugPrint('profileProvider -- refreshProfile: запускается обновление');
    await loadProfile();
  }

  Future<void> updateAvatar(int avatarId) async {
    try {
      await _profileService.saveProfile(avatarId: avatarId);
      state = state.copyWith(avatarId: avatarId);
      debugPrint('profileProvider -- updateAvatar: обновлён на $avatarId');
    } catch (e) {
      debugPrint('profileProvider -- updateAvatar error: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    DateTime? birthday,
    Gender? gender,
    String? school,
    int? avatarId,
  }) async {
    try {
      final result = await _profileService.saveProfile(
        name: name,
        birthday: birthday,
        gender: gender,
        school: school,
        avatarId: avatarId,
      );

      if (result) {
        state = state.copyWith(
          name: name ?? state.name,
          birthday: birthday ?? state.birthday,
          gender: gender ?? state.gender,
          school: school ?? state.school,
          avatarId: avatarId ?? state.avatarId,
        );

        if (!state.needToFill) {
          state = state.copyWith(isRegistration: false);
        }

        debugPrint('profileProvider -- updateProfile: профиль обновлён');
      }

      return result;
    } catch (e) {
      debugPrint('profileProvider -- updateProfile error: $e');
      return false;
    }
  }

  void setRegistrationMode() {
    try {
      state = state.copyWith(isRegistration: true);
      debugPrint('profileProvider -- setRegistrationMode: режим регистрации активирован');
    } catch (e) {
      debugPrint('profileProvider -- setRegistrationMode error: $e');
    }
  }

  void signOut() {
    try {
      state = ProfileState.empty();
      debugPrint('profileProvider -- signOut: профиль сброшен');
    } catch (e) {
      debugPrint('profileProvider -- signOut error: $e');
    }
  }

  Future<bool> deleteProfile() async {
    try {
      state = ProfileState.empty().copyWith(status: Status.loading);
      final result = await _profileService.deleteProfile();
      debugPrint('profileProvider -- deleteProfile: профиль удалён = $result');
      return result;
    } catch (e) {
      debugPrint('profileProvider -- deleteProfile error: $e');
      return false;
    }
  }

  /// 🚀 ==========================
  /// 🚀 Квесты: энергия, сускоины, streak
  /// 🚀 ==========================

  Future<void> addSuscoins(int count) async {
    final newSuscoins = (state.suscoins) + count;
    await _profileService.saveProfile(suscoins: newSuscoins);
    state = state.copyWith(suscoins: newSuscoins);
    debugPrint('profileProvider -- addSuscoins: +$count => $newSuscoins');
  }

  Future<void> spendSuscoins(int count) async {
    final newSuscoins = (state.suscoins - count).clamp(0, 999999);
    await _profileService.saveProfile(suscoins: newSuscoins);
    state = state.copyWith(suscoins: newSuscoins);
    debugPrint('profileProvider -- spendSuscoins: -$count => $newSuscoins');
  }

  Future<void> addEnergy(int count) async {
    final newEnergy = (state.energy) + count;
    await _profileService.saveProfile(energy: newEnergy);
    state = state.copyWith(energy: newEnergy);
    debugPrint('profileProvider -- addEnergy: +$count => $newEnergy');
  }

  Future<void> spendEnergy(int count) async {
    final newEnergy = (state.energy - count).clamp(0, 999);
    await _profileService.saveProfile(energy: newEnergy);
    state = state.copyWith(energy: newEnergy);
    debugPrint('profileProvider -- spendEnergy: -$count => $newEnergy');
  }

  Future<void> incrementStreak() async {
    final newStreak = (state.streak) + 1;
    await _profileService.saveProfile(streak: newStreak);
    state = state.copyWith(streak: newStreak);
    debugPrint('profileProvider -- incrementStreak: => $newStreak');
  }

  Future<void> resetStreak() async {
    await _profileService.saveProfile(streak: 0);
    state = state.copyWith(streak: 0);
    debugPrint('profileProvider -- resetStreak: streak сброшен');
  }
}
