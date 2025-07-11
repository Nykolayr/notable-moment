import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({super.key, required this.title, required this.onTap, this.color = AppColor.bgText00});

  final String title;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppGestureDetector(
      onTap:
          onTap == null
              ? null
              : () {
                context.unfocus();
                onTap?.call();
              },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(title, style: AppStyle.subheader2.copyWith(color: color)),
      ),
    );
  }
}
