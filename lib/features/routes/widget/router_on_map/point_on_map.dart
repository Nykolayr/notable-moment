import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CirclePoint extends StatelessWidget {
  final bool isUnlocked;
  final bool isFirstLocked;
  final bool isLocked;
  final Widget? childIcon;

  const CirclePoint({
    super.key,
    required this.isUnlocked,
    required this.isFirstLocked,
    required this.isLocked,
    this.childIcon,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color fillColor;

    if (isUnlocked) {
      borderColor = const Color(0xFF466BFF);
      fillColor = const Color(0xFF466BFF);
    } else if (isFirstLocked) {
      borderColor = const Color(0xFF466BFF);
      fillColor = const Color(0xFF74A5FF);
    } else {
      borderColor = const Color(0xFFBCC3CD);
      fillColor = const Color(0xFFE1E9F4);
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Center(child: childIcon),
    );
  }
}

class PointsOnMap extends StatelessWidget {
  final List<RoutePoint> points;
  final int lastUnlockedIndex;

  const PointsOnMap({
    super.key,
    required this.points,
    required this.lastUnlockedIndex,
  });

  @override
  Widget build(BuildContext context) {
    const double step = 116; // 58 * 2
    const double circleDiameter = 60;
    const double horizontalPadding = 75;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double leftX = horizontalPadding;
    final double rightX = screenWidth - horizontalPadding - circleDiameter;
    final double centerX = (screenWidth - circleDiameter) / 2;

    List<Widget> stackChildren = [];
    int i = 0;
    int rowIndex = 0;

    while (i < points.length) {
      // 2-1-2-1 чередование
      if ((rowIndex % 2 == 0) && (i + 1 < points.length)) {
        // Два поинта: слева и справа
        final double y = rowIndex * step;

        // Слева кружок
        stackChildren.add(Positioned(
          left: leftX,
          top: y,
          child: CirclePoint(
            isUnlocked: i <= lastUnlockedIndex,
            isFirstLocked: i == lastUnlockedIndex + 1,
            isLocked: i > lastUnlockedIndex + 1,
            childIcon: i > lastUnlockedIndex + 1
                ? SvgPicture.asset(
                    'assets/svg/lock.svg',
                    width: 20,
                    height: 20,
                  )
                : null,
          ),
        ));

        // Подпись слева в контейнере
        stackChildren.add(Positioned(
          left: leftX - ((screenWidth / 2) - 60 - circleDiameter) / 2, // Центрирую относительно кружка
          top: y + circleDiameter + 8,
          child: Container(
            width: (screenWidth / 2) - 60, // Формула для двух кружков
            child: Text(
              points[i].name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));

        // Справа кружок
        stackChildren.add(Positioned(
          left: rightX,
          top: y,
          child: CirclePoint(
            isUnlocked: (i + 1) <= lastUnlockedIndex,
            isFirstLocked: (i + 1) == lastUnlockedIndex + 1,
            isLocked: (i + 1) > lastUnlockedIndex + 1,
            childIcon: (i + 1) > lastUnlockedIndex + 1
                ? SvgPicture.asset(
                    'assets/svg/lock.svg',
                    width: 20,
                    height: 20,
                  )
                : null,
          ),
        ));

        // Подпись справа в контейнере
        stackChildren.add(Positioned(
          left: rightX - ((screenWidth / 2) - 60 - circleDiameter) / 2, // Центрирую относительно кружка
          top: y + circleDiameter + 8,
          child: Container(
            width: (screenWidth / 2) - 60, // Формула для двух кружков
            child: Text(
              points[i + 1].name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));

        i += 2;
        rowIndex++;
      } else {
        // Один поинт по центру
        final double y = rowIndex * step;

        stackChildren.add(Positioned(
          left: centerX,
          top: y,
          child: CirclePoint(
            isUnlocked: i <= lastUnlockedIndex,
            isFirstLocked: i == lastUnlockedIndex + 1,
            isLocked: i > lastUnlockedIndex + 1,
            childIcon: i > lastUnlockedIndex + 1
                ? SvgPicture.asset(
                    'assets/svg/lock.svg',
                    width: 20,
                    height: 20,
                  )
                : null,
          ),
        ));

        // Подпись по центру в контейнере
        stackChildren.add(Positioned(
          left: centerX - (screenWidth - 80 - circleDiameter) / 2, // Центрирую относительно кружка
          top: y + circleDiameter + 8,
          child: Container(
            width: screenWidth - 90, // Формула для одного кружка
            child: Text(
              points[i].name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));

        i += 1;
        rowIndex++;
      }
    }

    final double totalHeight = rowIndex * step + circleDiameter;
    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: Stack(children: stackChildren),
    );
  }
}
