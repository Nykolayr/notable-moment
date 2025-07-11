import 'package:flutter/material.dart';
import 'package:notable_moments/features/onboarding/onboarding_screen.dart';
import 'package:notable_moments/features/auth/auth_login_screen.dart';
import 'package:notable_moments/features/auth/auth_fill_profile_screen.dart';
import 'package:notable_moments/features/global/loading_screen.dart';
import 'package:notable_moments/features/global/main_screen.dart';
import 'package:notable_moments/features/global/enum/global_screen_enum.dart';

final Map<GlobalScreen, Widget> _screenMap = {
  GlobalScreen.onboarding: const OnboardingScreen(),
  GlobalScreen.auth: const AuthLoginScreen(),
  GlobalScreen.fillProfile: const AuthFillProfileScreen(),
  GlobalScreen.loading: const LoadingScreen(),
  GlobalScreen.main: const MainScreen(),
};

Widget getScreen(GlobalScreen screen) => _screenMap[screen]!;

final appRouterRoot = _AppRouterRoot();

class _AppRouterRoot {
  Route<dynamic> generateRoute(RouteSettings settings, GlobalScreen screen) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => getScreen(screen),
    );
  }
}
