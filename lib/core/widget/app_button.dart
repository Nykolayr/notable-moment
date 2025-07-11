import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_loading_icon.dart';

enum AppButtonStyle { white, primary, red }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    this.width = double.infinity,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
  })  : icon = null,
        assert(title != null);

  const AppButton.icon({
    super.key,
    required this.icon,
    required this.onTap,
    this.width = 40,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
  })  : title = null,
        assert(icon != null);

  final String? title;
  final String? icon;
  final VoidCallback? onTap;
  final double width;
  final AppButtonStyle style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final canPress = !isDisabled && !isLoading;
    const height = 40.0;

    final bgColor = isDisabled
        ? AppColor.bgText300
        : switch (style) {
            AppButtonStyle.white => AppColor.bgText100,
            AppButtonStyle.primary => AppColor.primary,
            AppButtonStyle.red => AppColor.error,
          };
    final textColor = isDisabled
        ? AppColor.bgText500
        : switch (style) {
            AppButtonStyle.white => AppColor.bgText900,
            AppButtonStyle.primary => AppColor.bgText00,
            AppButtonStyle.red => AppColor.bgText00,
          };

    const loadingSize = 16.0;
    final sizePadding = (height - loadingSize) / 2;

    return AppGestureDetector(
      onTap: canPress
          ? () {
              context.unfocus();
              onTap?.call();
            }
          : null,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: (icon != null) //
            ? isLoading
                ? AppLoadingIcon(color: textColor, size: loadingSize)
                : SvgPicture.asset(
                    icon!, //
                    // ignore: deprecated_member_use
                    color: textColor,
                  )
            : Row(
                children: [
                  if (isLoading) SizedBox(width: sizePadding + loadingSize),
                  const Spacer(),
                  Text(title!, style: AppStyle.subheader2.copyWith(color: textColor)),
                  const Spacer(),
                  if (isLoading) ...[
                    AppLoadingIcon(color: textColor, size: loadingSize),
                    SizedBox(width: sizePadding),
                  ],
                ],
              ),
      ),
    );
  }
}
