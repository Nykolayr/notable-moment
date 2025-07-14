import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool selected;
  final bool showResult;
  final bool isRight;
  final bool isWrong;
  const CustomCheckbox(
      {required this.selected, required this.showResult, required this.isRight, required this.isWrong, super.key});

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE0E0E0);
    Color fillColor = Colors.white;
    IconData? icon;
    Color iconColor = Colors.white;

    if (selected && !showResult) {
      borderColor = const Color(0xFF97CB06);
      fillColor = const Color(0xFFEFFFC3);
      icon = Icons.check;
      iconColor = const Color(0xFF97CB06);
    }
    if (isRight) {
      borderColor = const Color(0xFF97CB06);
      fillColor = const Color(0xFFE6F9E2);
      icon = Icons.check;
      iconColor = const Color(0xFF97CB06);
    } else if (isWrong) {
      borderColor = const Color(0xFFFF3B30);
      fillColor = const Color(0xFFFFE6E6);
      icon = Icons.close;
      iconColor = const Color(0xFFFF3B30);
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(6),
        color: fillColor,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: icon != null
          ? Center(
              child: Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            )
          : null,
    );
  }
}
