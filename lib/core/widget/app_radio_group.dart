import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';

class AppRadioValue<T> {
  const AppRadioValue({required this.value, required this.label});
  final T value;
  final String label;
}

class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({super.key, required this.values, required this.value, required this.onChanged, this.label});

  final List<AppRadioValue<T>> values;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Пол', style: AppStyle.subtext.bgText500),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children:
              values
                  .map((v) => _Item(value: v, isSelected: v.value == value, onTap: () => onChanged(v.value)))
                  .toList(),
        ),
      ],
    );
  }
}

class _Item<T> extends StatelessWidget {
  const _Item({required this.value, required this.isSelected, required this.onTap});
  final AppRadioValue<T> value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppGestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSelected
              ? Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(color: AppColor.primary.withValues(alpha: .3), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.primary),
                ),
              )
              : Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.primary, width: 1, strokeAlign: BorderSide.strokeAlignInside),
                ),
              ),

          const SizedBox(width: 8),
          Text(value.label, style: AppStyle.body.bgText900.h1),
        ],
      ),
    );
  }
}
