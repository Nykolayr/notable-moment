import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
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
    return Scaffold(
      backgroundColor: AppColor.bgText00,
      body: SafeArea(
        top: useSafeAreaTop,
        bottom: useSafeAreaBottom,
        child: Column(
          children: [
            appBar ?? const SizedBox(),
            Expanded(
              child: singleSpageScrollable
                  ? SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height -
                            context.safeArea.vertical -
                            (appBar?.preferredSize.height ?? 0),
                        child: body,
                      ),
                    ) //
                  : body,
            ),
          ],
        ),
      ),
    );
  }
}
