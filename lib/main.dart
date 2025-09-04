import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/features/auth/auth_fill_profile_screen.dart';
import 'package:notable_moments/features/auth/auth_login_screen.dart';
import 'package:notable_moments/features/global/enum/global_screen_enum.dart';
import 'package:notable_moments/features/global/loading_screen.dart';
import 'package:notable_moments/features/global/main_screen.dart';
import 'package:notable_moments/features/global/provider/global_screen_provider.dart';
import 'package:notable_moments/features/onboarding/onboarding_screen.dart';
import 'package:notable_moments/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:notable_moments/core/provider/auth_provider.dart';
import 'package:notable_moments/core/provider/auth_state.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Загрузка .env
  try {
    await dotenv.load();
  } catch (e) {
    Logger.e('Ошибка загрузки .env: $e');
  }

  // Инициализация Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    Logger.e('Ошибка инициализации Firebase: $e');
  }

  // Запрос разрешения геолокации
  await Permission.location.request();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final List<GlobalKey> navigatorKeys = List.generate(
    GlobalScreen.values.length,
    (index) => GlobalKey<NavigatorState>(),
  );

  // Уникальный ключ для текущего экрана
  String _currentScreenKey = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);
        final screen = ref.watch(globalScreenProvider);

        Logger.i(
            'main.dart build: authState.isAuthenticated: ${authState.isAuthenticated}');
        Logger.i('main.dart build: screen: ${screen.name}');
        Logger.i('main.dart build: screen.index: ${screen.index}');

        return GestureDetector(
          onTap: context.unfocus,
          child: MaterialApp(
            key: ValueKey('material_app_${screen.name}_${screen.index}'),
            debugShowCheckedModeBanner: false,
            title: 'Родные штрихи',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
              scaffoldBackgroundColor: Colors.white,
            ),
            builder: (context, child) =>
                ResponsiveScaledBox(width: 360, child: child!),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru'),
              Locale('en'),
            ],
            locale: const Locale('ru'),
            navigatorObservers: [routeObserver],
            home: _buildHome(authState, screen),
          ),
        );
      },
    );
  }

  Widget _buildHome(AuthState authState, GlobalScreen screen) {
    if (!authState.isAuthenticated) {
      // Пользователь не авторизован
      Logger.i('main.dart _buildHome: возвращаем AuthLoginScreen');
      return const AuthLoginScreen();
    } else if (authState.isLoading) {
      // Пользователь авторизован, но идет загрузка (регистрация)
      Logger.i('main.dart _buildHome: возвращаем LoadingScreen (регистрация)');
      return const LoadingScreen();
    } else {
      // Пользователь авторизован и загрузка завершена
      Logger.i('main.dart _buildHome: возвращаем экран: ${screen.name}');

      // ПРОСТО ВОЗВРАЩАЕМ НУЖНЫЙ ЭКРАН БЕЗ Navigator!
      return switch (screen) {
        GlobalScreen.onboarding => const OnboardingScreen(),
        GlobalScreen.auth => const AuthLoginScreen(),
        GlobalScreen.fillProfile => const AuthFillProfileScreen(),
        GlobalScreen.main => const MainScreen(),
        GlobalScreen.loading => const LoadingScreen(),
      };
    }
  }
}
