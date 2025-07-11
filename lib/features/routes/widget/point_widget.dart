import 'package:flutter/widgets.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';

class PointWidget extends StatelessWidget {
  const PointWidget({super.key, required this.point, required this.onRemove});

  final PointAdminModel point;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: point.isDraft ? AppColor.orange.withValues(alpha: .1) : AppColor.bgText200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              point.title,
              style: AppStyle.subheader2.copyWith(color: point.isDraft ? AppColor.bgText500 : AppColor.bgText900),
            ),
          ),
          AppButton.icon(
            icon: AppIcon.trash,
            onTap: () => appButtonDeleteDialog(
              title: 'Удалить точку',
              context: context,
              okCallBack: onRemove,
            ),
            style: AppButtonStyle.red,
          ),
        ],
      ),
    );
  }
}
