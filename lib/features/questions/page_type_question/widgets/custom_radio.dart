import 'package:flutter/material.dart';

class CustomRadio extends StatelessWidget {
  final bool selected;
  final bool showResult;
  final bool isRight;
  final bool isWrong;
  const CustomRadio({
    required this.selected,
    required this.showResult,
    required this.isRight,
    required this.isWrong,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFF466BFF);
    Color dotColor = Colors.transparent;
    Color dotBorder = Colors.transparent;
    Color outerColor = Colors.white;

    if (selected && !showResult) {
      borderColor = Colors.transparent; // Убираем бордер когда выбран
      dotColor = const Color(0xFF97CB06);
      dotBorder = const Color(0x4D97CB06); // 30% opacity
      outerColor = const Color(0x4D97CB06); // 30% opacity зелёного
    }
    if (isRight) {
      dotColor = const Color(0xFF97CB06);
      dotBorder = const Color(0x4D97CB06);
      borderColor = const Color(0xFF97CB06);
      outerColor = Colors.white;
    } else if (isWrong) {
      dotColor = const Color(0xFFFF3B30);
      dotBorder = const Color(0x33FF3B30);
      borderColor = const Color(0xFFFF3B30);
      outerColor = Colors.white;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outerColor,
        border: borderColor != Colors.transparent ? Border.all(color: borderColor, width: 1.5) : null,
      ),
      child: Center(
        child: selected || isRight || isWrong
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: Border.all(color: dotBorder, width: 6),
                ),
              )
            : null,
      ),
    );
  }
}
