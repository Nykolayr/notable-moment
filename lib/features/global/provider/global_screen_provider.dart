import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/provider/auth_provider.dart';
import 'package:notable_moments/core/provider/auth_state.dart';
import 'package:notable_moments/features/global/enum/global_screen_enum.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/profile/provider/profile_state.dart';

/// Добавляем расширение, если по какой-то причине в AuthState не видно геттер
extension AuthStateExtension on AuthState {
  bool get isAuthenticated => user != null;
}

/// Комбинированный провайдер для удобного получения состояния авторизации и профиля
final _combinedProvider = Provider<(AuthState, ProfileState)>((ref) {
  final authState = ref.watch(authProvider);
  final profileState = ref.watch(profileProvider);
  return (authState, profileState);
});

/// Провайдер экрана, управляет навигацией по экрану в зависимости от статуса авторизации и профиля
final globalScreenProvider = StateNotifierProvider<GlobalScreenNotifier, GlobalScreen>((ref) {
  return GlobalScreenNotifier(ref);
});

class GlobalScreenNotifier extends StateNotifier<GlobalScreen> {
  final Ref ref;
  User? user;
  bool justStarted = true;

  GlobalScreenNotifier(this.ref) : super(GlobalScreen.onboarding) {
    user = FirebaseAuth.instance.currentUser;

    ref.listen<(AuthState, ProfileState)>(
      _combinedProvider,
      (previous, current) {
        final (authState, profileState) = current;

        Logger.i('globalScreenProvider isAuthenticated: ${authState.isAuthenticated}');

        if (authState.isAuthenticated) {
          justStarted = false;
        }

        if (!authState.isAuthenticated && justStarted) {
          state = GlobalScreen.onboarding;
          return;
        }

        if (!authState.isAuthenticated) {
          state = GlobalScreen.auth;
          return;
        }

        if (profileState.showLoading) {
          state = GlobalScreen.loading;
          return;
        }

        if (profileState.needToFill) {
          state = GlobalScreen.fillProfile;
        } else {
          state = GlobalScreen.main;
        }
      },
    );
  }

  /// Завершить онбординг вручную
  void finishOnboarding() {
    state = GlobalScreen.auth;
    justStarted = false;
  }
}
