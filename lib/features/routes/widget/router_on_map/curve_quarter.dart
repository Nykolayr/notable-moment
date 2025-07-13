import 'package:flutter/material.dart';

enum QuarterCorner {
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
}

class CurveQuarter extends StatelessWidget {
  final bool isBlue;
  final QuarterCorner corner;

  const CurveQuarter({
    super.key,
    required this.isBlue,
    required this.corner,
  });

  @override
  Widget build(BuildContext context) {
    double angle = 0;
    switch (corner) {
      case QuarterCorner.rightBottom:
        angle = 0;
        break;
      case QuarterCorner.rightTop:
        angle = -3.14159 / 2;
        break;
      case QuarterCorner.leftTop:
        angle = 3.14159;
        break;
      case QuarterCorner.leftBottom:
        angle = 3.14159 / 2;
        break;
    }
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: const Size(63, 63),
        painter: CurveQuarterPainter(isBlue: isBlue),
      ),
    );
  }
}

class CurveQuarterPainter extends CustomPainter {
  final bool isBlue;
  const CurveQuarterPainter({required this.isBlue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isBlue ? const Color(0xFF466BFF) : const Color(0xFFBCC3CD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Четверть круга: правая нижняя (0°..90°)
    canvas.drawArc(rect, 0, 1.5708, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
