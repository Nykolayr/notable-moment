import 'package:flutter/material.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_label.dart';
import 'package:notable_moments/features/routes/edit_period_screen.dart';
import 'package:notable_moments/features/routes/enum/week_day_enum.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';
import 'package:notable_moments/features/routes/widget/period_summary_widget.dart';

class ScheduleEditorWidget extends StatefulWidget {
  const ScheduleEditorWidget({
    super.key,
    required this.schedule,
    required this.onScheduleChanged,
  });

  final WorkingHours schedule;
  final ValueChanged<WorkingHours> onScheduleChanged;

  @override
  State<ScheduleEditorWidget> createState() => _ScheduleEditorWidgetState();
}

class _ScheduleEditorWidgetState extends State<ScheduleEditorWidget> {
  late List<WorkingPeriod> periods = List.from(widget.schedule.periods);

  void _addPeriod() async {
    final newPeriod = WorkingPeriod(
      days: [WeekDay.monday],
      timeFrom: const TimeOfDay(hour: 9, minute: 0),
      timeTo: const TimeOfDay(hour: 18, minute: 0),
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPeriodScreen(
          period: newPeriod,
          onSave: (period) {
            setState(() {
              periods.add(period);
            });
            _notifyChange();
          },
        ),
      ),
    );
  }

  void _removePeriod(int index) => appButtonDeleteDialog(
        title: 'Удалить период',
        context: context,
        okCallBack: () {
          setState(() {
            periods.removeAt(index);
          });
          _notifyChange();
        },
      );

  void _updatePeriod(int index, WorkingPeriod period) {
    setState(() {
      periods[index] = period;
    });
    _notifyChange();
  }

  void _notifyChange() {
    widget.onScheduleChanged(WorkingHours(periods: periods));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppLabel('График работы'),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: periods.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = periods.removeAt(oldIndex);
              periods.insert(newIndex, item);
            });
            _notifyChange();
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final elevation = Curves.easeInOut.transform(animation.value);
                final period = periods[index];
                return Material(
                  elevation: elevation,
                  borderRadius: BorderRadius.circular(8),
                  child: PeriodSummaryWidget(
                    key: ValueKey('period_${period.hashCode}'),
                    period: period,
                    onDelete: () => _removePeriod(index),
                    onSave: (period) => _updatePeriod(index, period),
                  ),
                );
              },
            );
          },
          itemBuilder: (context, index) => PeriodSummaryWidget(
            key: ValueKey('period_$index'),
            period: periods[index],
            onDelete: () => _removePeriod(index),
            onSave: (period) => _updatePeriod(index, period),
            bottomPadding: index == periods.length - 1 ? 0 : 8,
          ),
        ),
        if (periods.isNotEmpty) const SizedBox(height: 8),
        AppButton(
          title: 'Добавить период',
          onTap: _addPeriod,
          style: AppButtonStyle.primary,
        ),
      ],
    );
  }
}
