import 'package:flutter/material.dart';

enum CurveDirection { up, down }

class CurveHalf extends StatelessWidget {
  final bool isBlue;
  final CurveDirection direction; // up = полукруг вверх, down = полукруг вниз
  final bool isReversed; // true = повернуть на 180° (для нечётных строк)

  const CurveHalf({
    super.key,
    required this.isBlue,
    required this.direction,
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget curve = CustomPaint(
      size: const Size(63, 63), // Размер для полукруга
      painter: CurveHalfPainter(
        isBlue: isBlue,
        direction: direction,
      ),
    );

    // Если нужно повернуть на 180°
    if (isReversed) {
      curve = Transform.rotate(
        angle: 3.14159, // 180° = π
        child: curve,
      );
    }

    return curve;
  }
}

class CurveHalfPainter extends CustomPainter {
  final bool isBlue;
  final CurveDirection direction;

  const CurveHalfPainter({
    required this.isBlue,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isBlue ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10; // Толщина линии

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    switch (direction) {
      case CurveDirection.up:
        // Полукруг вверх: от 90° до 270°
        canvas.drawArc(rect, 1.5708, 3.14159, false, paint); // 90° = π/2, 180° = π
        break;
      case CurveDirection.down:
        // Полукруг вниз: от 270° до 90°
        canvas.drawArc(rect, 4.7124, 3.14159, false, paint); // 270° = 3π/2, 180° = π
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
