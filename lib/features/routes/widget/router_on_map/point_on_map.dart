import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'row_for_two.dart';
import 'row_for_one.dart';

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
    List<Widget> rows = [];
    int i = 0;
    final total = points.length;
    final indexFirstLocked = points.indexWhere((p) => i > lastUnlockedIndex);
    while (i < total) {
      // RowForTwo (пара)
      if (i + 1 < total) {
        final isFirst = i == 0;
        final isLast = (i + 2 >= total);
        final isLeft = !isFirst;
        rows.add(RowForTwo(
          points: [points[i], points[i + 1]],
          isFirst: isFirst,
          isLast: isLast,
          isLeft: isLeft,
          indexFirstUnlocked: indexFirstLocked,
          lastUnlockedIndex: lastUnlockedIndex,
          index0: i,
          index1: i + 1,
        ));
        i += 2;
      } else {
        // RowForOne (одиночная в конце)
        final isLast = true;
        final isLeft = true;
        rows.add(RowForOne(
          point: points[i],
          isLast: isLast,
          isLeft: isLeft,
          indexFirstUnlocked: indexFirstLocked,
          lastUnlockedIndex: lastUnlockedIndex,
          index: i,
        ));
        i += 1;
      }
      // Если после пары есть ещё одна точка — одиночная в центре
      if (i < total) {
        final isLast = (i + 1 >= total);
        final isLeft = false;
        rows.add(RowForOne(
          point: points[i],
          isLast: isLast,
          isLeft: isLeft,
          indexFirstUnlocked: indexFirstLocked,
          lastUnlockedIndex: lastUnlockedIndex,
          index: i,
        ));
        i += 1;
      }
    }
    return Column(children: rows);
  }
}
