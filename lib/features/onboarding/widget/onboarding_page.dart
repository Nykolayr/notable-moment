import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imageWidget,
    required this.index,
    required this.bottomButton,
  });

  final String title;
  final String description;
  final Widget imageWidget;
  final int index;
  final Widget bottomButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        backgroundColor: AppColor.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyle.headline.bgText200),
                const SizedBox(height: 11),
                Text(description, style: AppStyle.roboto14w500.bgText200),
                Expanded(child: Center(child: imageWidget)),
                _IndicatorRow(index: index),
                const SizedBox(height: 16),

                Center(child: bottomButton),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 3,
          width: index == 0 ? 48 : 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: AppColor.bgText00.withValues(alpha: index >= 0 ? 1 : 0.6),
          ),
        ),
        const SizedBox(width: 3),
        Container(
          height: 3,
          width: index == 1 ? 48 : 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: AppColor.bgText00.withValues(alpha: index >= 1 ? 1 : 0.6),
          ),
        ),
        const SizedBox(width: 3),
        Container(
          height: 3,
          width: index == 2 ? 48 : 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: AppColor.bgText00.withValues(alpha: index >= 2 ? 1 : 0.6),
          ),
        ),
      ],
    );
  }
}
