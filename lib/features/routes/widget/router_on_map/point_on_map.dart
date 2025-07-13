import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_item.dart';
import 'curve_quarter.dart';

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
    const double quarterSize = 58;
    const double step = quarterSize * 2;
    const double circleDiameter = 60;
    const double horizontalPadding = 75;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double leftX = horizontalPadding - 4;
    final double rightX = screenWidth - horizontalPadding - circleDiameter + 4;
    final double centerX = (screenWidth - circleDiameter) / 2;

    List<Widget> stackChildren = [];
    List<Widget> lines = []; // Отдельный список для линий
    List<Widget> circlesAndLabels = []; // Отдельный список для кружков и подписей
    int i = 0;
    int rowIndex = 0;

    while (i < points.length) {
      // 2-1-2-1 чередование
      if ((rowIndex % 2 == 0) && (i + 1 < points.length)) {
        // Два поинта: слева и справа
        final double y = rowIndex * step;

        // Линия для первого row (от края до центра первого кружка)
        if (rowIndex == 0) {
          lines.add(Positioned(
            left: 0,
            top: y + (circleDiameter - 10) / 2, // По центру кружка
            width: leftX + circleDiameter / 2, // До центра кружка
            height: 10,
            child: Container(color: const Color(0xFF466BFF)),
          ));
        }

        // Слева кружок
        circlesAndLabels.add(Positioned(
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
        circlesAndLabels.add(Positioned(
          left: leftX - ((screenWidth / 2) - 60 - circleDiameter) / 2, // Центрирую относительно кружка
          top: y + circleDiameter + 8,
          child: Container(
            width: (screenWidth / 2) - 60,
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
        circlesAndLabels.add(Positioned(
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
        circlesAndLabels.add(Positioned(
          left: rightX - ((screenWidth / 2) - 60 - circleDiameter) / 2, // Центрирую относительно кружка
          top: y + circleDiameter + 8,
          child: Container(
            width: (screenWidth / 2) - 60,
            child: Text(
              points[i + 1].name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));

        // rightTop четверть для четных row (начинается от середины правого кружка)
        if (i + 2 < points.length) {
          // Не последний row
          final bool isRightUnlocked = (i + 1) <= lastUnlockedIndex;
          lines.add(Positioned(
            right: 15, // 15 от правого края
            top: y + circleDiameter / 2, // От центра кружка по высоте
            child: CurveQuarter(
              isBlue: isRightUnlocked,
              corner: QuarterCorner.rightTop,
              size: step,
            ),
          ));
        }

        // rightBottom четверть для четных row (начинается от середины правого кружка)
        if (i + 2 < points.length) {
          // Не последний row
          final bool isRightUnlocked = (i + 1) <= lastUnlockedIndex;
          lines.add(Positioned(
            right: 15, // 15 от правого края
            top: y + circleDiameter / 2, // От центра кружка по высоте
            child: CurveQuarter(
              isBlue: isRightUnlocked,
              corner: QuarterCorner.rightBottom,
            ),
          ));
        }

        // leftBottom четверть для четных row (начинается от середины левого кружка)
        if (i + 2 < points.length && rowIndex > 0) {
          // Не последний row и не первый row
          final bool isLeftUnlocked = i <= lastUnlockedIndex;
          lines.add(Positioned(
            left: 15, // 15 от левого края
            top: y - step + circleDiameter / 2,
            child: CurveQuarter(
              isBlue: isLeftUnlocked,
              corner: QuarterCorner.leftBottom,
            ),
          ));
        }

        // Линия для последнего четного row (справа от края до центра правого кружка)
        if (i + 2 >= points.length) {
          final bool isRightUnlocked = (i + 1) <= lastUnlockedIndex;
          final Color lineColor = isRightUnlocked ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD);

          lines.add(Positioned(
            left: rightX + circleDiameter / 2, // От центра правого кружка
            top: y + (circleDiameter - 10) / 2, // По центру кружка
            width: screenWidth - (rightX + circleDiameter / 2), // До края экрана
            height: 10,
            child: Container(color: lineColor),
          ));

          // leftBottom четверть для последнего четного row (где линия справа)
          lines.add(Positioned(
            left: 15, // 15 от левого края
            top: y - step + circleDiameter / 2,
            child: CurveQuarter(
              isBlue: isRightUnlocked,
              corner: QuarterCorner.leftBottom,
            ),
          ));
        }

        i += 2;
        rowIndex++;
      } else {
        // Один поинт по центру
        final double y = rowIndex * step;

        circlesAndLabels.add(Positioned(
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
        circlesAndLabels.add(Positioned(
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

        // rightBottom четверть для нечетных row (начинается от середины правого кружка)
        if (i + 1 < points.length) {
          // Не последний row
          final bool isCenterUnlocked = i <= lastUnlockedIndex;
          lines.add(Positioned(
            right: 15, // 15 от правого края
            top: y - step + circleDiameter / 2, // От центра кружка по высоте
            child: CurveQuarter(
              isBlue: isCenterUnlocked,
              corner: QuarterCorner.rightBottom,
              size: step,
            ),
          ));
        }

        // leftTop четверть для нечетных row (начинается от середины левого кружка)
        if (i + 1 < points.length) {
          // Не последний row
          final bool isCenterUnlocked = i <= lastUnlockedIndex;
          lines.add(Positioned(
            left: 15, // 15 от левого края
            top: y + circleDiameter / 2, // От центра кружка по высоте
            child: CurveQuarter(
              isBlue: isCenterUnlocked,
              corner: QuarterCorner.leftTop,
            ),
          ));
        }

        // Линия для последнего нечетного row (слева от края до центра кружка)
        if (i + 1 >= points.length) {
          final bool isCenterUnlocked = i <= lastUnlockedIndex;

          // rightTop четверть для последнего нечетного row (где нет линии слева)
          lines.add(Positioned(
            right: 15, // 15 от правого края
            top: y + circleDiameter / 2, // От центра кружка по высоте
            child: CurveQuarter(
              isBlue: isCenterUnlocked,
              corner: QuarterCorner.rightTop,
            ),
          ));
        }

        i += 1;
        rowIndex++;
      }
    }

    // Сначала добавляем линии (фон), потом кружки и подписи (поверх)
    stackChildren.addAll(lines);
    stackChildren.addAll(circlesAndLabels);

    final double totalHeight = rowIndex * step + circleDiameter;
    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: Stack(children: stackChildren),
    );
  }
}
