import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_dropdown_fullscreen_screen.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class AppDropdownFullscreen extends StatelessWidget {
  const AppDropdownFullscreen({
    super.key,
    required this.value,
    required this.onChanged,
    required this.values,
    this.label,
  });

  final String? value;
  final List<String> values;
  final Function(String? value) onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AppGestureDetector(
      onTap: () async {
        final val = await context.push<String?>(AppDropdownFullscreenScreen(values: values));

        onChanged(val);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[Text(label!, style: AppStyle.subtext.bgText500), const SizedBox(height: 2)],
          Container(
            height: 40,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.bgText200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Не выбрано',
                    style: AppStyle.body.copyWith(color: value == null ? AppColor.bgText500 : AppColor.bgText900),
                  ),
                ),
                const SizedBox(width: 8),
                AppIcon.chevronDown.svgPricture,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
