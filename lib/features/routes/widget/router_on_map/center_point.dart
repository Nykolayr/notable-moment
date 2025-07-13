import 'package:flutter/material.dart';

class CenterPoint extends StatelessWidget {
  final double centerY;
  final double lineHeight;
  final double left;
  final double width;
  final bool isBlue;
  final bool isLastRow;
  const CenterPoint({
    super.key,
    required this.centerY,
    required this.lineHeight,
    required this.left,
    required this.width,
    required this.isBlue,
    required this.isLastRow,
  });

  @override
  Widget build(BuildContext context) {
    if (isLastRow) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: left,
      top: centerY - lineHeight / 2 - 15,
      width: width,
      height: lineHeight,
      child: Container(
        color: isBlue ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD),
      ),
    );
  }
}
