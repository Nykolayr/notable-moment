import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/global/provider/global_screen_provider.dart';
import 'package:notable_moments/features/global/enum/global_screen_enum.dart';
import 'package:notable_moments/features/routes/app_router_root.dart';
import 'package:notable_moments/core/theme/app_color.dart';

final navigatorKeysProvider = Provider<List<GlobalKey<NavigatorState>>>(
  (ref) => List.generate(
    GlobalScreen.values.length,
    (index) => GlobalKey<NavigatorState>(),
  ),
);

class NotableApp extends ConsumerWidget {
  const NotableApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(globalScreenProvider);
    final navigatorKeys = ref.watch(navigatorKeysProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notable Moments',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light,
      locale: const Locale('ru'),
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LayoutBuilder(
        builder: (context, constraints) {
          return Navigator(
            key: navigatorKeys[screen.index],
            onGenerateRoute: (settings) {
              return appRouterRoot.generateRoute(settings, screen);
            },
          );
        },
      ),
    );
  }
}
