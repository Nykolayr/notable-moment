import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/routes/edit_period_screen.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';

class PeriodSummaryWidget extends StatelessWidget {
  const PeriodSummaryWidget({
    super.key,
    required this.period,
    required this.onDelete,
    required this.onSave,
    this.bottomPadding = 0,
  });

  final WorkingPeriod period;
  final VoidCallback onDelete;
  final void Function(WorkingPeriod) onSave;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditPeriodScreen(
              period: period,
              onSave: onSave,
            ),
          ),
        );
        if (!context.mounted) return;
        context.unfocus();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.bgText200,
        ),
        margin: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            Expanded(
              child: Text(
                period.toString(),
                style: AppStyle.body.bgText900,
              ),
            ),
            AppButton.icon(
              icon: AppIcon.trash,
              onTap: onDelete,
              style: AppButtonStyle.red,
            ),
          ],
        ),
      ),
    );
  }
}
