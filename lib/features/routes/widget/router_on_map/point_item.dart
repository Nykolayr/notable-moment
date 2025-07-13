import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PointItem extends StatelessWidget {
  final RoutePoint point;
  final int index;
  final int indexFirstLocked;
  final int lastUnlockedIndex;

  const PointItem({
    super.key,
    required this.point,
    required this.index,
    required this.indexFirstLocked,
    required this.lastUnlockedIndex,
  });

  @override
  Widget build(BuildContext context) {
    Logger.i('point: ${point.toJson()}');
    final isUnlocked = index <= lastUnlockedIndex;
    final isFirstLocked = index == indexFirstLocked;
    final width = (MediaQuery.of(context).size.width / 2) - 30;
    Color borderColor;
    Color fillColor;
    Widget? childIcon;
    if (isUnlocked) {
      borderColor = const Color(0xFF466BFF);
      fillColor = const Color(0xFF466BFF);
      childIcon = null; // Можно добавить иконку, если нужно
    } else if (isFirstLocked) {
      borderColor = const Color(0xFF466BFF);
      fillColor = const Color(0xFF74A5FF);
      childIcon = null;
    } else {
      borderColor = const Color(0xFFBCC3CD);
      fillColor = const Color(0xFFE1E9F4);
      childIcon = SvgPicture.asset(
        'assets/svg/lock.svg',
        width: 20,
        height: 20,
      );
    }
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
            ),
            child: Center(child: childIcon),
          ),
          const SizedBox(height: 8),
          Text(
            point.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9198A1),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
