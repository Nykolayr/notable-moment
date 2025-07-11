import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class AppInfoWidget extends ConsumerStatefulWidget {
  const AppInfoWidget({super.key, required this.text});

  final String text;

  @override
  ConsumerState<AppInfoWidget> createState() => _AppInfoWidgetState();
}

class _AppInfoWidgetState extends ConsumerState<AppInfoWidget> {
  OverlayEntry? _overlayEntry;

  final GlobalKey iconKey = GlobalKey();

  void _showOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    final renderBox = iconKey.currentContext!.findRenderObject() as RenderBox;
    // final position = renderBox.localToGlobal(Offset.zero);

    final offset = -renderBox.globalToLocal(Offset.zero);

    final iconSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // left: position.dx + renderBox.size.width / 2 - 100,
        // top: position.dy, // - renderBox.size.height - 8,
        // left: position.dx,
        bottom: offset.dy - iconSize.height - 16,
        left: offset.dx + iconSize.width / 2 - 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 200,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColor.bgText600, borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.center,
            child: Text(widget.text, style: AppStyle.subtext.bgText00, textAlign: TextAlign.center),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 2 seconds
    Future.delayed(Duration(seconds: 2), () => _removeOverlay());
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return AppGestureDetector(key: iconKey, onTap: () => _showOverlay(), child: AppIcon.info.svgPricture);
  }
}
