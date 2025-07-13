import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CirclePoint extends StatelessWidget {
  final bool isUnlocked;
  final bool isFirstLocked;
  final bool isLocked;
  final Widget? childIcon;
  final VoidCallback? onTap;
  const CirclePoint({
    super.key,
    required this.isUnlocked,
    required this.isFirstLocked,
    required this.isLocked,
    this.childIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color fillColor;
    if (isUnlocked) {
      borderColor = const Color(0xFF466BFF);
      fillColor = const Color(0xFF466BFF);
    } else if (isFirstLocked) {
      borderColor = const Color(0xFF466BFF);
      fillColor = const Color(0xFF74A5FF);
    } else {
      borderColor = const Color(0xFFBCC3CD);
      fillColor = const Color(0xFFE1E9F4);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Center(child: childIcon),
      ),
    );
  }
}

class PointItem extends StatelessWidget {
  final RoutePoint point;
  final int index;
  final int indexFirstLocked;
  final int lastUnlockedIndex;
  final VoidCallback? onTap;

  const PointItem({
    super.key,
    required this.point,
    required this.index,
    required this.indexFirstLocked,
    required this.lastUnlockedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = index <= lastUnlockedIndex;
    final isFirstLocked = index == indexFirstLocked;
    final isLocked = !isUnlocked && !isFirstLocked;
    Widget? childIcon;
    if (isLocked) {
      childIcon = SvgPicture.asset(
        'assets/svg/lock.svg',
        width: 20,
        height: 20,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CirclePoint(
          isUnlocked: isUnlocked,
          isFirstLocked: isFirstLocked,
          isLocked: isLocked,
          childIcon: childIcon,
          onTap: onTap,
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
    );
  }
}
