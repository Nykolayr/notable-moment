import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.singleSpageScrollable = false,
    this.useSafeAreaTop = true,
    this.useSafeAreaBottom = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool singleSpageScrollable;
  final bool useSafeAreaTop;
  final bool useSafeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: useSafeAreaTop,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColor.bgText00,
        appBar: appBar,
        body: body,
      ),
    );
  }
}
