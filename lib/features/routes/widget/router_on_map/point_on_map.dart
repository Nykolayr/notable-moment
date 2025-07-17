import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_item.dart';
import 'curve_quarter.dart';

class PointsOnMap extends StatelessWidget {
  final List<RoutePoint> points;
  final int lastUnlockedIndex;
  final void Function(int index, bool isLocked) onPointTap;

  const PointsOnMap({
    super.key,
    required this.points,
    required this.lastUnlockedIndex,
    required this.onPointTap,
  });

  void _handlePointTap(BuildContext context, int index, bool isLocked, bool isFirstLocked) {
    if (isLocked) {
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF757B83),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Пройди все места выше, чтобы открыть доступ!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      );
      overlay.insert(overlayEntry);
      Future.delayed(const Duration(seconds: 6), () => overlayEntry.remove());
    } else {
      onPointTap(index, isFirstLocked);
    }
  }

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
    int pointIndex = 0; // Только для кружков

    while (i < points.length) {
      // 2-1-2-1 чередование
      if ((rowIndex % 2 == 0) && (i + 1 < points.length)) {
        // Два поинта: слева и справа
        final double y = rowIndex * step;

        // Линия для первого row (от края до центра первого кружка)
        if (rowIndex == 0) {
          lines.add(
            Positioned(
              left: 0,
              top: y + (circleDiameter - 10) / 2, // По центру кружка
              width: leftX + circleDiameter / 2, // До центра кружка
              height: 10,
              child: Container(
                color: const Color(0xFF466BFF),
              ),
            ),
          );
        }

        // Для левого кружка:
        final isUnlocked = i <= lastUnlockedIndex;
        final isFirstLocked = i == lastUnlockedIndex + 1;
        final isLocked = !isUnlocked && !isFirstLocked;

        circlesAndLabels.add(
          Positioned(
            left: leftX,
            top: y,
            child: CirclePoint(
              isUnlocked: isUnlocked,
              isFirstLocked: isFirstLocked,
              isLocked: isLocked,
              childIcon: isLocked
                  ? SvgPicture.asset(
                      'assets/svg/lock.svg',
                      width: 20,
                      height: 20,
                    )
                  : null,
              onTap: (index, isLocked, isFirstLocked) {
                _handlePointTap(context, index, isLocked, isFirstLocked);
              },
              pointIndex: pointIndex,
            ),
          ),
        );

        // Подпись слева в контейнере
        circlesAndLabels.add(
          Positioned(
            left: leftX - ((screenWidth / 2) - 60 - circleDiameter) / 2, // Центрирую относительно кружка
            top: y + circleDiameter + 8,
            child: SizedBox(
              width: (screenWidth / 2) - 60,
              child: Text(
                points[i].name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );

        // Для правого кружка:
        final isUnlockedRight = (i + 1) <= lastUnlockedIndex;
        final isFirstLockedRight = (i + 1) == lastUnlockedIndex + 1;
        final isLockedRight = !isUnlockedRight && !isFirstLockedRight;

        circlesAndLabels.add(
          Positioned(
            left: rightX,
            top: y,
            child: CirclePoint(
              isUnlocked: isUnlockedRight,
              isFirstLocked: isFirstLockedRight,
              isLocked: isLockedRight,
              childIcon: isLockedRight
                  ? SvgPicture.asset(
                      'assets/svg/lock.svg',
                      width: 20,
                      height: 20,
                    )
                  : null,
              onTap: (index, isLocked, isFirstLocked) {
                _handlePointTap(context, index, isLocked, isFirstLocked);
              },
              pointIndex: pointIndex + 1,
            ),
          ),
        );

        // Подпись справа в контейнере
        circlesAndLabels.add(
          Positioned(
            left: rightX - ((screenWidth / 2) - 60 - circleDiameter) / 2, // Центрирую относительно кружка
            top: y + circleDiameter + 8,
            child: SizedBox(
              width: (screenWidth / 2) - 60,
              child: Text(
                points[i + 1].name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );

        // Линия между двумя кружками на четных row
        final bool isLeftUnlocked = i <= lastUnlockedIndex;
        final bool isRightUnlocked = (i + 1) <= lastUnlockedIndex;
        final Color lineColor = (isLeftUnlocked && isRightUnlocked) ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD);

        lines.add(
          Positioned(
            left: leftX + circleDiameter, // От центра левого кружка
            top: y + (circleDiameter - 10) / 2, // По центру кружка
            width: rightX - (leftX + circleDiameter), // До центра правого кружка
            height: 10,
            child: Container(color: lineColor),
          ),
        );

        // rightTop четверть для четных row (начинается от середины правого кружка)
        if (i + 2 < points.length) {
          // Не последний row
          final bool isRightUnlocked = (i + 1) <= lastUnlockedIndex;
          lines.add(
            Positioned(
              right: 15, // 15 от правого края
              top: y + circleDiameter / 2, // От центра кружка по высоте
              child: CurveQuarter(
                isBlue: isRightUnlocked,
                corner: QuarterCorner.rightTop,
                size: step,
              ),
            ),
          );
        }

        // rightBottom четверть для четных row (начинается от середины правого кружка)
        if (i + 2 < points.length) {
          // Не последний row
          final bool isRightUnlocked = (i + 1) <= lastUnlockedIndex;
          lines.add(
            Positioned(
              right: 15, // 15 от правого края
              top: y + circleDiameter / 2, // От центра кружка по высоте
              child: CurveQuarter(
                isBlue: isRightUnlocked,
                corner: QuarterCorner.rightBottom,
              ),
            ),
          );
        }

        // leftBottom четверть для четных row (начинается от середины левого кружка)
        if (i + 2 < points.length && rowIndex > 0) {
          // Не последний row и не первый row
          final bool isLeftUnlocked = i <= lastUnlockedIndex;
          lines.add(
            Positioned(
              left: 15, // 15 от левого края
              top: y - step + circleDiameter / 2,
              child: CurveQuarter(
                isBlue: isLeftUnlocked,
                corner: QuarterCorner.leftBottom,
              ),
            ),
          );
        }

        // Линия для последнего четного row (справа от края до центра правого кружка)
        if (i + 2 >= points.length) {
          final bool isRightUnlocked = (i + 1) <= lastUnlockedIndex;
          final Color lineColor = isRightUnlocked ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD);

          lines.add(
            Positioned(
              left: rightX + circleDiameter / 2, // От центра правого кружка
              top: y + (circleDiameter - 10) / 2, // По центру кружка
              width: screenWidth - (rightX + circleDiameter / 2), // До края экрана
              height: 10,
              child: Container(color: lineColor),
            ),
          );

          // leftBottom четверть для последнего четного row (где линия справа)
          lines.add(
            Positioned(
              left: 15, // 15 от левого края
              top: y - step + circleDiameter / 2,
              child: CurveQuarter(
                isBlue: isRightUnlocked,
                corner: QuarterCorner.leftBottom,
              ),
            ),
          );
        }

        i += 2;
        rowIndex++;
        pointIndex += 2; // Увеличиваем на 2 для двух кружков

        // Проверяем, не вышли ли за границы после увеличения i
        if (i >= points.length) break;
      } else if ((rowIndex % 2 == 0) && (i + 1 >= points.length)) {
        // Случай, когда должны быть двойные точки, но осталась только одна
        // Используем логику для одиночной точки
        final double y = rowIndex * step;

        // Для центрального кружка:
        final isUnlockedCenter = i <= lastUnlockedIndex;
        final isFirstLockedCenter = i == lastUnlockedIndex + 1;
        final isLockedCenter = !isUnlockedCenter && !isFirstLockedCenter;

        circlesAndLabels.add(
          Positioned(
            left: centerX,
            top: y,
            child: CirclePoint(
              isUnlocked: isUnlockedCenter,
              isFirstLocked: isFirstLockedCenter,
              isLocked: isLockedCenter,
              childIcon: isLockedCenter
                  ? SvgPicture.asset(
                      'assets/svg/lock.svg',
                      width: 20,
                      height: 20,
                    )
                  : null,
              onTap: (index, isLocked, isFirstLocked) {
                _handlePointTap(context, index, isLocked, isFirstLocked);
              },
              pointIndex: pointIndex,
            ),
          ),
        );

        // Подпись по центру в контейнере
        circlesAndLabels.add(
          Positioned(
            left: centerX - (screenWidth - 80 - circleDiameter) / 2, // Центрирую относительно кружка
            top: y + circleDiameter + 8,
            child: SizedBox(
              width: screenWidth - 90, // Формула для одного кружка
              child: Text(
                points[i].name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );

        // Линии слева и справа от центрального кружка до краев экрана
        final bool isCenterUnlocked = i <= lastUnlockedIndex;
        final Color lineColor = isCenterUnlocked ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD);

        // Линия слева от края до кружка
        lines.add(
          Positioned(
            left: 0,
            top: y + (circleDiameter - 10) / 2, // По центру кружка
            width: centerX, // До центра кружка
            height: 10,
            child: Container(color: lineColor),
          ),
        );

        // Линия справа от кружка до края
        lines.add(
          Positioned(
            left: centerX + circleDiameter, // От правого края кружка
            top: y + (circleDiameter - 10) / 2, // По центру кружка
            width: screenWidth - (centerX + circleDiameter), // До края экрана
            height: 10,
            child: Container(color: lineColor),
          ),
        );

        // leftBottom четверть для соединения с предыдущим рядом (если это не первый ряд)
        if (rowIndex > 0) {
          lines.add(
            Positioned(
              left: 15, // 15 от левого края
              top: y - step + circleDiameter / 2,
              child: CurveQuarter(
                isBlue: isCenterUnlocked,
                corner: QuarterCorner.leftBottom,
              ),
            ),
          );
        }

        i += 1;
        rowIndex++;
        pointIndex += 1;
      } else {
        // Один поинт по центру
        final double y = rowIndex * step;

        // Для центрального кружка:
        final isUnlockedCenter = i <= lastUnlockedIndex;
        final isFirstLockedCenter = i == lastUnlockedIndex + 1;
        final isLockedCenter = !isUnlockedCenter && !isFirstLockedCenter;

        circlesAndLabels.add(
          Positioned(
            left: centerX,
            top: y,
            child: CirclePoint(
              isUnlocked: isUnlockedCenter,
              isFirstLocked: isFirstLockedCenter,
              isLocked: isLockedCenter,
              childIcon: isLockedCenter
                  ? SvgPicture.asset(
                      'assets/svg/lock.svg',
                      width: 20,
                      height: 20,
                    )
                  : null,
              onTap: (index, isLocked, isFirstLocked) {
                _handlePointTap(context, index, isLocked, isFirstLocked);
              },
              pointIndex: pointIndex,
            ),
          ),
        );

        // Подпись по центру в контейнере
        circlesAndLabels.add(
          Positioned(
            left: centerX - (screenWidth - 80 - circleDiameter) / 2, // Центрирую относительно кружка
            top: y + circleDiameter + 8,
            child: SizedBox(
              width: screenWidth - 90, // Формула для одного кружка
              child: Text(
                points[i].name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9198A1), fontWeight: FontWeight.w500, fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );

        // rightBottom четверть для нечетных row (начинается от середины правого кружка)
        if (i + 1 < points.length) {
          // Не последний row
          final bool isCenterUnlocked = i <= lastUnlockedIndex;
          lines.add(
            Positioned(
              right: 15, // 15 от правого края
              top: y - step + circleDiameter / 2, // От центра кружка по высоте
              child: CurveQuarter(
                isBlue: isCenterUnlocked,
                corner: QuarterCorner.rightBottom,
                size: step,
              ),
            ),
          );
        }

        // leftTop четверть для нечетных row (начинается от середины левого кружка)
        if (i + 1 < points.length) {
          // Не последний row
          final bool isCenterUnlocked = i <= lastUnlockedIndex;
          lines.add(
            Positioned(
              left: 15, // 15 от левого края
              top: y + circleDiameter / 2, // От центра кружка по высоте
              child: CurveQuarter(
                isBlue: isCenterUnlocked,
                corner: QuarterCorner.leftTop,
              ),
            ),
          );

          // Линия слева от четверти до кружка
          lines.add(
            Positioned(
              left: 15 + 58, // От четверти (15 + размер четверти)
              top: y + (circleDiameter - 10) / 2, // По центру кружка
              width: centerX - (15 + 58), // До центра кружка
              height: 10,
              child: Container(color: isCenterUnlocked ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD)),
            ),
          );

          // Линия справа от кружка до четверти
          lines.add(
            Positioned(
              left: centerX + circleDiameter / 2, // От центра кружка
              top: y + (circleDiameter - 10) / 2, // По центру кружка
              width: screenWidth - 15 - 58 - (centerX + circleDiameter / 2), // До четверти справа
              height: 10,
              child: Container(color: isCenterUnlocked ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD)),
            ),
          );
        }

        // Линия для последнего нечетного row (слева от края до центра кружка)
        if (i + 1 >= points.length) {
          final bool isCenterUnlocked = i <= lastUnlockedIndex;

          // rightTop четверть для последнего нечетного row (где нет линии слева)
          lines.add(
            Positioned(
              right: 15, // 15 от правого края
              top: y + circleDiameter / 2, // От центра кружка по высоте
              child: CurveQuarter(
                isBlue: isCenterUnlocked,
                corner: QuarterCorner.rightTop,
              ),
            ),
          );
        }

        i += 1;
        rowIndex++;
        pointIndex += 1; // Увеличиваем на 1 для одного кружка
      }
    }

    // Сначала добавляем линии (фон), потом кружки и подписи (поверх)
    stackChildren.addAll(lines);
    stackChildren.addAll(circlesAndLabels);

    // Правильный расчет высоты: последний row + высота кружка + отступ для подписи
    final double totalHeight = (rowIndex - 1) * step + circleDiameter + 40; // 40px для подписи
    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: Stack(children: stackChildren),
    );
  }
}
