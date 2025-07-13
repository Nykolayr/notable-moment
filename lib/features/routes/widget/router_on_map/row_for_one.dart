import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_item.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/left_point.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/right_point.dart';

class RowForOne extends StatelessWidget {
  final RoutePoint point;
  final bool isLast;
  final bool isLeft;
  final int indexFirstUnlocked;
  final int lastUnlockedIndex;
  final int index;
  final bool isEvenRow; // true = чётная строка (2, 4, 6...), false = нечётная (1, 3, 5...)
  final int rowIndex;

  const RowForOne({
    super.key,
    required this.point,
    required this.isLast,
    required this.isLeft,
    required this.indexFirstUnlocked,
    required this.lastUnlockedIndex,
    required this.index,
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
    final double centerY = height / 2;
    final double centerX = screenWidth / 2;
    return Container(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          LeftPoint(
            centerY: centerY,
            lineHeight: lineHeight,
            centerX: centerX,
            curveSize: curveSize,
            isBlue: index <= indexFirstUnlocked,
            rowIndex: rowIndex,
            isFirstRow: index == 0,
            isLastRow: isLast,
          ),
          RightPoint(
            centerY: centerY,
            lineHeight: lineHeight,
            centerX: centerX,
            curveSize: curveSize,
            isBlue: index <= indexFirstUnlocked,
            rowIndex: rowIndex,
            isFirstRow: index == 0,
            isLastRow: isLast,
          ),
          Align(
            alignment: Alignment.center,
            child: PointItem(
              point: point,
              index: index,
              indexFirstLocked: indexFirstUnlocked,
              lastUnlockedIndex: lastUnlockedIndex,
            ),
          ),
        ],
      ),
    );
  }
}
