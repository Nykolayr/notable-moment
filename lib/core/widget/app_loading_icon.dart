import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';

class AppLoadingIcon extends StatelessWidget {
  const AppLoadingIcon({super.key, this.color = AppColor.primary, this.size = 16});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          strokeCap: StrokeCap.round,
          color: color,
        ),
      ),
    );
  }
}
