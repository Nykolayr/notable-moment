import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_item.dart';

class RowForTwo extends StatelessWidget {
  final List<RoutePoint> points;
  final bool isLast;
  final bool isFirst;
  final bool isLeft;
  final int indexFirstUnlocked;
  final int lastUnlockedIndex;
  final int index0;
  final int index1;

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
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width / 2) - 15;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PointItem(
          point: points[0],
          index: index0,
          indexFirstLocked: indexFirstUnlocked,
          lastUnlockedIndex: lastUnlockedIndex,
          width: width,
        ),
        PointItem(
          point: points[1],
          index: index1,
          indexFirstLocked: indexFirstUnlocked,
          lastUnlockedIndex: lastUnlockedIndex,
          width: width,
        ),
      ],
    );
  }
}
