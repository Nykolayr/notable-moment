import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.white, Colors.black, 0.5),
      body: Center(
        child: SizedBox(
          width: 46,
          height: 46,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            backgroundColor: AppColor.bgText300,
            color: AppColor.primary,
          ),
        ),
      ),
    );
  }
}
