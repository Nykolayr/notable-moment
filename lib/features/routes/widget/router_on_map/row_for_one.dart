import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/widget/router_on_map/point_item.dart';

class RowForOne extends StatelessWidget {
  final RoutePoint point;
  final bool isLast;
  final bool isLeft;
  final int indexFirstUnlocked;
  const RowForOne({
    super.key,
    required this.point,
    required this.isLast,
    required this.isLeft,
    required this.indexFirstUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width / 2) - 15;
    return Center(
      child: PointItem(
        point: point,
        index: 0,
        indexFirstLocked: indexFirstUnlocked,
        width: width,
      ),
    );
  }
}
