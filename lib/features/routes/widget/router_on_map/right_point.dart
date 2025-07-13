import 'package:flutter/material.dart';
import 'curve_quarter.dart';

class RightPoint extends StatelessWidget {
  final double centerY;
  final double lineHeight;
  final double centerX;
  final double curveSize;
  final bool isBlue;
  final int rowIndex;
  final bool isLastRow;
  final bool isFirstRow;
  const RightPoint({
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
      // Первая строка — rightTop
      return Positioned(
        right: 15,
        top: centerY - 15,
        child: CurveQuarter(
          isBlue: isBlue,
          corner: QuarterCorner.rightTop,
        ),
      );
    } else if (isLastRow && rowIndex % 2 == 0) {
      // Последняя строка и она чётная — линия
      return Positioned(
        right: 0,
        top: centerY - lineHeight / 2 - 15,
        width: MediaQuery.of(context).size.width - centerX,
        height: lineHeight,
        child: Container(
          color: isBlue ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD),
        ),
      );
    } else if (rowIndex % 2 == 0) {
      // Чётная строка (2, 4, ...) — rightTop
      return Positioned(
        right: 15,
        top: centerY - 15,
        child: CurveQuarter(
          isBlue: isBlue,
          corner: QuarterCorner.rightTop,
        ),
      );
    } else {
      // Нечётная строка (3, 5, ...) — rightBottom
      return Positioned(
        right: 15,
        top: centerY - 15,
        child: CurveQuarter(
          isBlue: isBlue,
          corner: QuarterCorner.rightBottom,
        ),
      );
    }
  }
}
