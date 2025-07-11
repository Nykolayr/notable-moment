import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/theme/app_svg.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_checkbox.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/features/routes/enum/week_day_enum.dart';
import 'package:notable_moments/features/routes/model/working_hours_model.dart';

class PeriodTileWidget extends StatefulWidget {
  const PeriodTileWidget({
    super.key,
    required this.period,
    required this.onRemove,
    required this.onChanged,
  });

  final WorkingPeriod period;
  final VoidCallback onRemove;
  final ValueChanged<WorkingPeriod> onChanged;

  @override
  State<PeriodTileWidget> createState() => _PeriodTileWidgetState();
}

class _PeriodTileWidgetState extends State<PeriodTileWidget> {
  late List<WeekDay> selectedDays = List.from(widget.period.days);
  late TimeOfDay timeFrom = widget.period.timeFrom;
  late TimeOfDay timeTo = widget.period.timeTo;
  late bool isAllDay = widget.period.isAllDay;
  late bool isClosed = widget.period.isClosed;

  void _toggleDay(WeekDay day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
      _notifyChange();
    });
  }

  Future<void> _selectTime(bool isFrom) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isFrom ? timeFrom : timeTo,
    );
    if (time != null) {
      setState(() {
        if (isFrom) {
          timeFrom = time;
        } else {
          timeTo = time;
        }
        _notifyChange();
      });
    }
  }

  void _notifyChange() {
    widget.onChanged(
      WorkingPeriod(
        days: selectedDays,
        timeFrom: timeFrom,
        timeTo: timeTo,
        isAllDay: isAllDay,
        isClosed: isClosed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.bgText200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Дни недели', style: AppStyle.body.bgText900),
              ),
              AppGestureDetector(
                onTap: () => appButtonDeleteDialog(
                  context: context,
                  title: 'Удалить период?',
                  description: 'Вы уверены, что хотите удалить этот период?',
                  okCallBack: widget.onRemove,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor.bgText00,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppIcon.close.svgPricture,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: WeekDay.values.map((day) {
              final isSelected = selectedDays.contains(day);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AppGestureDetector(
                    onTap: () => _toggleDay(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected ? AppColor.primary : AppColor.bgText00,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day.shortName,
                        style: AppStyle.body.copyWith(
                          color: isSelected ? AppColor.bgText00 : AppColor.bgText900,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          AppCheckbox(
            title: 'Выходной',
            value: isClosed,
            onChange: (value) {
              setState(() {
                isClosed = value;
                if (isClosed) isAllDay = false;
                _notifyChange();
              });
            },
          ),
          const SizedBox(height: 8),
          AppCheckbox(
            title: 'Круглосуточно',
            value: isAllDay,
            onChange: (value) {
              setState(() {
                isAllDay = value;
                if (isAllDay) isClosed = false;
                _notifyChange();
              });
            },
          ),
          if (!isAllDay && !isClosed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Время открытия', style: AppStyle.body.bgText900),
                      const SizedBox(height: 8),
                      AppGestureDetector(
                        onTap: () => _selectTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: AppColor.bgText00,
                          ),
                          child: Text(
                            '${timeFrom.hour.toString().padLeft(2, '0')}:${timeFrom.minute.toString().padLeft(2, '0')}',
                            style: AppStyle.body.bgText900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Время закрытия', style: AppStyle.body.bgText900),
                      const SizedBox(height: 8),
                      AppGestureDetector(
                        onTap: () => _selectTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: AppColor.bgText00,
                          ),
                          child: Text(
                            '${timeTo.hour.toString().padLeft(2, '0')}:${timeTo.minute.toString().padLeft(2, '0')}',
                            style: AppStyle.body.bgText900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
