import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_item.dart';

class RowForTwo extends StatelessWidget {
  final List<RoutePoint> points;
  final bool isLast;
  final bool isFirst;
  final bool isLeft;
  final int indexFirstUnlocked;

  const RowForTwo({
    super.key,
    required this.points,
    required this.isLast,
    required this.isFirst,
    required this.isLeft,
    required this.indexFirstUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width / 2) - 15;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PointItem(
          point: points[0],
          index: 0,
          indexFirstLocked: indexFirstUnlocked,
          width: width,
        ),
        PointItem(
          point: points[1],
          index: 1,
          indexFirstLocked: indexFirstUnlocked,
          width: width,
        ),
      ],
    );
  }
}
