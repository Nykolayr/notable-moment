import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_item.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/left_point.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/right_point.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/center_point.dart';

class RowForTwo extends StatelessWidget {
  final List<RoutePoint> points;
  final bool isLast;
  final bool isFirst;
  final bool isLeft;
  final int indexFirstUnlocked;
  final int lastUnlockedIndex;
  final int index0;
  final int index1;
  final bool isEvenRow; // true = чётная строка (2, 4, 6...), false = нечётная (1, 3, 5...)
  final int rowIndex;

  const RowForTwo({
    super.key,
    required this.points,
    required this.isLast,
    required this.isFirst,
    required this.isLeft,
    required this.indexFirstUnlocked,
    required this.lastUnlockedIndex,
    required this.index0,
    required this.index1,
    required this.isEvenRow,
    required this.rowIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double height = 127;
    const double circleDiameter = 56;
    const double lineHeight = 10;
    const double curveSize = 56;
    const double spacing = 32; // расстояние между кружками
    // Центры кружков
    final double centerY = height / 2;
    final double totalRowWidth = circleDiameter * 2 + spacing;
    final double startX = (screenWidth - totalRowWidth) / 2;
    final double centerX0 = startX + circleDiameter / 2;
    final double centerX1 = centerX0 + circleDiameter + spacing;
    // Линия между центрами
    final double centerLineWidth = centerX1 - centerX0;
    return Container(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          LeftPoint(
            centerY: centerY,
            lineHeight: lineHeight,
            centerX: centerX0,
            curveSize: curveSize,
            isBlue: index0 <= indexFirstUnlocked,
            rowIndex: rowIndex,
            isFirstRow: isFirst,
            isLastRow: isLast,
          ),
          CenterPoint(
            centerY: centerY,
            lineHeight: lineHeight,
            left: centerX0,
            width: centerLineWidth,
            isBlue: index1 <= indexFirstUnlocked,
            isLastRow: isLast,
          ),
          RightPoint(
            centerY: centerY,
            lineHeight: lineHeight,
            centerX: centerX1,
            curveSize: curveSize,
            isBlue: index1 <= indexFirstUnlocked,
            rowIndex: rowIndex,
            isFirstRow: isFirst,
            isLastRow: isLast,
          ),
          // Точки
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PointItem(
                  point: points[0],
                  index: index0,
                  indexFirstLocked: indexFirstUnlocked,
                  lastUnlockedIndex: lastUnlockedIndex,
                ),
                SizedBox(width: spacing),
                PointItem(
                  point: points[1],
                  index: index1,
                  indexFirstLocked: indexFirstUnlocked,
                  lastUnlockedIndex: lastUnlockedIndex,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
