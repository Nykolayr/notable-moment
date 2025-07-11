import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class AppEditButton extends StatelessWidget {
  const AppEditButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppGestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(color: AppColor.bgText100, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: AppIcon.edit.svgPricture,
      ),
    );
  }
}
