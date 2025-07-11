import 'package:flutter/widgets.dart';
import 'package:notable_moments/core/theme/app_style.dart';

class AppLabel extends StatelessWidget {
  const AppLabel(this.label, {super.key, this.bottomPadding = 2});
  final String label;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Text(label, style: AppStyle.subtext.bgText500),
    );
  }
}
