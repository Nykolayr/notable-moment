import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.title, required this.value, required this.onChange});

  final String title;
  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return AppGestureDetector(
      onTap: () => onChange(!value),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: value ? AppColor.primary : AppColor.bgText00,
              border: Border.all(color: AppColor.primary),
            ),
            alignment: Alignment.center,
            child: AppIcon.checkmark.svgPricture,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppStyle.body.copyWith(color: value ? AppColor.bgText900 : AppColor.bgText500),
            ),
          ),
        ],
      ),
    );
  }
}
