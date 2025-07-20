import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/features/places/places_screen.dart';
import 'package:notable_moments/features/profile/profile_screen.dart';
import 'package:notable_moments/features/routes/routes_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 1;

  void selectIndex(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool result, PopInvokedWithResultCallback? callback) async {
        print('>>> onPopInvokedWithResult main: $result, $callback');
        // Показываем диалог подтверждения выхода
        final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Выход из приложения'),
                content: const Text('Вы уверены, что хотите выйти из приложения?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            ) ??
            false;

        // Если пользователь подтвердил выход, закрываем приложение
        if (shouldPop) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.bgText00,
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  const PlacesScreen(),
                  RoutesScreen(isActive: true),
                  const ProfileScreen(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 6, bottom: 6 + context.safeArea.bottom),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.bgText00,
                border: Border(top: BorderSide(color: AppColor.bgText200)),
              ),
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BottomItem(
                    title: 'Места',
                    onTap: () => selectIndex(0),
                    icon: AppIcon.places,
                    isActive: _currentIndex == 0,
                  ),
                  const SizedBox(width: 24),
                  _BottomItem(
                    title: 'Маршруты',
                    onTap: () => selectIndex(1),
                    icon: AppIcon.routes,
                    isActive: _currentIndex == 1,
                  ),
                  const SizedBox(width: 24),
                  _BottomItem(
                    title: 'Профиль',
                    onTap: () => selectIndex(2),
                    icon: AppIcon.profile,
                    isActive: _currentIndex == 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.title, required this.onTap, required this.icon, required this.isActive});

  final String title;
  final VoidCallback onTap;
  final String icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColor.bgText900 : AppColor.bgText500;

    return AppGestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: deprecated_member_use
            SvgPicture.asset(icon, color: color),
            const SizedBox(height: 2),
            Text(title, style: AppStyle.subtext.copyWith(color: color).h1),
          ],
        ),
      ),
    );
  }
}
