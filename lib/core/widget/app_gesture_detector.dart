import 'package:flutter/material.dart';

class AppGestureDetector extends StatelessWidget {
  const AppGestureDetector({
    super.key,
    required this.onTap,
    this.behavior = HitTestBehavior.opaque,
    required this.child,
  });

  final VoidCallback? onTap;
  final HitTestBehavior behavior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, behavior: behavior, child: child);
  }
}
