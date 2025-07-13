import 'package:flutter/material.dart';
import 'curve_quarter.dart';

class LeftPoint extends StatelessWidget {
  final double centerY;
  final double lineHeight;
  final double centerX;
  final double curveSize;
  final bool isBlue;
  final int rowIndex;
  final bool isLastRow;
  final bool isFirstRow;
  const LeftPoint({
    super.key,
    required this.centerY,
    required this.lineHeight,
    required this.centerX,
    required this.curveSize,
    required this.isBlue,
    required this.rowIndex,
    required this.isLastRow,
    required this.isFirstRow,
  });

  @override
  Widget build(BuildContext context) {
    if (isFirstRow) {
      // Первая строка — линия
      return Positioned(
        left: 0,
        top: centerY - lineHeight / 2 - 15,
        width: centerX,
        height: lineHeight,
        child: Container(
          color: isBlue ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD),
        ),
      );
    } else if (isLastRow && rowIndex % 2 == 1) {
      // Последняя строка и она нечётная — линия
      return Positioned(
        left: 0,
        top: centerY - lineHeight / 2 - 15,
        width: centerX,
        height: lineHeight,
        child: Container(
          color: isBlue ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD),
        ),
      );
    } else if (rowIndex % 2 == 0) {
      // Чётная строка (2, 4, ...) — leftBottom
      return Positioned(
        left: 15,
        top: centerY - 15,
        child: CurveQuarter(
          isBlue: isBlue,
          corner: QuarterCorner.leftBottom,
        ),
      );
    } else {
      // Нечётная строка (3, 5, ...) — leftTop
      return Positioned(
        left: 15,
        top: centerY - 15,
        child: CurveQuarter(
          isBlue: isBlue,
          corner: QuarterCorner.leftTop,
        ),
      );
    }
  }
}
