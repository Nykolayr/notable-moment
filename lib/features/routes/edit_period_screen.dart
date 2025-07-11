import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';
import 'package:notable_moments/features/routes/widget/period_tile_widget.dart';

class EditPeriodScreen extends StatefulWidget {
  const EditPeriodScreen({
    super.key,
    required this.period,
    required this.onSave,
  });

  final WorkingPeriod? period;
  final ValueChanged<WorkingPeriod> onSave;

  @override
  State<EditPeriodScreen> createState() => _EditPeriodScreenState();
}

class _EditPeriodScreenState extends State<EditPeriodScreen> {
  late final initialPeriod = isNew
      ? WorkingPeriod(
          days: [],
          timeFrom: TimeOfDay.now(),
          timeTo: TimeOfDay.now(),
          isAllDay: false,
          isClosed: false,
        )
      : widget.period!.copyWith(days: widget.period!.sortedDays);

  late WorkingPeriod editedPeriod = initialPeriod;
  bool get isNew => widget.period == null;
  bool hasError = false;

  // canSave
  bool get canSave => !hasError;

  bool get hasChanges {
    if (!ListEquality().equals(editedPeriod.sortedDays, initialPeriod.sortedDays)) return true;
    if (editedPeriod.timeFrom != initialPeriod.timeFrom) return true;
    if (editedPeriod.timeTo != initialPeriod.timeTo) return true;
    if (editedPeriod.isAllDay != initialPeriod.isAllDay) return true;
    if (editedPeriod.isClosed != initialPeriod.isClosed) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();

    if (!isNew) {
      setPeriod(widget.period!);
    }
  }

  void setPeriod(WorkingPeriod period) {
    // sort days
    setState(() {
      editedPeriod = period;

      hasError = editedPeriod.hasError;
    });
  }

  void handleBack() async {
    if (hasChanges) {
      appButtonDeleteDialog(
        context: context,
        title: 'Несохраненные изменения',
        description: 'У вас есть несохраненные изменения. Вы уверены, что хотите выйти?',
        okText: 'Выйти',
        okStyle: AppButtonStyle.red,
        okCallBack: () => context.pop(),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: isNew ? 'Новое время работы' : 'Редактирование времени работы',
        backButtonTap: handleBack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PeriodTileWidget(
              period: editedPeriod,
              onRemove: () {},
              onChanged: setPeriod,
            ),
            if (hasError) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.error.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColor.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Выберите дни недели и убедитесь, что время начала меньше времени окончания',
                        style: TextStyle(color: AppColor.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            AppButton(
              title: 'Сохранить',
              onTap: canSave
                  ? () {
                      if (!hasError) {
                        widget.onSave(editedPeriod);
                        Navigator.of(context).pop();
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
