import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/list_extension.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_back_button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key, //
    required this.title,
    this.showClose = false,
    this.hideLeading = false,
    this.backButtonTap,
    this.actions = const [],
  });

  final String title;
  final bool showClose;
  final bool hideLeading;
  final VoidCallback? backButtonTap;

  static const height = 44.0;

  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Row(
        children: [
          const SizedBox(width: 4),
          if (hideLeading) ...[
            const SizedBox(width: 14),
          ] else ...[
            AppBackButton(onTap: backButtonTap),
            const SizedBox(width: 2),
          ],
          Expanded(child: Text(title, style: AppStyle.body.bgText900)),
          if (actions.isNotEmpty) const SizedBox(width: 8),
          ...actions.separatedBy(const SizedBox(width: 8)),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}
