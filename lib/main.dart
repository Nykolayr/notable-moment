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
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    final screen = ref.watch(globalScreenProvider);

    return GestureDetector(
      onTap: context.unfocus,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Родные штрихи',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
          scaffoldBackgroundColor: Colors.white,
        ),
        builder: (context, child) => ResponsiveScaledBox(width: 360, child: child!),
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
        home: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }
            final user = snapshot.data;
            if (user == null) {
              // Пользователь не авторизован
              return const AuthLoginScreen();
            } else {
              // Пользователь авторизован
              return Navigator(
                key: navigatorKeys[screen.index],
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => switch (screen) {
                      GlobalScreen.onboarding => const OnboardingScreen(),
                      GlobalScreen.auth => const AuthLoginScreen(),
                      GlobalScreen.fillProfile => const AuthFillProfileScreen(),
                      GlobalScreen.main => const MainScreen(),
                      GlobalScreen.loading => const LoadingScreen(),
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
