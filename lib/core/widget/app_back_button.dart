import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap, this.showClose = false});

  final void Function()? onTap;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    return AppGestureDetector(
      onTap: onTap ?? context.pop,
      child: Container(
        height: AppAppBar.height,
        width: AppAppBar.height,
        alignment: Alignment.center,
        child: showClose ? AppIcon.close.svgPricture : AppIcon.back.svgPricture,
      ),
    );
  }
}
