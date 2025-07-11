import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class FoldableItem extends StatefulWidget {
  const FoldableItem({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  State<FoldableItem> createState() => _FoldableItemState();
}

class _FoldableItemState extends State<FoldableItem> {
  bool isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppGestureDetector(
          onTap:
              () => setState(() {
                isCollapsed = !isCollapsed;
              }),
          child: SizedBox(
            height: 34,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(child: Text(widget.title, style: AppStyle.subheader2.bgText900, maxLines: 2)),
                isCollapsed ? AppIcon.chevronDown.svgPricture : AppIcon.chevronUp.svgPricture,
              ],
            ),
          ),
        ),
        if (!isCollapsed) widget.body,
      ],
    );
  }
}
